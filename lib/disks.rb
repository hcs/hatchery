# Taken from
# http://docs.amazonwebservices.com/AWSEC2/latest/UserGuide/InstanceStorage.html
EPHEMERAL_DISKS = {
  't1.micro' => 0,    # None (use Amazon EBS volumes)
  'm1.small' => 1,    # 1 x 150 GiB
  'm1.medium' => 1,   # 1 x 400 GiB
  'm1.large' => 2,    # 2 x 420 GiB (840 GiB)
  'm1.xlarge' => 4,   # 4 x 420 GiB (1680 GiB)
  'm3.xlarge' => 0,   # None (use Amazon EBS volumes)
  'm3.2xlarge' => 0,  # None (use Amazon EBS volumes)
  'c1.medium' => 1,   # 1 x 340 GiB
  'c1.xlarge' => 4,   # 4 x 420 GiB (1680 GiB)
  'm2.xlarge' => 1,   # 1 x 410 GiB
  'm2.2xlarge' => 1,  # 1 x 840 GiB
  'm2.4xlarge' => 2,  # 2 x 840 GiB (1680 GiB)
  'hi1.4xlarge' => 2, # 2 x 1 TiB SSD (2 TiB)
  'cc1.4xlarge' => 2, # 2 x 840 GiB (1680 GiB)
  'cc2.8xlarge' => 4, # 4 x 840 GiB (3360 GiB)
  'cg1.4xlarge' => 2  # 2 x 840 GiB (1680 GiB)
}

# TODO: do something with this. Local raid storage?
