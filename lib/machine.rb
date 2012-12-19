class Machine
  AMI = 'ami-3d4ff254' # Ubuntu 12.04.1 LTE
  KEY_NAME = 'HCS'
  SECURITY_GROUPS = ['sg-ec12f983'] # SSH access
  INSTANCE_TYPE = 'm1.small'
  SUBNET = 'subnet-4111e52b' # Public subnet
  PRIVATE_KEY = 'HCS.pem'

  def initialize name
    @name = name
  end

  def create
    # TODO: check if this instance already exists?
    $log.info "About to start instance #{@name} of type #{self.class.name}"

    # The self.class::CONSTANT thing here is so subclasses can override the
    # constants in a reasonable way
    @instance = $EC2.images[self.class::AMI].run_instance(
      :instance_type      => self.class::INSTANCE_TYPE,
      :key_name           => self.class::KEY_NAME,
      :security_group_ids => self.class::SECURITY_GROUPS,
      :subnet             => self.class::SUBNET
    )

    $log.info "Waiting for #{@name}"
    sleep 1 while @instance.status == :pending

    $log.info "Launched instance #{@instance.id}, status: #{@instance.status}"

    raise "Status error!" unless @instance.status == :running

    $log.info "Allocating an IP address for the new instance"
    @instance.ip_address = $EC2.elastic_ips.allocate :vpc => true
    $log.info "Allocated IP #{@instance.ip_address}"

    launch_hook

    $log.info "Trying to SSH to #{@instance.ip_address}"
    remote_exec do |ssh|
      $log.info "We're in! Calling SSH hook."
      ssh_hook ssh
    end

    post_hook

    $log.info "Everything is shiny. Have fun with #{@instance}"
  end

  ### Hooks

  def launch_hook
  end

  def ssh_hook ssh
    ssh.stream 'sudo apt-get update'
    ssh.stream 'sudo apt-get upgrade -y'
  end

  def post_hook
  end

  ### Helpers

  private
  def remote_exec &blk
    raise "No instance" unless @instance
    raise "No IP" unless @instance.ip_address
    key = fetch_secret self.class::PRIVATE_KEY
    begin
      Net::SSH.start(@instance.ip_address, 'ubuntu', :key_data => [key], &blk)
    rescue SystemCallError, Timeout::Error => e
      # From the sample code: "port 22 might not be available immediately after
      # the instance finishes launching"
      sleep 1
      retry
    end
  end
end
