module CapistranoProvisioning
  class Cluster
    attr_accessor :name, :servers, :bootstrap, :config
    attr_reader :users

    def initialize(name, opts = {})
      self.name = name    
      self.servers = opts[:servers]
      self.bootstrap = opts[:bootstrap]
      self.config = opts[:config]
            
      @users = []
      
      add_cluster_cap_task
    end
    
    def install_users
      if users.empty?
        @users = config.default_users
      end
      
      abort "No users found" unless self.users
      
      self.servers.each do |server|
        self.users.each do |user|
          user.install(:server => server)
        end
      end
    end
        
    def add_users(users, opts = {})
      @users += users.collect do |user|
        opts.merge!(:name => user, :config => self.config)
        CapistranoProvisioning::User.new(opts)         # This dependency should be injected, really.
      end
    end
    
    protected
    
    def add_cluster_cap_task
      cluster = self
      
      self.config.task(name.to_sym, :desc => "Set the current cluster to '#{name}'") do
        logger.info "Setting servers to #{cluster.servers.join(', ')}"
        set(:cluster, cluster)
      end
    end
  end
end