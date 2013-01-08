require 'thread'
require 'socket'

class SSHocket
  def self.open channel, host, port
    @channel = channel
    @recv_buffer = ""
    @lock = Mutex.new

    @channel.exec "nc #{shellescape host} #{shellescape port}" do |ch, ok|
      unless ok
        $log.error "Error SSHocketing to #{host}:#{port}"
        raise Net::SSH::Disconnect
      end

      ch.on_data do |data|
        @lock.synchronize do
          @recv_buffer << data
        end
      end
    end
  end

  def closed?
    @channel.closing? || !@channel.active?
  end

  def close
    @channel.close
  end

  def send data, flags
    @channel.send_data data
  end

  def recv size
    return nil if closed?
    @lock.synchronize do
      @recv_buffer.slice 0..size
    end
  end
end

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

class Net::SSH::Connection::Session
  def stream cmd
    exec! cmd do |ch, stream, data|
      fd = stream == :stderr ? $stderr : $stdout
      fd.print data
      fd.flush
    end
  end
end
