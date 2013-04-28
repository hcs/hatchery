class BifrostServer < Server
  AMI = 'ami-d0f89fb9' # Ubuntu 12.04.1 LTS, using EBS
  INSTANCE_TYPE = 't1.micro'
  IP_RANGE = 10...15
  SECURITY_GROUPS = ['sg-1347827c']
  PUBLIC = true

  def create_hook
    $log.info "Allocating an IP address for the bifrost"
    @instance.ip_address = $EC2.elastic_ips.allocate :vpc => true
    $log.info "Allocated IP #{@instance.ip_address}"

    ssh_hook
  end
end
