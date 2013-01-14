class GatewayServer < Server
  AMI = 'ami-fd20ad94' # Ubuntu 12.04.1 LTS, using EBS
  INSTANCE_TYPE = 't1.micro'
  IP_RANGE = 10...15
  SECURITY_GROUPS = ['sg-dfde28b0']
  PUBLIC = true

  def create_hook
    $log.info "Allocating an IP address for the gateway"
    @instance.ip_address = $EC2.elastic_ips.allocate :vpc => true
    $log.info "Allocated IP #{@instance.ip_address}"

    # Disable source/destination checking, so we can act as a NAT for other
    # instances in the VPC.
    @instance.network_interfaces.each do |ni|
      ni.source_dest_check = false
    end

    ssh_hook

    $log.info "Be sure to change the routing tables to go through instance #{id}"
  end

  private
  def start_ssh key
    Net::SSH.start @instance.ip_address, 'ubuntu', :key_data => [key]
  end
end
