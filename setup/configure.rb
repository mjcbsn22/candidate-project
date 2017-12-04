# Load Config
App = JSON.parse(File.read('./config/config.json'), symbolize_names: true)

# Enable cross origin
enable :cross_origin
set :allow_origin, :any
set :allow_methods, [:get, :post, :put, :delete, :options]

# Helper for before
set(:accepted_verbs) do |*verbs|
  condition do 
    verbs.any?{|v| v == request.request_method }
  end 
end

set(:not_accepted_verbs) do |*verbs|
  condition do 
    !verbs.any?{|v| v == request.request_method }
  end 
end

# Load Environment
Envyable.load('./config/environment.yml') if @Env == 'development'
