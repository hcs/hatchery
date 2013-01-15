require 'thread'
require 'socket'

# TODO: multiple gateways?
class Gateway
  @@ssh = nil
  @@lock = Mutex.new
  def self.connect!
    return unless @@ssh.nil?

    # We need to require here to prevent a circular dependency
    require 'lib/servers/gateway'

    # TODO: hcs.harvard.edu
    host = 'gateway.hcs.so'
    key = fetch_secret "#{GatewayServer::KEY_NAME}.pem"

    $log.info "Establishing connection to gateway server #{host}"
    @@ssh = Net::SSH.start host, 'ubuntu', :key_data => [key]

    Thread.new do
      loop do
        @@lock.synchronize do
          # A smaller timeout means we send data more interactively
          @@ssh.process 0.001
        end
        Thread.pass
      end
    end
  end

  # Pipe data back and forth between an SSH channel and a socket
  def self.pipe channel, socket
    channel.on_data do |ch, data|
      socket.send data, 0
    end
    channel.on_close do
      socket.close_write
    end
    Thread.new do
      loop do
        msg = socket.recv 1024
        if msg.length == 0
          channel.eof!
          break
        end
        channel.send_data msg
      end
    end
  end

  def self.open host, port
    connect!

    local, remote = UNIXSocket.pair

    @@lock.synchronize do
      @@ssh.open_channel do |channel|
        channel.exec "nc #{host} #{port}" do |ch, ok|
          raise Net::SSH::Disconnect.new unless ok

          pipe ch, remote
        end
      end
    end

    # HACK: stub this out, since unix sockets don't have IPs.
    local.instance_variable_set :@peer_ip, host

    local
  end
end

module SSHable
  def ssh cmd
    raise 'No instance' if instance.nil?
    connect if @ssh.nil?

    $log.info "#{@hostname}$ #{cmd}"
    @ssh.exec! "TERM='#{ENV['TERM'] || 'vt100'}' #{cmd}" do |ch, stream, data|
      fd = stream == :stderr ? $stderr : $stdout
      fd.print data
      fd.flush
    end
  end

  # The Drop Bear, Thylarctos plummetus, is a large, arboreal, predatory
  # marsupial related to the Koala.
  #
  # Drop Bears hunt by ambushing ground dwelling animals from above, waiting up
  # to as much as four hours to make a surprise kill. Once prey is within view,
  # the Drop Bear will drop as much as eight metres to pounce on top of the
  # unsuspecting victim. The initial impact often stuns the prey, allowing it to
  # be bitten on the neck and quickly subdued.
  #
  # In their spare time, Drop Bears have been known to drop files on remote
  # servers with stunning accuracy.
  def dropbear path, str
    raise 'No instance' if @instance.nil?
    connect if @ssh.nil?

    # To make things easier on droppers, try to detect--and strip--leading
    # indentation
    min_indent = str.gsub(/[\r\n]+/, "\n").scan(/^ */).map(&:length).min
    str = str.gsub(/^ {#{min_indent}}/, '')

    $log.info "Dropping a file to #{path}:"
    $log.info str

    @ssh.exec! "sudo mkdir -p \"$(dirname #{shellescape path})\""

    channel = @ssh.exec "sudo tee #{shellescape path} > /dev/null"
    channel.send_data str
    channel.eof!

    channel.wait
  end

  private
  def connect
    key = fetch_secret "#{self.class::KEY_NAME}.pem"
    begin
      @ssh = start_ssh key
      $log.info "Connected via SSH"
    rescue SystemCallError, Timeout::Error, Net::SSH::Disconnect => e
      # From the sample code: "port 22 might not be available immediately
      # after the instance finishes launching"
      $log.info "SSH unavailable. Trying again in 1s!"
      sleep 1
      retry
    end
  end
  def start_ssh key
    user = bootstrapped? ? 'root' : 'ubuntu'
    Net::SSH.start ip, user, :key_data => [key], :proxy => Gateway
  end
end
