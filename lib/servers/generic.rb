class GenericServer < Server
  AMI = 'ami-d0f89fb9' # Ubuntu 12.04.1 LTS, using EBS
  INSTANCE_TYPE = 't1.micro'
  IP_RANGE = 200...250
end
