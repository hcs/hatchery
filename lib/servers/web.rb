class WebServer < Server
  INSTANCE_TYPE = 'c1.medium'
  IP_RANGE = 30..40
  SECURITY_GROUPS = ['sg-4952a326']
end
