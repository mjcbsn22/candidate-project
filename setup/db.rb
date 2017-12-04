# Require libraries
require 'sinatra/activerecord'
require 'yaml'

# Establish ActiveRecord connection
config = YAML.load_file('config/database.yml')
if @Env == 'production'
  config['production']['host'] = ENV['DB_HOST']
  config['production']['database'] = ENV['DB_NAME']
  config['production']['username'] = ENV['DB_USER']
  config['production']['password'] = ENV['DB_PASS']
end
ActiveRecord::Base.configurations = config

if ENV.has_key?('DATABASE_URL')
  ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])
else
  ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations[@Env])
end

originalLogger = ActiveRecord::Base.logger
ActiveRecord::Base.logger = nil