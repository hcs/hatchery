class FileServer < Server
  INSTANCE_TYPE = 'm1.large'
  IP_RANGE = 250..253

  def ssh_hook
    super

    # ubuntu-zfs requires kernel headers, but the package has broken
    # dependencies or something, so it doesn't actually get installed
    ssh 'sudo apt-get install -y linux-headers-virtual'

    ssh 'sudo add-apt-repository ppa:zfs-native/stable'
    ssh 'sudo apt-get update'

    ssh 'sudo apt-get install -y ubuntu-zfs'
  end
end
