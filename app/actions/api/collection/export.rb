# frozen_string_literal: true

require_relative "../../../action"

module MTGEstimator
  module Actions
    module Api
      module Collection
        class Export < MTGEstimator::Action
          def handle(request, response)
            session_id, session = session_for(request)
            collection = session[:collection] || []

            json_response(response, {
              "exported_date" => Time.now.iso8601,
              "total_cards" => collection.length,
              "total_value" => collection.sum { |card| card["price"] || 0 },
              "cards" => collection
            })
            
            response.set_cookie("session_id", { value: session_id, path: "/" })
          end
        end
      end
    end
  end
end
