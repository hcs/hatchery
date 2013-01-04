class GenericServer < Server
  AMI = 'ami-fd20ad94' # Ubuntu 12.04.1 LTS, using EBS
  INSTANCE_TYPE = 't1.micro'
  IP_RANGE = 200...250
end
