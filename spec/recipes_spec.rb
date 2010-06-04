require 'spec_helper'

class CapConfig
  include Capistrano::Configuration::Namespaces
end

describe "Recipes" do  
  it "should create an :all task which loads all servers in that namespace"

  context "cluster definition" do
    it "should take a list of servers without a block"
    
    it "should create a task to set the servers"
    
    it "should create a task to bootstrap the servers" do
      CapConfig.should_receive(:task).with(:run_bootstrap)
    end
    
    it "should create a task to install users on the servers" do
      CapConfig.should_receive(:task).with(:install_users)
    end
    
    context "servers" do
      it "should take a list of servers"
  
      it "should correctly set the current servers"

      it "should raise an error if no servers are specifed"
    end
    
    context "users" do
      it "should be passed into the cluster definition"
      
      it "should have the option of belonging to a group"
    end
  end
end