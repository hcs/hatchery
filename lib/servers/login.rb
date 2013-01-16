class LoginServer < Server
  IP_RANGE = 20...30
  SECURITY_GROUPS = ['sg-791dec16']
  PUBLIC = true

  def create_hook
    $log.info "Allocating an IP address for the login server"
    @instance.ip_address = $EC2.elastic_ips.allocate :vpc => true
    $log.info "Allocated IP #{@instance.ip_address}"

    ssh_hook
  end
end
