# frozen_string_literal: true

require "json"
require "securerandom"

module MTGEstimator
  class Action
    # Shared sessions store (in-memory for simplicity)
    @@sessions = {}

    def self.sessions
      @@sessions
    end

    def initialize
      # Subclasses can override this
    end

    # Rack interface
    def call(env)
      request = Rack::Request.new(env)
      response = Rack::Response.new
      
      # Set CORS headers
      response["Access-Control-Allow-Origin"] = "*"
      response["Access-Control-Allow-Methods"] = "GET, POST, PUT, DELETE, OPTIONS"
      response["Access-Control-Allow-Headers"] = "Content-Type, Accept"
      
      handle(request, response)
      
      response.finish
    end

    # Override in subclasses
    def handle(request, response)
      raise NotImplementedError
    end

    protected

    def session_for(request)
      session_id = request.cookies["session_id"] || SecureRandom.hex(32)
      @@sessions[session_id] ||= { collection: [] }
      [session_id, @@sessions[session_id]]
    end

    def json_response(response, data, status: 200)
      response.status = status
      response["Content-Type"] = "application/json"
      response.write(JSON.generate(data))
    end

    def parse_json_body(request)
      body = request.body.read
      request.body.rewind if request.body.respond_to?(:rewind)
      body.empty? ? {} : JSON.parse(body, symbolize_names: true)
    rescue JSON::ParserError
      {}
    end
  end
end
