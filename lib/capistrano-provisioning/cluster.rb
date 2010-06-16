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
      ensure_users      

      self.servers.each do |server|
        self.users.each do |user|
          user.install(:server => server)
        end
      end
    end
    
    def preview_users
      ensure_users

      self.servers.each do |server|
        puts "#{server}: "
        self.users.each do |user|
          groups = user.groups.empty? ? '' : "(#{user.groups.join(', ')})"
          puts "\t#{user.name} #{groups}"
        end
      end
    end
    
    def ensure_users
      if users.empty?
        @users = config.default_users
      end
      
      abort "No users found" unless self.users
    end
        
    def add_users(users, opts = {})
      @users += users.collect do |user|
        if user.is_a? CapistranoProvisioning::User
          user.config = self.config
          user
        else
          opts.merge!(:name => user, :config => self.config)
          CapistranoProvisioning::User.new(opts)         # This dependency should be injected, really.
        end
      end
    end
    
    def unique_name
      self.config.send(:unique_name) + ":" + self.name.to_s
    end

    protected
    
    def add_cluster_cap_task
      cluster = self
      
      self.config.task(name.to_sym, :desc => "Set the current cluster to '#{name}'") do
        logger.info "Setting servers to #{cluster.servers.join(', ')}"
        current_cluster = fetch(:clusters, [])
        set(:clusters, current_cluster.push(cluster))
      end
    end
  end
end