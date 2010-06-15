module CapistranoProvisioning
  module NamespaceExtension

    attr_accessor :clusters
    def cluster(name, *servers, &block)
      # A note on initialising. At the moment I can't figure out how to initialize stuff from this module, 
      # hence the untidy defaulting here.
      self.clusters ||= {}
      self.create_namespace_all_task

      self.clusters[name] = CapistranoProvisioning::Cluster.new(name, :config => self)
      self.clusters[name].servers = servers

      return unless block_given?

      @current_cluster = @clusters[name]
      yield block
      @current_cluster = nil
    end

    def servers(*servers)
      @current_cluster.servers = servers
    end
    alias :server :servers

    def default_users(*args)
      return @users || [] if args.empty?

      name, users, options = parse_name_collection_and_options_args(args)
      new_users = users.collect do |user|
        CapistranoProvisioning::User.new(options.merge!(:name => user, :config => self))            
      end
      
      if name
        @user_groups ||= {}
        @user_groups[name] = new_users
      end

      @users ||= []      
      @users += new_users
    end
    alias :default_user :default_users
    
    def default_user_group(group)
      @user_groups[group]
    end

    def inherit_default_users(*args)
      groups, options = parse_collection_and_options_args(args)
      
      options[:additional_groups] = options[:additional_groups].to_a
      parent_users = clone_parent_users(groups)
        
      if options[:additional_groups]
        parent_users.collect! do |user|
          user.groups += options[:additional_groups]
          user
        end
      end

      @users ||= []
      @users += parent_users
    end
    alias :inherit_default_user :inherit_default_users

    def users(*args)
      users, options = parse_collection_and_options_args(args)
      @current_cluster.add_users(users, options)
    end
    alias :user :users

    def bootstrap(&block)
      @current_cluster.bootstrap = block
    end

    protected
    def create_namespace_all_task
      return if self.tasks.keys.include?(:all)

      task(:all, :desc => "Set the current clusters '#{name}'") do
        logger.info "Setting clusters to #{self.clusters.keys.join(',')}"
        set(:clusters, self.clusters.values)
      end
    end

    def clone_parent_users(groups = [])
      unless groups.empty?
        users = groups.collect { |group| self.parent.default_user_group(group) }.flatten
      else
        users = self.parent.default_users
      end

      Marshal.load(Marshal.dump(users)) # Need a deep copy, so clone or dup won't cut it
    end
    
    def parse_name_collection_and_options_args(args)
      args = args.dup
      
      name = (args.first.is_a? Symbol) ? args.shift : nil
      collection, options = parse_collection_and_options_args(args)
      return name, collection, options
    end

    def parse_collection_and_options_args(args)
      args = args.dup

      if args.last.is_a? Hash
        options = args.pop
      else
        options = {}
      end

      collection = args
      return collection, options
    end
  end
end

Capistrano::Configuration::Namespaces::Namespace.send(:include, CapistranoProvisioning::NamespaceExtension)