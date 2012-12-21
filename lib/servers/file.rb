class FileServer < Server
  INSTANCE_TYPE = 'm1.large'
  IP_RANGE = 250..253

  def ssh_hook ssh
    super

    ssh.stream 'sudo add-apt-repository ppa:zfs-native/stable'
    ssh.stream 'sudo apt-get update'

    ssh.stream 'sudo apt-get install -y ubuntu-zfs'
  end
end
