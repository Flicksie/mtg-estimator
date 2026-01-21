# frozen_string_literal: true

require_relative "../../action"

module MTGEstimator
  module Actions
    module Static
      class Serve < MTGEstimator::Action
        PUBLIC_FOLDER = "frontend/dist"

        def handle(request, response)
          path = request.path
          file_path = File.join(PUBLIC_FOLDER, path)

          if File.exist?(file_path) && !File.directory?(file_path)
            serve_file(response, file_path)
          else
            # SPA fallback
            index_path = File.join(PUBLIC_FOLDER, "index.html")
            
            if File.exist?(index_path)
              serve_file(response, index_path)
            else
              json_response(response, { error: "Frontend not built. Run: cd frontend && npm run build" }, status: 404)
            end
          end
        end

        private

        def serve_file(response, file_path)
          response.status = 200
          response["Content-Type"] = mime_type(file_path)
          content = File.read(file_path, encoding: 'UTF-8') rescue File.read(file_path)
          response.write(content)
        end

        def mime_type(path)
          case File.extname(path).downcase
          when ".html" then "text/html"
          when ".css" then "text/css"
          when ".js" then "application/javascript"
          when ".json" then "application/json"
          when ".png" then "image/png"
          when ".jpg", ".jpeg" then "image/jpeg"
          when ".gif" then "image/gif"
          when ".svg" then "image/svg+xml"
          when ".ico" then "image/x-icon"
          when ".woff" then "font/woff"
          when ".woff2" then "font/woff2"
          else "application/octet-stream"
          end
        end
      end
    end
  end
end
