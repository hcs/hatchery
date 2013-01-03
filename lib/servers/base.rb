require 'lib/hostname'

class Server
  AMI = 'ami-d726abbe' # Ubuntu 12.04.1 LTS, using instance store
  KEY_NAME = 'HCS'
  SECURITY_GROUPS = ['sg-ec12f983'] # SSH access
  INSTANCE_TYPE = 'm1.small'
  PRIVATE_KEY = 'HCS.pem'

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
    sleep 1 while @instance.status == :pending

    $log.info "Launched instance #{@instance.id}, status: #{@instance.status}"

    raise "Status error!" unless @instance.status == :running

    create_hook

    $log.info "Everything is shiny. Have fun with #{@hostname}"
  end

  def terminate
    if @instance.nil? || @instance.status == :terminated
      raise "Instance is already gone (or maybe never existed)!"
    end

    # TODO: think about cleaning up EIPs?
    @instance.terminate
  end

  ### Hooks

  def create_hook
    ssh_hook
  end

  def ssh_hook
    $log.info "Trying to SSH to #{@instance.ip_address}"

    # Set up hostname
    ssh "echo 127.0.0.1 #{@hostname} | sudo tee -a /etc/hosts"
    ssh "sudo hostname #{@hostname}"
    ssh "echo #{@hostname} | sudo tee /etc/hostname"

    # Package upgrades
    ssh 'sudo apt-get update'
    ssh 'sudo apt-get dist-upgrade -y'
  end

  # Proxy some methods through to the underlying EC2 instance
  [:id, :launch_time, :ip_address, :private_ip_address, :status].each do |m|
    define_method m do |*args|
      raise "Server does not exist yet!" if @instance.nil?
      @instance.send m, *args
    end
  end

  # SSH support
  def ssh cmd
    if @ssh.nil?
      key = fetch_secret self.class::PRIVATE_KEY
      begin
        @ssh = connect key
        $log.info "Connected via SSH"
      rescue SystemCallError, Timeout::Error => e
        # From the sample code: "port 22 might not be available immediately
        # after the instance finishes launching"
        sleep 1
        retry
      end
    end

    $log.info "#{@hostname}$ #{cmd}"
    @ssh.stream "TERM='#{ENV['TERM'] || 'vt100'}' #{cmd}"
  end

  private
  def connect key
    ip = @instance.private_ip_address
    Net::SSH.start ip, 'ubuntu', :key_data => [key], :proxy => SSH_GATEWAY
  end
end
