class BifrostServer < Server
  AMI = 'ami-fd20ad94' # Ubuntu 12.04.1 LTS, using EBS
  INSTANCE_TYPE = 't1.micro'
  IP_RANGE = 10...15
  SECURITY_GROUPS = ['sg-1347827c']
  PUBLIC = true

  def create_hook
    $log.info "Allocating an IP address for the bifrost"
    @instance.ip_address = $EC2.elastic_ips.allocate :vpc => true
    $log.info "Allocated IP #{@instance.ip_address}"

    # Disable source/destination checking, so we can act as a NAT for other
    # instances in the VPC.
    @instance.network_interfaces.each do |ni|
      ni.source_dest_check = false
    end

    ssh_hook

    ssh 'echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward'

    $log.info "Be sure to change the routing tables to go through instance #{id}"
  end
end
