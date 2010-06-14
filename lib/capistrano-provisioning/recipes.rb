require 'capistrano-provisioning'

Capistrano::Configuration.instance(:must_exist).load do
  on :before, "cluster_ensure", :only => ["run_bootstrap", "install_users"]
  desc "[Internal] Ensures that a cluster has been specified"
  task :cluster_ensure do
    @clusters = fetch(:clusters, false)
    unless @clusters
      abort("No cluster specified - please use one of '#{self.clusters.keys.join(', ')}'")
    end
  end
  
  # Will set  up a 'cluster' role, that will be set by the current provision.
  set :servers, []
  role(:cluster) {
    fetch(:clusters).collect(&:servers).flatten
  }

  desc "Runs the bootstrap comamnds on the cluster"
  task :run_bootstrap do
    @clusters.each do |cluster|
      abort "No bootstrap block given for '#{cluster.name}' cluster" unless cluster.bootstrap
      cluster.bootstrap.call
    end
  end
  
  desc "Installs the specified users on the cluster"
  task :install_users do
    @clusters.each do |cluster|
      cluster.install_users
    end
  end
end