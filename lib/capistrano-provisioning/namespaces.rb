module Capistrano
  class Configuration
    module Namespaces
      attr_accessor :clusters

      def cluster(name, *servers, &block)
        self.clusters ||= {}
        self.clusters[name] = CapistranoProvisioning::Cluster.new(name, :config => self)

        self.clusters[name].servers = servers

        return unless block_given?

        @current_cluster = self.clusters[name]
        yield block
        @current_cluster = nil
      end

      def servers(*servers)
        @current_cluster.servers = servers
      end
      alias :server :servers
    
      def default_users(*args)
        return @users || [] if args.empty?

        users, options = parse_collection_and_options_args(args)

        @users ||= []
        @users += users.collect do |user|
          CapistranoProvisioning::User.new(options.merge!(:name => user, :config => self))            
        end
      end
      alias :default_user :default_users

      def inherit_default_users(options = {})
        @users ||= []
        
        parent_users = Marshal.load(Marshal.dump(self.parent.default_users)) # Need a deep copy, so clone or dup won't cut it
                
        if options[:additional_groups]
          parent_users.collect! do |user|
            user.groups += options[:additional_groups]
            user
          end
        end
        
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
end