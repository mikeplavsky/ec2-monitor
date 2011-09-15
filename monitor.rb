#!/usr/bin/ruby

require "right_aws"
require "yaml"

path = File.join File.dirname( __FILE__ )

require 'logger'

`[ ! -x ./log ] && mkdir ./log`
@logger = Logger.new File.join(path,"log","log.txt"), 'daily' 
@logger.level = Logger::DEBUG

@cfg = YAML.load( File.read( File.join path, "config.yml" ))  

params = @cfg["access_key_id"], @cfg["secret_access_key"] 

ec2 = RightAws::Ec2.new *params, {:logger => @logger}
acw = RightAws::AcwInterface.new *params, {:logger => @logger}

require "./core.rb"

while true

  analyze ec2, acw, @logger
  sleep 60*5

end
