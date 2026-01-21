# frozen_string_literal: true

require_relative "../../../action"

module MTGEstimator
  module Actions
    module Api
      module Collection
        class Remove < MTGEstimator::Action
          def handle(request, response)
            session_id, session = session_for(request)
            
            # Extract ID from path
            match = request.path_info.match(/\/api\/collection\/remove\/(\d+)/)
            card_id = match ? match[1].to_i : nil

            unless card_id
              return json_response(response, { error: "Invalid card ID" }, status: 400)
            end

            unless session[:collection]
              return json_response(response, { error: "Collection not found" }, status: 404)
            end

            session[:collection].reject! { |c| c["id"] == card_id }

            json_response(response, { success: true })
            response.set_cookie("session_id", { value: session_id, path: "/" })
          end
        end
      end
    end
  end
end
