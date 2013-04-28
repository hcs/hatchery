class ConfigServer < Server
  AMI = 'ami-d0f89fb9' # Ubuntu 12.04.1 LTS, using EBS
  INSTANCE_TYPE = 't1.micro'
  IP_RANGE = 4...10
  SECURITY_GROUPS = ['sg-dede28b1']

  def ssh_hook
    super

    ssh "echo #{ip} config.hcs.harvard.edu | sudo tee -a /etc/hosts"

    ssh 'sudo apt-get install -y bcfg2-server git'
    ssh 'sudo rm -r /var/lib/bcfg2'
    ssh 'sudo git clone https://github.com/hcs/config.git /var/lib/bcfg2'

    key = fetch_secret 'bcfg2-crypt-key'
    ssh "sudo /var/lib/bcfg2/bin/bootstrap #{key}"
  end

  def bcfg2
    ssh 'sudo bcfg2 -C /etc/bcfg2-bootstrap.conf -vqe'
  end

  def pull
    ssh 'cd /var/lib/bcfg2 && sudo git pull'
  end
  def version
    ssh 'cd /var/lib/bcfg2 && sudo git rev-parse HEAD'
  end
end
