require 'lib/hostname'

class Server
  AMI = 'ami-d726abbe' # Ubuntu 12.04.1 LTS, using instance store
  KEY_NAME = 'HCS'
  SECURITY_GROUPS = ['sg-5813f837']
  INSTANCE_TYPE = 'm1.small'
  PUBLIC = false

  # Factory magic!
  class << self
    alias_method :the_real_new, :new

    def new hostname
      h = Hostname.new hostname
      h.server_class.the_real_new h
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
    if !@instance.nil? && @instance.status != :terminated
      raise "Instance is already running! Refusing to create a duplicate"
    end

    $log.info "About to start instance #{@hostname} of type #{self.class.name}"

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

    $log.info "Waiting for #{@hostname}"
    sleep 1 while status == :pending

    $log.info "Launched instance #{id}, status: #{status}"

    raise "Status error!" unless status == :running

    create_hook

    $log.info "Everything is shiny. Have fun with #{@hostname}"
  end

  def terminate
    if @instance.nil? || @instance.status == :terminated
      raise "Instance is already gone (or maybe never existed)!"
    end

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
    ssh "echo #{@hostname} | sudo tee /etc/hostname"

    # Package upgrades
    # XXX: We should switch to the normal Bcfg2 PPA when 1.3.0 is released
    ssh 'sudo add-apt-repository -y ppa:bcfg2/precisetesting'
    ssh 'sudo apt-get update'
    ssh 'sudo apt-get dist-upgrade -y'

    ssh 'sudo apt-get install -y bcfg2'
  end

  def finalize
    raise 'Not bootstrapped yet' unless bootstrapped?

    ssh 'deluser --remove-home ubuntu'
  end

  # Proxy some methods through to the underlying EC2 instance
  [:id, :launch_time, :ip_address, :private_ip_address, :status].each do |m|
    define_method m do |*args|
      raise "Server does not exist yet!" if @instance.nil?
      @instance.send m, *args
    end
  end
  alias_method :ip, :private_ip_address

  # SSH support
  def ssh cmd
    raise 'No instance' if @instance.nil?
    if @ssh.nil?
      key = fetch_secret "#{self.class::KEY_NAME}.pem"
      begin
        @ssh = connect key
        $log.info "Connected via SSH"
      rescue SystemCallError, Timeout::Error, Net::SSH::Disconnect => e
        # From the sample code: "port 22 might not be available immediately
        # after the instance finishes launching"
        $log.info "SSH unavailable. Trying again in 1s!"
        sleep 1
        retry
      end
    end

    $log.info "#{@hostname}$ #{cmd}"
    @ssh.stream "TERM='#{ENV['TERM'] || 'vt100'}' #{cmd}"
  end

  def bootstrapped?
    !@instance.tags['Bootstrapped'].nil?
  end

  private
  def connect key
    user = bootstrapped? ? 'root' : 'ubuntu'
    Net::SSH.start ip, user, :key_data => [key], :proxy => Gateway
  end
end
