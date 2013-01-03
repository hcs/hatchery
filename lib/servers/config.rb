class ConfigServer < Server
  AMI = 'ami-fd20ad94' # Ubuntu 12.04.1 LTS, using EBS
  INSTANCE_TYPE = 't1.micro'
  IP_RANGE = 4..9

  def ssh_hook
    super

    # XXX: We should switch to the normal Bcfg2 PPA when 1.3.0 is released
    ssh 'sudo add-apt-repository ppa:bcfg2/precisetesting'
    ssh 'sudo apt-get update'

    ssh 'sudo apt-get install -y bcfg2-server bcfg2 git'
    ssh 'sudo rm -r /var/lib/bcfg2'
    ssh 'sudo git clone https://github.com/hcs/config.git /var/lib/bcfg2'

    key = fetch_secret 'bcfg2-crypt-key'
    ssh "sudo /var/lib/bcfg2/bin/bootstrap #{key}"
  end
end
