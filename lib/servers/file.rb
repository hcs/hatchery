class FileServer < Server
  INSTANCE_TYPE = 'm1.large'
  IP_RANGE = 250...254
  SECURITY_GROUPS = ['sg-c6de28a9']
end
