require 'spec_helper'

class CapConfig
  include Capistrano::Configuration::Namespaces
  include CapistranoProvisioning::NamespaceExtension
end

describe Capistrano::Configuration::Namespaces do
  let(:config)    { CapConfig.new }
  
  context "default users" do
    it "should take a list of default users" do
      config.default_users 'sam', 'chris'
      config.default_users.length.should == 2
    end
  
    it "should take a name for the list of users" do
      config.default_users :admin, 'sam', 'chris'
      config.default_users.length.should == 2
    end
  
    it "should return an empty array if there are no default users" do
      config.default_users.should == []
    end
  end

  describe "default user inheritance" do
    it "should inherit the users" do
      config.default_users 'sam', 'chris'
      config.namespace :nested do
        inherit_default_users
      end      
    
      config.namespaces[:nested].default_users.length.should == 2
    end
    
    it "should inherit a named group of users" do
      config.default_users :admin, 'chris', 'sam'
      config.namespace :nested do
        inherit_default_users :admin
      end
    
      config.namespaces[:nested].default_users.length.should == 2
    end
    
    it "should inherit the users' groups" do
      config.default_users 'sam', 'chris', :groups => 'test_group'
      config.namespace :nested do
        inherit_default_users
      end

      config.namespaces[:nested].default_users.each do |user|
        user.groups.should include('test_group')
      end
    end

    describe "additional groups" do
      before(:each) do
        config.default_users 'sam', 'chris', :groups => 'test_group'
      end
      
      it "should add one additional groups from a string" do
        config.namespace :nested do
          inherit_default_users :additional_groups => 'test_group_2'
        end        

        config.namespaces[:nested].default_users.each do |user|
          user.groups.should include('test_group')
          user.groups.should include('test_group_2')
        end        
      end

      it "should add any additional groups from an array" do
        config.namespace :nested do
          inherit_default_users :additional_groups => ['test_group_2']
        end        

        config.namespaces[:nested].default_users.each do |user|
          user.groups.should include('test_group')
          user.groups.should include('test_group_2')
        end
      end

      it "should not add additional groups to the original users" do
        config.namespace :nested do
          inherit_default_users :additional_groups => ['test_group_2']
        end        

        config.default_users.each do |user|
          user.groups.should_not include('test_group_2')
        end
      end
    end
  end

  it "should create a cluster" do
    config.cluster :test_cluster
    config.clusters[:test_cluster].should be_a CapistranoProvisioning::Cluster
  end
  
  it "cluster should take a list of servers inline" do
    config.cluster :test_cluster, 'server_1', 'server_2'
    config.clusters[:test_cluster].servers.length.should == 2
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
            
    it "should take a list of servers" do
      pending()
      
      # Current errors
      config.cluster :test_cluster do
        servers 'server_1', 'server_2'
      end
      config.clusters[:test_cluster].servers.length.should == 2
    end
    
    it "should take a bootstrap block"    
  end
  
  # Shouldn't necessarily be testing this protected method, 
  # however it is complex and worthy of a spec, I feel.
  context "argument parsing" do
    it "should handle a named collection" do
      args = [:test, 'sam', 'bob']
      name, collection, options = config.send(:parse_name_collection_and_options_args, args)

      name.should == :test
      collection.should == ['sam', 'bob']
      options.should be_empty
    end
    
    it "should handle a named collection with options" do
      args = [:test, 'sam', 'bob', { :option => true } ]
      name, collection, options = config.send(:parse_name_collection_and_options_args, args)

      name.should == args.first
      collection.should == args.slice(1,2)
      options.should == args.last
    end
    
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