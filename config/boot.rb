ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)
 
require 'bundler/setup' # Set up gems listed in the Gemfile.

require 'active_record'
require 'sidekiq-scheduler'

$: << './lib'
require 'db_connect'

# Require workers
Dir['./app/workers/*.rb'].each {|file| require file }

# Require models
Dir['./app/models/*.rb'].each {|file| require file }
