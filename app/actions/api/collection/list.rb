# frozen_string_literal: true

require_relative "../../../action"

module MTGEstimator
  module Actions
    module Api
      module Collection
        class List < MTGEstimator::Action
          def handle(request, response)
            session_id, session = session_for(request)
            
            json_response(response, session[:collection] || [])
            response.set_cookie("session_id", { value: session_id, path: "/" })
          end
        end
      end
    end
  end
end
