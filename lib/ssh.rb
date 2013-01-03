SSH_GATEWAY = Net::SSH::Proxy::Command.new("ssh gateway.#{DOMAIN} nc %h %p")

class Net::SSH::Connection::Session
  def stream cmd
    exec! cmd do |ch, stream, data|
      fd = stream == :stderr ? $stderr : $stdout
      fd.print data
      fd.flush
    end
  end
end
