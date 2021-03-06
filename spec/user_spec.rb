require 'spec_helper'

describe CapistranoProvisioning::User do
  let(:username)      { 'z6MeKbLOXPqi5P' }
  let(:server)        { 'test1.example.com' }
  let(:config_mock)   { mock(Capistrano::Configuration) }
  let(:user)          { CapistranoProvisioning::User.new(:name => username, :server => server, :config => config_mock) }

  describe "install" do
    it "should require a server" do
      expect { user.install }.to raise_error(SystemExit)
    end

    it "should error if the user's ssh key cannot be loaded" do
      expect { user.install(:server => server) }.to raise_error(SystemExit)
    end  
  end
  
  it "should create an account on the server" do      
    config_mock.should_receive(:run).with(/#{username}/, anything()).once
    config_mock.should_receive(:sudo).with(no_args()).once
    
    user.send(:create_account_on_server, server)
  end
  
  describe "and groups" do
    it "should return an empty array if there are no groups" do
      user.groups.should == []
    end
    
    it "should de-duplify groups" do
      user.groups = ['test_group', 'test_group2', 'test_group']
      user.groups.should == ['test_group','test_group2']
    end
    
    it "should add a user to one group" do
      user = CapistranoProvisioning::User.new(:name => username, :server => server, :config => config_mock, :groups => 'test_group')
      user.groups.should include("test_group")
    end
    
    it "should add a user to an array of groups" do
      user = CapistranoProvisioning::User.new(:name => username, :server => server, :config => config_mock, :groups => ['test_group', 'test_group_2'])
      user.groups.should include("test_group")
      user.groups.should include("test_group_2")
    end
  end
end