describe "monitor" do

  require  "./core.rb"

  let (:ec2) {double("ec2")}
  let (:acw) {double("acw")}
  let (:logger) {double("logger")}

  before (:each) do
    logger.should_receive :info
  end
  
  it "should check running spot instances" do
    
    ec2.should_receive(:describe_instances).with( :filters => {
     
      "instance-type" => "m1.small", 
      "instance-lifecycle" => "spot", 
      "instance-state-name" => "running"

    }){[]}       

    analyze ec2, acw, logger

  end

  it "should check load average" do
    
    ec2.should_receive( :describe_instances ) {[]}
    acw.should_receive :get_metric_statistics 

    analyze ec2, acw, logger 

  end
  it "should do nothing with loaded instances"
  it "should terminate resting instance"
  it "should not terminate resting instance running less than an hour"

end
