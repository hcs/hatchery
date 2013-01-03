class Net::SSH::Connection::Session
  def stream cmd
    exec! cmd do |ch, stream, data|
      puts data
    end
  end
end
