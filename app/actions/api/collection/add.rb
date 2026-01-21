# frozen_string_literal: true

require_relative "../../../action"

module MTGEstimator
  module Actions
    module Api
      module Collection
        class Add < MTGEstimator::Action
          def handle(request, response)
            session_id, session = session_for(request)
            data = parse_json_body(request)
            
            session[:collection] ||= []

            card = {
              "id" => session[:collection].length + 1,
              "name" => data[:name],
              "set" => data[:set],
              "price" => data[:price] || 0,
              "image_uri" => data[:image_uri] || "",
              "added_date" => Time.now.iso8601
            }

            session[:collection] << card

            json_response(response, { success: true, card: card })
            response.set_cookie("session_id", { value: session_id, path: "/" })
          end
        end
      end
    end
  end
end
