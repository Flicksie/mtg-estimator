# frozen_string_literal: true

require 'json'
require 'fileutils'
require 'securerandom'
require 'rack'
require 'dotenv/load'

begin
  require_relative 'app/actions/api/scan'
  require_relative 'app/actions/api/search'
  require_relative 'app/actions/api/identify'
  require_relative 'app/actions/api/stats'
  require_relative 'app/actions/api/collection/list'
  require_relative 'app/actions/api/collection/export'
  require_relative 'app/actions/api/collection/add'
  require_relative 'app/actions/api/collection/clear'
  require_relative 'app/actions/api/collection/remove'
rescue LoadError => e
  puts "Error loading required files: #{e.message}"
  puts "Please ensure all service files are present in the application directory."
  exit 1
end

# Create uploads directory
FileUtils.mkdir_p('uploads')

# MTG Card Estimator - Pure Rack Web Application
class MTGEstimatorApp
  PUBLIC_FOLDER = 'frontend/dist'

  def initialize
    @scan_action = nil
    @search_action = nil
    @identify_action = nil
    @stats_action = nil
    @list_action = nil
    @export_action = nil
    @add_action = nil
    @clear_action = nil
    @remove_action = nil
  end

  def call(env)
    request = Rack::Request.new(env)
    
    # CORS headers with allowed origins
    allowed_origins = ['http://127.0.0.1:5004', 'http://localhost:5004']
    request_origin = request.get_header('HTTP_ORIGIN')
    allowed_origin = allowed_origins.include?(request_origin) ? request_origin : allowed_origins.first
    cors_headers = {
      'Access-Control-Allow-Origin' => allowed_origin,
      'Access-Control-Allow-Methods' => 'GET, POST, PUT, DELETE, OPTIONS',
      'Access-Control-Allow-Headers' => 'Content-Type, Accept',
      'Access-Control-Allow-Credentials' => 'true',
      'Vary' => 'Origin'
    }

    # Handle OPTIONS preflight
    if request.request_method == 'OPTIONS'
      return [200, cors_headers.merge('Allow' => 'GET, POST, PUT, DELETE, OPTIONS'), ['']]
    end

    # Route the request
    routed = route(request, env)

    # Expect [status, headers, body]
    status, headers, body = routed
    headers = (headers || {}).merge(cors_headers)
    [status, headers, body]
  end

  private

  def route(request, env)
    path = request.path_info
    method = request.request_method

    case [method, path]
    when ['GET', '/api/statsa']
      api_stats(env)
    when ['GET', '/api/collection/list']
      api_collection_list(env)
    when ['GET', '/api/collection/export']
      api_collection_export(env)
    when ['POST', '/api/search']
      api_search(env)
    when ['POST', '/api/scan']
      api_scan(env)
    when ['POST', '/api/identify']
      api_identify(env)
    when ['POST', '/api/collection/add']
      api_collection_add(env)
    when ['POST', '/api/collection/clear']
      api_collection_clear(env)
    else
      if method == 'DELETE' && path.start_with?('/api/collection/remove/')
        api_collection_remove(env)
      elsif path.start_with?('/api/')
        json_response(404, { error: 'Not found' })
      else
        serve_static(path)
      end
    end
  end

  def json_response(status, data)
    [status, { 'Content-Type' => 'application/json' }, [JSON.generate(data)]]
  end

  def api_scan(env)
    @scan_action ||= MTGEstimator::Actions::Api::Scan.new
    @scan_action.call(env)
  end

  def api_search(env)
    @search_action ||= MTGEstimator::Actions::Api::Search.new
    @search_action.call(env)
  end

  def api_identify(env)
    @identify_action ||= MTGEstimator::Actions::Api::Identify.new
    @identify_action.call(env)
  end

  def api_stats(env)
    @stats_action ||= MTGEstimator::Actions::Api::Stats.new
    @stats_action.call(env)
  end

  def api_collection_list(env)
    @list_action ||= MTGEstimator::Actions::Api::Collection::List.new
    @list_action.call(env)
  end

  def api_collection_export(env)
    @export_action ||= MTGEstimator::Actions::Api::Collection::Export.new
    @export_action.call(env)
  end

  def api_collection_add(env)
    @add_action ||= MTGEstimator::Actions::Api::Collection::Add.new
    @add_action.call(env)
  end

  def api_collection_clear(env)
    @clear_action ||= MTGEstimator::Actions::Api::Collection::Clear.new
    @clear_action.call(env)
  end

  def api_collection_remove(env)
    @remove_action ||= MTGEstimator::Actions::Api::Collection::Remove.new
    @remove_action.call(env)
  end

  def serve_static(path)
    file_path = File.join(PUBLIC_FOLDER, path)
    
    if File.exist?(file_path) && !File.directory?(file_path)
      mime_type = Rack::Mime.mime_type(File.extname(file_path))
      [200, { 'Content-Type' => mime_type }, [File.read(file_path)]]
    else
      index_path = File.join(PUBLIC_FOLDER, 'index.html')
      
      if File.exist?(index_path)
        [200, { 'Content-Type' => 'text/html' }, [File.read(index_path)]]
      else
        json_response(404, { error: 'Frontend not built. Run: cd frontend && npm run build' })
      end
    end
  end
end

# Run with: ruby app.rb
if __FILE__ == $PROGRAM_NAME
  require 'rack/handler/puma'
  puts "Starting MTG Estimator on http://0.0.0.0:5004"
  Rack::Handler::Puma.run(MTGEstimatorApp.new, Host: '0.0.0.0', Port: 5004)
end
