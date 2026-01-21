# frozen_string_literal: true

require "hanami/router"

module MTGEstimator
  Routes = Hanami::Router.new do
    # API routes
    get "/api/stats", to: MTGEstimator::Actions::Api::Stats.new
    post "/api/search", to: MTGEstimator::Actions::Api::Search.new
    post "/api/scan", to: MTGEstimator::Actions::Api::Scan.new
    post "/api/identify", to: MTGEstimator::Actions::Api::Identify.new
    
    get "/api/collection/list", to: MTGEstimator::Actions::Api::Collection::List.new
    get "/api/collection/export", to: MTGEstimator::Actions::Api::Collection::Export.new
    post "/api/collection/add", to: MTGEstimator::Actions::Api::Collection::Add.new
    post "/api/collection/clear", to: MTGEstimator::Actions::Api::Collection::Clear.new
    delete "/api/collection/remove/:id", to: MTGEstimator::Actions::Api::Collection::Remove.new

    # Static files and SPA fallback (catch-all with named splat)
    get "/*path", to: MTGEstimator::Actions::Static::Serve.new
  end
end
