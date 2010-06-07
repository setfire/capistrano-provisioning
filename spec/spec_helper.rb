$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rubygems'

require 'spec'
require 'spec/autorun'

require 'capistrano'
require 'capistrano-provisioning'

Spec::Runner.configure do |config|
  
end
