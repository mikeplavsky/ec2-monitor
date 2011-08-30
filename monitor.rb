#!/usr/bin/ruby

require "right_aws"
require "yaml"

path = File.join File.dirname( __FILE__ )

require 'logger'

@logger = Logger.new File.join( path,"log.txt" ), 'daily' 
@logger.level = Logger::DEBUG

def info str 
  @logger.info str
end

cfg = YAML.load( File.read( File.join path, "config.yml" ))  

acw = RightAws::AcwInterface.new cfg["access_key_id"], cfg["secret_access_key"], :logger => @logger
ec2 = RightAws::Ec2.new cfg["access_key_id"], cfg["secret_access_key"], :logger => @logger

while true

  res = ec2.describe_instances :filters => {

      "instance-type" => "m1.small", 
      "instance-lifecycle" => "spot", 
      "instance-state-name" => "running"

  }

  res.each do |i|

    id = i[:aws_instance_id]
    info "#{id} launched at #{i[:aws_launch_time]}"

    stats = acw.get_metric_statistics( :dimentions => {
      
      "InstanceId"=>id, 
      "Service" => "EC2", 
      "Namespace" => "AWS"

      },
      
      :start_time => (Time.now.utc - 60*60))

    cpu = stats[:datapoints].sort {|x,y| x[:timestamp] <=> y[:timestamp]}

    if cpu.length < 2 
      info "started less then 15 minutes ago, skipping"
      next
    end
    
    load = cpu.last[:average]
    info "#{id} load average: #{load}"

    if load < 5 
      info "#{id} Terminating"
      info ec2.terminate_instances(id)
    end

  end

  sleep 60*5

end
