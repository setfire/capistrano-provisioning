require 'spec_helper'

class CapConfig
  include Capistrano::Configuration::Namespaces
end

describe Capistrano::Configuration::Namespaces do
  let(:config)    { CapConfig.new }
  
  it "should create a cluster"
  
  it "cluster should take a list of servers inline"  
  
  it "should take a list of default users" do
    config.default_users 'sam', 'chris'
    config.default_users.length.should == 2
  end
  
  context "within a cluster" do
    it "should take a list of users"
    
    it "should not add users to the namespace" do
      pending()

      # Currently errors
      expect {
        config.cluster :test_cluster do
          users 'sam', 'chris'
        end
      }.to change(config.users, :length).by(0)
    end
    
    context "inheriting users" do
      it "should inherit its parent's default users"
    
      it "should add its parent's users to any additional groups"
    end
        
    it "should take a list of servers"
    
    it "should take a bootstrap block"
  end
  
  context "argument parsing" do
    it "should handle a collection with no options" do
      args = ['sam', 'bob']
      users, options = config.send(:parse_collection_and_options_args, args)

      users.should == args
      options.should be_empty      
    end
    
    it "should handle a collection with options" do
      args = ['sam', 'bob', { :option => true } ]
      users, options = config.send(:parse_collection_and_options_args, args)

      users.should == args.slice(0,2)
      options.should == args.last
    end
  end
end