class GatewayServer < Server
  IP_RANGE = 15...20
  SECURITY_GROUPS = ['sg-dfde28b0']
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
