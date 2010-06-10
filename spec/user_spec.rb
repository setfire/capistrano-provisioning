require 'spec_helper'

class CapConfig
  include Capistrano::Configuration::Namespaces
end

describe CapistranoProvisioning::User do
  it "should have a user in a group"

  let(:username)  { 'z6MeKbLOXPqi5P' }
  let(:server)    { 'test1.example.com' }
  let(:config)    { mock(CapConfig) }
  let(:user)      { CapistranoProvisioning::User.new(:name => username, :server => server, :config => config) }

  describe "install" do
    it "should require a server" do
      expect { user.install }.to raise_error(SystemExit)
    end

    it "should error if the user's ssh key cannot be loaded" do
      expect { user.install(:server => server) }.to raise_error(SystemExit)
    end  
  end

  it "should create an account on the server" do      
    config.should_receive(:run).with(/#{username}/, anything()).once
    config.should_receive(:sudo).with(no_args()).once
    
    user.send(:create_account_on_server)
  end
  
  it "should load the user's ssh key"
  
  it "should check if a user's account exists"
  
  it "should create the ssh directory on the server"
  
  it "should update the user's key on the server"

  describe "and groups" do
    it "should return an empty array if there are no groups" do
      user.groups.should == []
    end
    
    it "should add a user to one group" do
      user = CapistranoProvisioning::User.new(:name => username, :server => server, :config => config, :groups => 'test_group')
      user.groups.should include("test_group")
    end
    
    it "should add a user to an array of groups" do
      user = CapistranoProvisioning::User.new(:name => username, :server => server, :config => config, :groups => ['test_group', 'test_group_2'])
      user.groups.should include("test_group")
      user.groups.should include("test_group_2")
    end
  end


end