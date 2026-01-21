# Puma configuration file

# Bind to all interfaces for Codespaces/dev containers
bind 'tcp://0.0.0.0:5000'

# Development settings
environment ENV.fetch('RACK_ENV', 'development')

# Load the app directly, bypassing rackup's host authorization
app do |env|
  # Rewrite host header to pass any checks
  env['HTTP_HOST'] = 'localhost:5000'
  env['SERVER_NAME'] = 'localhost'
  
  require_relative '../app'
  MTGEstimatorApp.call(env)
end
