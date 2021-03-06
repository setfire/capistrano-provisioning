module CapistranoProvisioning
  class Cluster
    attr_accessor :name, :servers, :bootstrap, :config

    def initialize(name, opts = {})
      self.name = name    
      self.servers = opts[:servers]
      self.bootstrap = opts[:bootstrap]
      self.config = opts[:config]
            
      @users = []
      
      add_cluster_cap_task
    end
    
    def install_users(specified_users = [])
      ensure_users
      
      self.servers.each do |server|
        self.users.each do |user|
          next unless specified_users.empty? or specified_users.include?(user.name)
          user.install(:server => server)
        end
      end
    end
    
    def preview_users(specified_users = [])
      ensure_users

      self.servers.each do |server|
        puts "#{server}: "
        self.users.each do |user|
          next unless specified_users.empty? or specified_users.include?(user.name)
          groups = user.groups.empty? ? '' : "(#{user.groups.join(', ')})"
          puts "\t#{user.name} #{groups}"
        end
      end
    end
    
    def ensure_users
      if @users.empty? and config.respond_to?(:default_users)
        @users = config.default_users
      end
      
      abort "No users found" unless @users
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
    
    def users
      ensure_users
      @users
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