require 'spec_helper'

# TODO: Not sure how to test this yet

describe "Recipes" do  
  it "should create an :all task which loads all servers in that namespace"

  context "cluster definition" do
    it "should take a list of servers without a block"
    
    it "should create a task to set the servers"
    
    it "should create a task to bootstrap the servers"
    
    it "should create a task to install users on the servers"
    
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