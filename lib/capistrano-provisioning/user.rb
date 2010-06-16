module CapistranoProvisioning
  class User
    attr_accessor :name, :config, :key
    attr_writer :groups

    def initialize(opts = {})
      self.name = opts[:name]
      self.config = opts[:config]
      self.groups = opts[:groups].to_a || []
    end
        
    def install(opts = {})    
      abort "Aborting - Cannot install user #{self.name} as no server specified" unless opts[:server]
      abort "Aborting - Could not find key for #{self.name} at #{local_key_file_path}" unless File.exists?(local_key_file_path)

      logger.debug "installing #{self.name} on #{opts[:server]}"    

      self.key = File.read(local_key_file_path)
      
      self.create_account_on_server(opts[:server]) unless self.account_exists?(opts[:server])
      self.create_ssh_config_directory(opts[:server])
      self.update_authorized_keys(opts[:server])
      self.add_account_to_groups(opts[:server])
    end
    
    def groups
      @groups.uniq
    end
    
    protected
    def account_exists?(server)
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

    def create_account_on_server(server)
      run "#{sudo} /usr/sbin/useradd -m #{name}", :pty => true, :hosts => server
    end
    
    def add_account_to_groups(server)
      self.groups.each do |group|
        run "#{sudo} /usr/sbin/usermod -a -G#{group} #{self.name}", :pty => true, :hosts => server
      end
    end
    
    def create_ssh_config_directory(server)
      # Actual dirt
      commands = <<-COMMANDS
        sudo su root -c 'if [ ! -d #{ssh_config_directory_path} ]; then
          sudo mkdir #{ssh_config_directory_path};
        fi';
        #{sudo} chown #{name} #{ssh_config_directory_path} &&
        #{sudo} chmod 700 #{ssh_config_directory_path}
      COMMANDS
      
      run commands, :pty => true, :hosts => server
    end
    
    def update_authorized_keys(server)
      commands = <<-COMMANDS
        #{sudo} touch #{authorized_keys_file_path} &&
        echo '#{key}' | sudo tee #{authorized_keys_file_path}
      COMMANDS
      run commands, :pty => true, :hosts => server
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