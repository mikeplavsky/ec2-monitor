#!/usr/bin/ruby

require "right_aws"
require "yaml"
require "optparse"

options = {}

parser = OptionParser.new do |opts|

  opts.banner = "run.rb [options]"

  options[:kill] = false

  opts.on '-t', 'terminate resting spot instances' do 
    options[:kill] = true
  end

  opts.on '-h', '--help' do
    puts opts
    exit
  end

end

parser.parse!

path = File.join File.dirname( __FILE__ )
$LOAD_PATH.push path

require 'logger'

`[ ! -x ./log ] && mkdir ./log`
@logger = Logger.new File.join(".","log","ec2-monitor.log"), 'daily' 
@logger.level = Logger::DEBUG

@cfg = YAML.load( File.read( "config.yml" ))   

params = @cfg["access_key_id"], @cfg["secret_access_key"] 

ec2 = RightAws::Ec2.new *params, {:logger => @logger}
acw = RightAws::AcwInterface.new *params, {:logger => @logger}

require "core"
analyze( ec2, acw, @logger, options[:kill] )
