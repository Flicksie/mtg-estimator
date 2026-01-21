# frozen_string_literal: true

require "bundler/setup"
require "json"
require "rack/cors"

# Environment detection
CODESPACES = ENV['CODESPACES'] == 'true'
CODESPACE_NAME = ENV['GITHUB_CODESPACE_NAME']
ENVIRONMENT = ENV['RACK_ENV'] || 'development'

# Load services
require_relative "card_detector"
require_relative "card_recognizer"
require_relative "price_fetcher"
require_relative "ocr_service"

# Load the base action
require_relative "app/action"

# Load all actions
Dir[File.join(__dir__, "app/actions/**/*.rb")].sort.each { |f| require f }

# Log startup info in Codespaces
if CODESPACES
  puts "🚀 MTG Estimator running in GitHub Codespaces"
  puts "   Codespace: #{CODESPACE_NAME}"
  puts "   Environment: #{ENVIRONMENT}"
  puts "   Port: 5000"
end






module MTGEstimator
  class App
    def call(env)
      request = Rack::Request.new(env)
      
      # CORS preflight
      if request.request_method == "OPTIONS"
        return [200, cors_headers, [""]]
      end

      # Route to appropriate action
      action = route_action(request)
      action.call(env)
    end

    private

    def route_action(request)
      case request.path_info
      when /^\/api\/stats\/?$/
        MTGEstimator::Actions::Api::Stats.new
      when /^\/api\/search\/?$/
        MTGEstimator::Actions::Api::Search.new
      when /^\/api\/scan\/?$/
        MTGEstimator::Actions::Api::Scan.new
      when /^\/api\/identify\/?$/
        MTGEstimator::Actions::Api::Identify.new
      when /^\/api\/collection\/list\/?$/
        MTGEstimator::Actions::Api::Collection::List.new
      when /^\/api\/collection\/export\/?$/
        MTGEstimator::Actions::Api::Collection::Export.new
      when /^\/api\/collection\/add\/?$/
        MTGEstimator::Actions::Api::Collection::Add.new
      when /^\/api\/collection\/clear\/?$/
        MTGEstimator::Actions::Api::Collection::Clear.new
      when /^\/api\/collection\/remove\/(\d+)\/?$/
        MTGEstimator::Actions::Api::Collection::Remove.new
      else
        # Static files and SPA fallback
        MTGEstimator::Actions::Static::Serve.new
      end
    end

    def cors_headers
      {
        "Access-Control-Allow-Origin" => "*",
        "Access-Control-Allow-Methods" => "GET, POST, PUT, DELETE, OPTIONS",
        "Access-Control-Allow-Headers" => "Content-Type, Accept"
      }
    end
  end
end

# Build Rack app with middleware
app = Rack::Builder.new do
  use Rack::Cors do
    allow do
      origins "*"
      resource "*", headers: :any, methods: [:get, :post, :put, :patch, :delete, :options]
    end
  end

  run MTGEstimator::App.new
end

run app
