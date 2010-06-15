require 'spec_helper'

class CapConfig
  include Capistrano::Configuration::Namespaces
end

describe CapistranoProvisioning::Cluster do
  let(:config_mock)     { mock(CapConfig) }
  let(:cluster)         { CapistranoProvisioning::Cluster.new(cluster_name, :servers => [], :config => CapConfig.new) }
  let(:cluster_name)    { '16nHElbcaf' }

  it "should add a capistrano task" do
    config_mock.should_receive(:task).with(cluster_name.to_sym, anything)
    CapistranoProvisioning::Cluster.new(cluster_name, :servers => [], :config => config_mock)
  end
  
  it "should add users" do
    # For some reason `expect {}.to change` didn't work here - reverting to old style for now
    
    cluster.users.should == []
    cluster.add_users(['test1', 'test2'])
    cluster.users.length.should == 2    
  end
  
  it "should have a unique name"
  
  context "installing users" do
    it "should use the namespace's default users if no users are specified"
    
    it "should use the namespace's users if users are specified"
  
    it "should install users"
  end
end