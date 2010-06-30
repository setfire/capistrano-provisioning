module CapistranoProvisioning
  class User
    attr_accessor :name, :config
    attr_writer :groups, :key

    def initialize(opts = {})
      self.name = opts[:name]
      self.config = opts[:config]
      self.groups = opts[:groups].to_a || []
    end
        
    def install(opts = {})    
      abort "Aborting - Cannot install user #{self.name} as no server specified" unless opts[:server]
      abort "Aborting - Could not find key for #{self.name} at #{local_key_file_path}" unless key

      self.server = opts[:server]

      logger.debug "installing #{self.name} on #{self.server}"    

      self.create_account_on_server unless self.account_exists?
      self.create_ssh_config_directory
      self.update_authorized_keys
      self.set_ssh_config_permissions
      self.add_account_to_groups
    end
    
    def groups
      @groups.uniq
    end
    
    protected
    attr_accessor :server

    def account_exists?(server = self.server)
      begin
        if capture("id #{self.name}", :hosts => server)
          true
        else
          false
        end
      rescue
        # Must figure out a better way to capture that the command has failed
        false
      end
    end
    
    def key
      File.read(local_key_file_path) if File.exists?(local_key_file_path) 
    end

    def create_account_on_server(server = self.server)
      run "#{sudo} /usr/sbin/useradd -m #{name}", :pty => true, :hosts => server
    end
    
    def add_account_to_groups(server = self.server)
      self.groups.each do |group|
        run "#{sudo} /usr/sbin/usermod -a -G#{group} #{self.name}", :pty => true, :hosts => server
      end
    end
    
    def create_ssh_config_directory(server = self.server)
      # Actual dirt
      commands = <<-COMMANDS
        sudo su root -c 'if [ ! -d #{ssh_config_directory_path} ]; then
          sudo mkdir #{ssh_config_directory_path};
        fi';
      COMMANDS
      
      run commands, :pty => true, :hosts => server
    end
    
    def update_authorized_keys(server = self.server)
      tmp_location = "/tmp/#{self.name}.pub"
      put key, tmp_location, :hosts => server
      run "#{sudo} mv #{tmp_location} #{authorized_keys_file_path}", :pty => true, :hosts => server
    end
    
    def set_ssh_config_permissions(server = self.server)
      run "#{sudo} chown -R #{name} #{ssh_config_directory_path}", :pty => true, :hosts => server
      run "#{sudo} chmod -R 700 #{ssh_config_directory_path}", :pty => true, :hosts => server
    end
    
    def authorized_keys_file_path
      "/home/#{self.name}/.ssh/authorized_keys"
    end

    def home_directory_path
      "/home/#{self.name}/"
    end

    def ssh_config_directory_path
      "/home/#{self.name}/.ssh/"
    end
    
    def local_key_file_path
      "config/keys/#{self.name}.pub"
    end

    
    protected
    # This isn't the best way to get to the run/logger stuff in this class -
    # need to figure out a better way to do this, or a way to not need to.
    


    def put(data, path, options={})
      self.config.put(data, path, options)
    end

    def sudo(*parameters, &block)
      self.config.sudo(*parameters, &block)
    end

    def logger
      self.config.logger
    end
    
    def run(cmd, options={}, &block)
      self.config.run(cmd, options, &block)
    end

    def capture(command, options={})
      self.config.capture(command, options)
    end
  end
end