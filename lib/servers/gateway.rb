class GatewayServer < Server
  IP_RANGE = 15...20
  SECURITY_GROUPS = ['sg-dfde28b0']
  PUBLIC = true

  def create_hook
    $log.info "Allocating an IP address for the bifrost"
    @instance.ip_address = $EC2.elastic_ips.allocate :vpc => true
    $log.info "Allocated IP #{@instance.ip_address}"

    ssh_hook
  end
end
