require 'rubygems'
require 'bundler/setup'

require 'aws-sdk'
require 'net/ssh'
require 'yaml'

# Set up a logger
$log = Logger.new(STDERR)

require 'lib/util'
require 'lib/secrets'

# Initialze AWS
AWS.config(YAML.load(fetch_secret 'config.yml'))

$EC2 = AWS::EC2.new.regions[:'us-east-1']

require 'lib/ssh'
require 'lib/servers/base'
