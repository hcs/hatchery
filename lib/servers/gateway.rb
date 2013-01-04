class GatewayServer < Server
  AMI = 'ami-fd20ad94' # Ubuntu 12.04.1 LTS, using EBS
  INSTANCE_TYPE = 't1.micro'
  IP_RANGE = 10...15

  def create_hook
    $log.info "Allocating an IP address for the gateway"
    @instance.ip_address = $EC2.elastic_ips.allocate :vpc => true
    $log.info "Allocated IP #{@instance.ip_address}"

    ssh_hook
  end

  private
  def connect key
    Net::SSH.start @instance.ip_address, 'ubuntu', :key_data => [key]
  end
end
