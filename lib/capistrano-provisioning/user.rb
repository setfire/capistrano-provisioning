module CapistranoProvisioning
  class User
    attr_accessor :name, :config, :key, :groups

    def initialize(opts = {})
      self.name = opts[:name]
      self.config = opts[:config]
      self.groups = opts[:groups] || []
    end
        
    def install(opts = {})    
      abort "Aborting - Cannot install user #{self.name} as no server specified" unless opts[:server]
      abort "Aborting - Could not find key for #{self.name} at #{local_key_file_path}" unless File.exists?(local_key_file_path)

      logger.debug "installing #{self.name} on #{opts[:server]}"    

      self.key = File.read(local_key_file_path)
      
      self.create_account_on_server unless self.account_exists?
      self.create_ssh_config_directory
      self.update_authorized_keys
      self.add_account_to_groups
    end
    
    protected
    def account_exists?
      begin
        if capture("id #{self.name}")
          true
        else
          false
        end
      rescue
        # Must figure out a better way to capture that the command has failed
        false
      end
    end

    def create_account_on_server
      run "#{sudo} /usr/sbin/useradd -m #{name}", :pty => true
    end
    
    def add_account_to_groups
      self.groups.each do |group|
        run "#{sudo} /usr/sbin/usermod -a -G#{group} #{self.name}", :pty => true
      end
    end
    
    def create_ssh_config_directory
      # Actual dirt
      commands = <<-COMMANDS
        sudo su root -c 'if [ ! -d #{ssh_config_directory_path} ]; then
          sudo mkdir #{ssh_config_directory_path};
        fi';
        #{sudo} chown #{name} #{ssh_config_directory_path} &&
        #{sudo} chmod 700 #{ssh_config_directory_path}
      COMMANDS
      
      run commands, :pty => true
    end
    
    def update_authorized_keys
      commands = <<-COMMANDS
        #{sudo} touch #{authorized_keys_file_path} &&
        echo '#{key}' | sudo tee #{authorized_keys_file_path}
      COMMANDS
      run commands, :pty => true
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