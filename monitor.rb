#!/usr/bin/ruby

require "right_aws"
require "yaml"

path = File.join File.dirname( __FILE__ )

require 'logger'

`mkdir ./log`
@logger = Logger.new File.join(path,"log","log.txt"), 'daily' 
@logger.level = Logger::DEBUG

def info str 
  @logger.info str
end

@cfg = YAML.load( File.read( File.join path, "config.yml" ))  

create = ->(t) { t.new @cfg["access_key_id"], @cfg["secret_access_key"], :logger => @logger }  

acw = create.( RightAws::AcwInterface )
ec2 = create.( RightAws::Ec2 )

require "./core.rb"

while true

  analyze ec2, acw, @logger
  sleep 60*5

end
