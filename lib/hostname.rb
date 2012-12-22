class Hostname
  # Hosts are distributed round-robin amongst the following subnets. We're using
  # subnets as a proxy for availability zones, so try to cycle through AZs in a
  # reasonable way. We also assume all subnets are /24s, since it means we can
  # do string concatination instead of proper CIDR block parsing.
  SUBNETS = [
    {:subnet => 'subnet-05b4666f', :az => 'us-east-1b', :prefix => '10.0.2.'},
    {:subnet => 'subnet-a2b567c8', :az => 'us-east-1c', :prefix => '10.0.3.'},
    {:subnet => 'subnet-25ba684f', :az => 'us-east-1d', :prefix => '10.0.4.'},
  ]

  def initialize host
    # [env-]servertype123[.foobar.com]
    match = host.match /^(?:([a-z]+)-)?([a-z]+)([0-9]+)(?:\.(.*))?$/i
    raise "Invalid hostname" if match.nil?

    @env = match[1] && match[1].downcase
    @type = match[2].downcase
    @number = match[3].to_i
    @domain = match[4].nil? ? 'hcs.harvard.edu' : match[4].downcase
  end

  def server_class
    require 'lib/servers/' + @type
    Kernel.const_get(@type.capitalize + 'Server')
  end

  def subnet
    subnet = SUBNETS[(@number - 1) % SUBNETS.length]
    subnet[:subnet]
  end

  def ip
    subnet = SUBNETS[(@number - 1) % SUBNETS.length]
    ip = server_class::IP_RANGE.to_a[@number / SUBNETS.length]
    raise "Maximum number of servers in class reached" if ip.nil?
    subnet[:prefix] + ip.to_s
  end

  def shortname
    env_part = @env.nil? ? '' : "#{@env}-"
    "#{env_part}#{@type}#{@number}"
  end
  def to_s
    "#{shortname}.#{@domain}"
  end
  alias_method :inspect, :to_s

end
