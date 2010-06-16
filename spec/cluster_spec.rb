require 'spec_helper'

describe CapistranoProvisioning::Cluster do
  let(:config)          { Capistrano::Configuration.new }
  let(:user)            { CapistranoProvisioning::User.new }
  let(:namespace)       { Capistrano::Configuration::Namespaces::Namespace.new(:test_namespace, config) }
  let(:cluster)         { CapistranoProvisioning::Cluster.new(cluster_name, :servers => [], :config => config) }
  let(:cluster_name)    { '16nHElbcaf' }

  it "should add a capistrano task" do
    config_mock = mock(Capistrano::Configuration)  
    config_mock.should_receive(:task).with(cluster_name.to_sym, anything)
    CapistranoProvisioning::Cluster.new(cluster_name, :servers => [], :config => config_mock)
  end
  
  it "should return an empty of array of users when it has none" do
    cluster.users.should == []  
  end

  it "should add users from their names" do
    # For some reason `expect {}.to change` didn't work here - reverting to old style for now
    cluster.add_users ['test1', 'test2']
    cluster.users.length.should == 2    
  end
  
  it "should add users from objects" do
    cluster.add_users [user]
    cluster.users.length.should == 1
  end
  
  it "should have a unique name" do
    cluster = CapistranoProvisioning::Cluster.new(cluster_name, :servers => [], :config => namespace)
    cluster.unique_name.should == "test_namespace:#{cluster_name}"
  end

  it "should take a bootstrap block" do
    block = Proc.new {}
    cluster.bootstrap = block
    cluster.bootstrap.should == block
  end
  
  context "and users" do
    it "should use the namespace's default users if no users are specified" do
      namespace.default_users 'sam', 'david'
      cluster = CapistranoProvisioning::Cluster.new(cluster_name, :config => namespace)    

      cluster.users.collect(&:name).should include('sam', 'david')
    end

    it "should not add users to the namespace" do
      cluster = CapistranoProvisioning::Cluster.new(cluster_name, :config => namespace)    
      cluster.add_users ['bob', 'juan']
      
      namespace.default_users.should == []
    end
    
    it "should use the clusters's users if users are specified" do
      namespace.default_users 'sam', 'david'
      cluster = CapistranoProvisioning::Cluster.new(cluster_name, :config => namespace)    

      cluster.add_users ['bob', 'juan']

      user_names = cluster.users.collect(&:name)    
      user_names.should include('bob', 'juan')
      user_names.should_not include('sam', 'david')
    end
  
    it "should install users" do
      test_user, test_user_2 = user.dup, user.dup
      
      test_user.stub!(:key => 'test key')
      test_user.should_receive(:install)
      
      test_user_2.stub!(:key => 'test key 2')
      test_user_2.should_receive(:install)
      
      cluster.servers = 'host1.example.com'
      cluster.add_users [test_user, test_user_2]
      cluster.install_users
    end
  end
end