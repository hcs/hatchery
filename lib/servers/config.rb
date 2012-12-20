class ConfigServer < Server
  INSTANCE_TYPE = 't1.micro'
  IP_RANGE = 4..9

  def ssh_hook ssh
    super

    # XXX: We should switch to the normal Bcfg2 PPA when 1.3.0 is released
    ssh.stream 'sudo add-apt-repository ppa:bcfg2/precisetesting'
    ssh.stream 'sudo apt-get update'

    ssh.stream 'sudo apt-get install -y bcfg2-server bcfg2 git'
    ssh.stream 'sudo rm -r /var/lib/bcfg2'
    ssh.stream 'sudo git clone https://github.com/hcs/config.git /var/lib/bcfg2'

    key = fetch_secret 'bcfg2-crypt-key'
    ssh.stream "sudo /var/lib/bcfg2/bin/bootstrap #{key}"
  end
end
