def analyze ec2, acw, logger

  res = ec2.describe_instances :filters => {

      "instance-type" => "m1.small", 
      "instance-lifecycle" => "spot", 
      "instance-state-name" => "running"

  }

  res.each do |i|

    id = i[:aws_instance_id]
    logger.info "#{id} launched at #{i[:aws_launch_time]}"

    stats = acw.get_metric_statistics( :dimentions => {
      
      "InstanceId" => id, 
      "Service" => "EC2", 
      "Namespace" => "AWS"

      },
      
      :start_time => (Time.now.utc - 60*60))

    cpu = stats[:datapoints].sort {|x,y| x[:timestamp] <=> y[:timestamp]}

    if cpu.length < 2 
      logger.info "started less then 15 minutes ago, skipping"
      next
    end
    
    load = cpu.last[:average]
    logger.info "#{id} load average: #{load}"

    if load < 5 
      logger.info "#{id} Terminating"
      logger.info ec2.terminate_instances(id)
    end

  end

end
