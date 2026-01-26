# frozen_string_literal: true

require_relative "../../action"
require_relative "../../services/card_recognizer"
require_relative "../../services/price_fetcher"

module MTGEstimator
  module Actions
    module Api
      class Identify < MTGEstimator::Action
        def initialize
          super
          @card_recognizer = CardRecognizer.new
          @price_fetcher = PriceFetcher.new
        end

        def handle(request, response)
          data = parse_json_body(request)
          card_names = data[:card_names] || []

          if card_names.empty?
            return json_response(response, { error: "No card names provided" }, status: 400)
          end

          results = []
          total_value = 0

          card_names.each do |card_name|
            card_data = @card_recognizer.search_card_by_name(card_name)

            if card_data
              prices = @price_fetcher.get_card_price(card_data)
              price_usd = prices ? prices["usd"] || 0 : 0

              card_info = {
                "name" => card_data["name"],
                "price" => price_usd,
                "set" => card_data["set_name"],
                "set_code" => card_data["set"],
                "image_uri" => card_data.dig("image_uris", "normal") || "",
                "found" => true
              }

              total_value += price_usd
            else
              card_info = {
                "name" => card_name,
                "found" => false,
                "error" => "Card not found"
              }
            end

            results << card_info
          end

          json_response(response, {
            "cards" => results,
            "total_value" => total_value.round(2)
          })
        end
      end
    end
  end
end
