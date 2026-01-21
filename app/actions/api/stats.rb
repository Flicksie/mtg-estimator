# frozen_string_literal: true

require_relative "../../action"
require_relative "../../../card_recognizer"
require_relative "../../../price_fetcher"
require_relative "../../../ocr_service"

module MTGEstimator
  module Actions
    module Api
      class Stats < MTGEstimator::Action
        def initialize
          super
          @ocr_service = OCRService.new
        end

        def handle(request, response)
          session_id, session = session_for(request)
          collection = session[:collection] || []
          
          json_response(response, {
            "total_cards" => collection.length,
            "total_value" => collection.sum { |card| card["price"] || 0 },
            "ocr_available" => @ocr_service.available?
          })
          
          response.set_cookie("session_id", { value: session_id, path: "/" })
        end
      end
    end
  end
end
