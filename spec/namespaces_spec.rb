require 'spec_helper'

describe Capistrano::Configuration do
  let(:config)      { Capistrano::Configuration.new }
  let(:namespace)   { Capistrano::Configuration::Namespaces::Namespace.new(:test_namespace, config) }
  
  context "default users" do
    it "should take a list of default users" do
      namespace.default_users 'sam', 'chris'
      namespace.default_users.length.should == 2
    end
  
    it "should take a name for the list of users" do
      namespace.default_users :admin, 'sam', 'chris'
      namespace.default_users.length.should == 2
    end
  
    it "should return an empty array if there are no default users" do
      namespace.default_users.length.should == 0
    end
  end

  describe "default user inheritance" do
    it "should inherit the users" do
      namespace.default_users 'chris', 'sam'
      namespace.namespace :nested do
        inherit_default_users
      end
    
      namespace.namespaces[:nested].default_users.length.should == 2
    end
    
    it "should inherit a named group of users" do
      namespace.default_users :admin, 'chris', 'sam'
      namespace.namespace :nested do
        inherit_default_users :admin
      end
    
      namespace.namespaces[:nested].default_users.length.should == 2
    end
    
    it "should inherit multiple named groups of users" do
      namespace.default_users :admin, 'chris', 'sam'
      namespace.default_users :developers, 'david', 'rob'
      
      namespace.namespace :nested do
        inherit_default_users :admin, :developers
      end
      
      namespace.namespaces[:nested].default_users.length.should == 4
    end
    
    it "should inherit the users' groups" do
      namespace.default_users 'sam', 'chris', :groups => 'test_group'
      namespace.namespace :nested do
        inherit_default_users
      end

      namespace.namespaces[:nested].default_users.each do |user|
        user.groups.should include('test_group')
      end
    end

    describe "additional groups" do
      
      it "should add one additional groups from a string" do
        namespace.default_users 'sam', 'chris', :groups => 'test_group'
        namespace.namespace :nested do
          inherit_default_users :additional_groups => 'test_group_2'
        end
        
        namespace.namespaces[:nested].default_users.each do |user|
          user.groups.should include('test_group')
          user.groups.should include('test_group_2')
        end        
      end

      it "should add any additional groups from an array" do
        namespace.default_users 'sam', 'chris', :groups => 'test_group'
        namespace.namespace :nested do
          inherit_default_users :additional_groups => ['test_group_2']
        end
      
        namespace.namespaces[:nested].default_users.each do |user|
          user.groups.should include('test_group')
          user.groups.should include('test_group_2')
        end
      end

      it "should not add additional groups to the original users" do
        config.namespace :test_namespace do
          default_users 'sam', 'chris', :groups => 'test_group'
          namespace :nested do
            inherit_default_users :additional_groups => 'test_group_2'
          end
        end

        config.namespaces[:test_namespace].default_users.each do |user|
          user.groups.should_not include('test_group_2')
        end
      end
    end
  end
  
  it "should create a cluster" do
    namespace.cluster :test_cluster
    namespace.clusters["test_namespace:test_cluster"].should be_a CapistranoProvisioning::Cluster
  end
  
  it "cluster should take a list of servers inline" do
    namespace.cluster :test_cluster, 'server_1', 'server_2'
    namespace.clusters["test_namespace:test_cluster"].servers.length.should == 2
  end

  context "within a cluster" do
    it "should take a list of users" do
      config.namespace :test_namespace do
        cluster :test_cluster do
          users 'sam', 'chris'
        end
      end
      
      users = config.namespaces[:test_namespace].clusters["test_namespace:test_cluster"].users
      user_names = users.collect(&:name)
      user_names.should include('sam','chris')
    end
    
    it "should inherit named users" do
      config.namespace :test_namespace do
        default_users :chaps, 'joe', 'bob'
        cluster :test_cluster do
          users :chaps
        end
      end
      
      users = config.namespaces[:test_namespace].clusters["test_namespace:test_cluster"].users
      users.each do |user|
        user.should be_a CapistranoProvisioning::User
      end

      user_names = users.collect(&:name)
      user_names.should include('joe', 'bob')    
      user_names.should_not include(:chaps)

    end
    
    it "should raise an error if passed named users that do not exist" do
      expect {
        config.namespace :test_namespace do
          default_users :chaps, 'joe', 'bob'
          cluster :test_cluster do
            users :non_existent_group
          end
        end
      }.to raise_error
    end
    
    it "should inherit named users mixed in with user names" do
      config.namespace :test_namespace do
        default_users :chaps, 'joe', 'bob'
        cluster :test_cluster do
          users :chaps, 'sam'
        end
      end
      
      user_names = config.namespaces[:test_namespace].clusters["test_namespace:test_cluster"].users.collect(&:name)
      user_names.should include('joe', 'bob', 'sam')
      user_names.should_not include(:chaps)
    end
  end

  describe "unique name" do
    it "should give a unique name on the top-tier namespace" do
      namespace.send(:unique_name).should == 'test_namespace'
    end
    
    it "should give a unique name on a second-tier namespace" do
      namespace.namespace :foo do; end
      namespace.namespaces[:foo].send(:unique_name).should == "test_namespace:foo"
    end
    
    it "should give a unique name on a third-tier namespace" do
      namespace.namespace :foo do
        namespace :bar do; end
      end
      namespace.namespaces[:foo].namespaces[:bar].send(:unique_name).should == "test_namespace:foo:bar"
    end
  end
  
  # Shouldn't necessarily be testing these protected methods, 
  # however it is complex and worthy of a spec, I feel.
  context "argument parsing" do
    it "should handle a named collection" do
      args = [:test, 'sam', 'bob']
      name, collection, options = namespace.send(:parse_name_collection_and_options_args, args)

      name.should == :test
      collection.should == ['sam', 'bob']
      options.should be_empty
    end
    
    it "should handle a named collection with options" do
      args = [:test, 'sam', 'bob', { :option => true } ]
      name, collection, options = namespace.send(:parse_name_collection_and_options_args, args)

      name.should == args.first
      collection.should == args.slice(1,2)
      options.should == args.last
    end
    
    it "should handle a collection with no options" do
      args = ['sam', 'bob']
      users, options = namespace.send(:parse_collection_and_options_args, args)

      users.should == args
      options.should be_empty      
    end
    
    it "should handle a collection with options" do
      args = ['sam', 'bob', { :option => true } ]
      users, options = namespace.send(:parse_collection_and_options_args, args)

      users.should == args.slice(0,2)
      options.should == args.last
    end
  end
end