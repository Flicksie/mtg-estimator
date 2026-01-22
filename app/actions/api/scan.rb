# frozen_string_literal: true

require_relative "../../action"
require_relative "../../services/card_recognizer"
require_relative "../../services/price_fetcher"
require_relative "../../services/ocr_service"
require "digest"

module MTGEstimator
  module Actions
    module Api
      class Scan < MTGEstimator::Action
        def initialize
          super
          @card_recognizer = CardRecognizer.new
          @price_fetcher = PriceFetcher.new
          @ocr_service = OCRService.new
        end

        def handle(request, response)
          file_data = request.params["image"]
          custom_gemini_key = request.params["gemini_key"]
          
          unless file_data && file_data[:tempfile]
            return json_response(response, { error: "No image file provided" }, status: 400)
          end

          begin
            # Use custom key if provided, otherwise use server's key
            @ocr_service = OCRService.new(custom_gemini_key) if custom_gemini_key
            
            # Read file content and calculate hash
            file_content = file_data[:tempfile].read
            file_hash = Digest::SHA256.hexdigest(file_content)
            
            # Check if file with this hash already exists
            existing_file = find_existing_file_by_hash(file_hash)
            
            if existing_file
              filepath = File.join("uploads", existing_file)
              filename = existing_file
            else
              # Save new file with hash prefix
              filename = "#{file_hash[0..7]}_#{Time.now.strftime('%Y%m%d_%H%M%S')}_#{file_data[:filename]}"
              filepath = File.join("uploads", filename)
              
              File.open(filepath, "wb") do |f|
                f.write(file_content)
              end
            end

            results = {
              "num_detected" => 0,
              "cards" => [],
              "filename" => filename,
              "duplicate" => !existing_file.nil?
            }

            if @ocr_service.available?
              # Gemini handles multi-card detection directly
              raw_names = @ocr_service.extract_card_name_from_region(filepath)
              card_names = Array(raw_names).map(&:to_s).map(&:strip).reject(&:empty?)
              results["num_detected"] = card_names.length

              # Create an entry for each detected card
              (card_names.empty? ? [nil] : card_names).each_with_index do |card_name, name_idx|
                card_info = {
                  "index" => 0,
                  "alt_index" => name_idx,
                  "detected" => true,
                  "name" => nil,
                  "price" => nil,
                  "set" => nil,
                  "image_uri" => nil
                }

                if card_name
                  card_data = @card_recognizer.search_card_by_name(card_name)

                  if card_data
                    prices = @price_fetcher.get_card_price(card_data)
                    price_usd = prices ? prices["usd"] || 0 : 0

                    card_info.merge!({
                      "name" => card_data["name"],
                      "price" => price_usd,
                      "set" => card_data["set_name"],
                      "set_code" => card_data["set"],
                      "image_uri" => card_data.dig("image_uris", "normal") || ""
                    })
                  end
                end

                results["cards"] << card_info
              end
            else
              results["message"] = "OCR not available. Please provide card names manually."
            end

            json_response(response, results)
          rescue StandardError => e
            json_response(response, { error: "Error processing image: #{e.message}" }, status: 500)
          end
        end

        private

        # Find existing file by hash prefix
        def find_existing_file_by_hash(file_hash)
          hash_prefix = file_hash[0..7]
          Dir.glob(File.join("uploads", "#{hash_prefix}_*")).first&.then { |path| File.basename(path) }
        end
      end
    end
  end
end
