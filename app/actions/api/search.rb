# frozen_string_literal: true

require_relative "../../action"
require_relative "../../../services/card_recognizer"
require_relative "../../../services/price_fetcher"

module MTGEstimator
  module Actions
    module Api
      class Search < MTGEstimator::Action
        def initialize
          super
          @card_recognizer = CardRecognizer.new
          @price_fetcher = PriceFetcher.new
        end

        def handle(request, response)
          data = parse_json_body(request)
          query = data[:query]&.strip

          if query.nil? || query.empty?
            return json_response(response, { error: "Please provide a card name to search" }, status: 400)
          end

          card_data = @card_recognizer.search_card_by_name(query)

          unless card_data
            return json_response(response, { error: "Card not found" }, status: 404)
          end

          prices = @price_fetcher.get_card_price(card_data)

          json_response(response, {
            "name" => card_data["name"],
            "set" => card_data["set_name"],
            "set_code" => card_data["set"],
            "mana_cost" => card_data["mana_cost"] || "",
            "type_line" => card_data["type_line"] || "",
            "oracle_text" => card_data["oracle_text"] || "",
            "prices" => prices || {},
            "image_uri" => card_data.dig("image_uris", "normal") || "",
            "scryfall_uri" => card_data["scryfall_uri"] || ""
          })
        end
      end
    end
  end
end
