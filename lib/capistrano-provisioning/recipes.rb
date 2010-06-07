require 'capistrano-provisioning'


Capistrano::Configuration.instance(:must_exist).load do
  on :before, "cluster_ensure", :only => ["run_bootstrap", "install_users"]
  desc "[Internal] Ensures that a cluster has been specified"
  task :cluster_ensure do
    @cluster = fetch(:cluster, false)
    unless @cluster
      abort("No cluster specified - please use one of '#{self.clusters.keys.join(', ')}'")
    end
  end
  
  # Will set  up a 'cluster' role, that will be set by the current provision.
  set :servers, []
  role(:cluster) {
    fetch(:cluster).servers
  }

  desc "Runs the bootstrap comamnds on the cluster"
  task :run_bootstrap do
    abort "No bootstrap block given for '#{@cluster.name}' cluster" unless @cluster.bootstrap
    @cluster.bootstrap.call
  end
  
  desc "Installs the specified users on the cluster"
  task :install_users do
    @cluster.install_users
  end
end