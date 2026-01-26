# Puma configuration file

# Bind to all interfaces for Codespaces/dev containers
bind 'tcp://0.0.0.0:5000'

# Development settings
environment ENV.fetch('RACK_ENV', 'development')

# Number of threads
threads 1, 6

# Workers (set to 0 for development)
workers 0
