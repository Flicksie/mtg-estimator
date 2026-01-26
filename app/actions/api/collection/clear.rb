# frozen_string_literal: true

require_relative "../../../action"

module MTGEstimator
  module Actions
    module Api
      module Collection
        class Clear < MTGEstimator::Action
          def handle(request, response)
            session_id, session = session_for(request)
            session[:collection] = []

            json_response(response, { success: true })
            response.set_cookie("session_id", { value: session_id, path: "/" })
          end
        end
      end
    end
  end
end
