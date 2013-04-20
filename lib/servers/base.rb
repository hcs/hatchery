require 'lib/hostname'
require 'lib/bcfg2'

class Server
  include SSHable
  include Bcfg2

  AMI = 'ami-d726abbe' # Ubuntu 12.04.1 LTS, using instance store
  KEY_NAME = 'HCS'
  SECURITY_GROUPS = ['sg-5813f837']
  INSTANCE_TYPE = 'm1.small'
  PUBLIC = false

  class << self
    alias_method :the_real_new, :new

    # Factory magic!
    def new hostname
      h = Hostname.new hostname
      h.server_class.the_real_new h
    end

    def all
      AWS.memoize do
        $EC2.instances.map do |instance|
          new instance.tags['Name'] rescue nil if instance.status != :terminated
        end
      end
    end
  end

  attr_reader :hostname, :instance

  def initialize hostname
    @hostname = hostname
    AWS::memoize do
      @instance = $EC2.instances.filter('tag:Name', @hostname.to_s).find do |i|
        i.status != :terminated
      end
    end
  end

  def create
    create_instance
    wait

    $log.info "Launched instance #{id}, status: #{status}"
    raise "Status error!" unless status == :running

    create_hook

    $log.info "Everything is shiny, Capt'n!"
    $log.info "If this machine is bcfg2'd, try running Server#bootstrap next"
  end

  def terminate
    if @instance.nil? || @instance.status == :terminated
      raise "Instance is already gone (or maybe never existed)!"
    end

    disconnect

    # TODO: think about cleaning up EIPs?
    @instance.terminate
    @instance = nil
  end

  ### Hooks

  def create_hook
    ssh_hook
  end

  def ssh_hook
    # Set up hostname
    ssh "echo #{ip} #{@hostname} | sudo tee -a /etc/hosts"
    ssh "sudo hostname #{@hostname}"
    dropbear '/etc/hostname', @hostname.to_s

    # Package upgrades
    ssh 'sudo apt-get update'
    ssh 'sudo apt-get dist-upgrade -y'

    install_bcfg2
  end

  # Proxy some methods through to the underlying EC2 instance
  [:id, :launch_time, :ip_address, :private_ip_address, :status].each do |m|
    define_method m do |*args|
      raise "Server does not exist yet!" if @instance.nil?
      @instance.send m, *args
    end
  end
  alias_method :ip, :private_ip_address
  alias_method :public_ip, :ip_address

  # Actually do the dirty work of creating the instance through the AWS API
  def create_instance
    if !@instance.nil? && @instance.status != :terminated
      raise "Instance is already running! Refusing to create a duplicate"
    end

    $log.info "About to create instance #{@hostname} of type #{self.class.name}"

    # The self.class::CONSTANT thing here is so subclasses can override the
    # constants in a reasonable way
    @instance = $EC2.instances.create(
      :image_id           => self.class::AMI,
      :instance_type      => self.class::INSTANCE_TYPE,
      :key_name           => self.class::KEY_NAME,
      :security_group_ids => self.class::SECURITY_GROUPS,
      :subnet             => @hostname.subnet,
      :private_ip_address => @hostname.ip
    )
    @instance.tag 'Name', :value => @hostname.to_s
  end

  # Some states mean that the instance is busy performing some action for us.
  # This is a generalized function that waits until that action is done.
  def wait
    $log.info "Waiting for #{@hostname}"
    sleep 1 while [:pending, :'shutting-down', :stopping].include? status
  end
end
