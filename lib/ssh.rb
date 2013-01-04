require 'net/ssh/gateway'

class Gateway
  @@gateway = nil
  def self.open target
    if @@gateway.nil?
      require 'lib/servers/gateway'

      # TODO: hcs.harvard.edu
      host = 'gateway.hcs.so'
      key = fetch_secret "#{GatewayServer::KEY_NAME}.pem"

      $log.info "Establishing connection to gateway server #{host}"
      @@gateway = Net::SSH::Gateway.new host, 'ubuntu', :key_data => [key]
    end

    @@gateway.open target, 22
  end

  def self.close port
    @@gateway.close port
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
