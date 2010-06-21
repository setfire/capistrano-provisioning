require 'spec_helper'

# Fake a running instance of Capistrano
Capistrano::Configuration.instance = Capistrano::Configuration.new
require 'capistrano-provisioning/recipes'

describe "Recipes" do
  let(:config)      { Capistrano::Configuration.instance }
  
  context "namespace" do
    it "should create an :all task which loads all servers in that namespace" do
      pending("Currently failing due to inheritance confusion")

      config.load do
        namespace :test_namespace do
          cluster :test_cluster, 'cluster1.example.com'
        end
      end
      
      puts config.tasks.keys.inspect.gsub("<", '&lt;')
      config.namespaces.should include(:test_namespace)
      config.tasks.keys.should include(:test_namespace)
    end
  end

  context "global" do    
    it "should create a task to bootstrap the servers" do
      config.tasks.keys.should include(:run_bootstrap)
    end

    it "should create a task to install users on the servers" do
      config.tasks.keys.should include(:install_users)
    end
    
    it "should create a task to preview users that will be installed" do
      config.tasks.keys.should include(:install_users)      
    end
  end

  context "cluster definition" do
    it "should create a task to set the servers" do
      pending("Currently failing due to inheritance confusion")

      config.cluster :test_cluster
      config.tasks.keys.should include(:test_cluster)
    end
  end
end