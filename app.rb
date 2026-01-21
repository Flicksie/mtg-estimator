# frozen_string_literal: true

require 'json'
require 'fileutils'
require 'securerandom'
require 'rack'

begin
  require_relative 'card_detector'
  require_relative 'card_recognizer'
  require_relative 'price_fetcher'
  require_relative 'ocr_service'
rescue LoadError => e
  puts "Error loading required files: #{e.message}"
  puts "Please ensure all service files are present in the application directory."
  exit 1
end

# Create uploads directory
FileUtils.mkdir_p('uploads')

# MTG Card Estimator - Pure Rack Web Application
class MTGEstimatorApp
  PUBLIC_FOLDER = 'frontend/dist'

  def initialize
    @sessions = {}
    @card_detector = CardDetector.new
    @card_recognizer = CardRecognizer.new
    @price_fetcher = PriceFetcher.new
    @ocr_service = OCRService.new
  end

  def call(env)
    request = Rack::Request.new(env)
    
    # Get or create session
    session_id = request.cookies['session_id'] || SecureRandom.hex(32)
    @sessions[session_id] ||= { collection: [] }
    session = @sessions[session_id]

    # CORS headers
    cors_headers = {
      'Access-Control-Allow-Origin' => '*',
      'Access-Control-Allow-Methods' => 'GET, POST, PUT, DELETE, OPTIONS',
      'Access-Control-Allow-Headers' => 'Content-Type, Accept',
      'Access-Control-Allow-Credentials' => 'true'
    }

    # Handle OPTIONS preflight
    if request.request_method == 'OPTIONS'
      return [200, cors_headers.merge('Allow' => 'GET, POST, PUT, DELETE, OPTIONS'), ['']]
    end

    # Route the request
    status, headers, body = route(request, session)

    # Set session cookie
    response = Rack::Response.new(body, status, cors_headers.merge(headers))
    response.set_cookie('session_id', { value: session_id, path: '/' })
    response.finish
  end

  private

  def route(request, session)
    path = request.path_info
    method = request.request_method

    case [method, path]
    when ['GET', '/api/stats']
      api_stats(session)
    when ['GET', '/api/collection/list']
      api_collection_list(session)
    when ['GET', '/api/collection/export']
      api_collection_export(session)
    when ['POST', '/api/search']
      api_search(request)
    when ['POST', '/api/scan']
      api_scan(request)
    when ['POST', '/api/identify']
      api_identify(request)
    when ['POST', '/api/collection/add']
      api_collection_add(request, session)
    when ['POST', '/api/collection/clear']
      api_collection_clear(session)
    else
      if method == 'DELETE' && path.start_with?('/api/collection/remove/')
        card_id = path.split('/').last.to_i
        api_collection_remove(card_id, session)
      elsif path.start_with?('/api/')
        json_response(404, { error: 'Not found' })
      else
        serve_static(path)
      end
    end
  end

  def json_response(status, data)
    [status, { 'Content-Type' => 'application/json' }, [JSON.generate(data)]]
  end

  def api_stats(session)
    collection = session[:collection] || []
    total_cards = collection.length
    total_value = collection.sum { |card| card['price'] || 0 }

    json_response(200, {
      'total_cards' => total_cards,
      'total_value' => total_value,
      'ocr_available' => @ocr_service.available?
    })
  end

  def api_collection_list(session)
    json_response(200, session[:collection] || [])
  end

  def api_collection_export(session)
    collection = session[:collection] || []
    json_response(200, {
      'exported_date' => Time.now.iso8601,
      'total_cards' => collection.length,
      'total_value' => collection.sum { |card| card['price'] || 0 },
      'cards' => collection
    })
  end

  def api_search(request)
    data = JSON.parse(request.body.read)
    query = data['query']&.strip

    if query.nil? || query.empty?
      return json_response(400, { error: 'Please provide a card name to search' })
    end

    card_data = @card_recognizer.search_card_by_name(query)

    unless card_data
      return json_response(404, { error: 'Card not found' })
    end

    prices = @price_fetcher.get_card_price(card_data)

    json_response(200, {
      'name' => card_data['name'],
      'set' => card_data['set_name'],
      'set_code' => card_data['set'],
      'mana_cost' => card_data['mana_cost'] || '',
      'type_line' => card_data['type_line'] || '',
      'oracle_text' => card_data['oracle_text'] || '',
      'prices' => prices || {},
      'image_uri' => card_data.dig('image_uris', 'normal') || '',
      'scryfall_uri' => card_data['scryfall_uri'] || ''
    })
  end

  def api_scan(request)
    params = Rack::Multipart.parse_multipart(request.env)
    
    unless params && params['image']
      return json_response(400, { error: 'No image file provided' })
    end

    begin
      file = params['image']
      filename = "#{Time.now.strftime('%Y%m%d_%H%M%S')}_#{file[:filename]}"
      filepath = File.join('uploads', filename)

      File.open(filepath, 'wb') do |f|
        f.write(file[:tempfile].read)
      end

      card_images = @card_detector.detect_cards(filepath)
      num_detected = card_images.length

      results = {
        'num_detected' => num_detected,
        'cards' => [],
        'filename' => filename
      }

      if @ocr_service.available? && num_detected > 0
        card_images.each_with_index do |_card_image, i|
          card_name = @ocr_service.extract_card_name_from_region(filepath)

          card_info = {
            'index' => i,
            'detected' => true,
            'name' => nil,
            'price' => nil,
            'set' => nil,
            'image_uri' => nil
          }

          if card_name
            card_data = @card_recognizer.search_card_by_name(card_name)

            if card_data
              prices = @price_fetcher.get_card_price(card_data)
              price_usd = prices ? prices['usd'] || 0 : 0

              card_info.merge!({
                'name' => card_data['name'],
                'price' => price_usd,
                'set' => card_data['set_name'],
                'set_code' => card_data['set'],
                'image_uri' => card_data.dig('image_uris', 'normal') || ''
              })
            end
          end

          results['cards'] << card_info
        end
      else
        results['message'] = 'Cards detected but OCR not available. Please provide card names manually.'
      end

      json_response(200, results)
    rescue StandardError => e
      json_response(500, { error: "Error processing image: #{e.message}" })
    end
  end

  def api_identify(request)
    data = JSON.parse(request.body.read)
    card_names = data['card_names'] || []

    if card_names.empty?
      return json_response(400, { error: 'No card names provided' })
    end

    results = []
    total_value = 0

    card_names.each do |card_name|
      card_data = @card_recognizer.search_card_by_name(card_name)

      if card_data
        prices = @price_fetcher.get_card_price(card_data)
        price_usd = prices ? prices['usd'] || 0 : 0

        card_info = {
          'name' => card_data['name'],
          'price' => price_usd,
          'set' => card_data['set_name'],
          'set_code' => card_data['set'],
          'image_uri' => card_data.dig('image_uris', 'normal') || '',
          'found' => true
        }

        total_value += price_usd
      else
        card_info = {
          'name' => card_name,
          'found' => false,
          'error' => 'Card not found'
        }
      end

      results << card_info
    end

    json_response(200, {
      'cards' => results,
      'total_value' => total_value.round(2)
    })
  end

  def api_collection_add(request, session)
    data = JSON.parse(request.body.read)
    session[:collection] ||= []

    card = {
      'id' => session[:collection].length + 1,
      'name' => data['name'],
      'set' => data['set'],
      'price' => data['price'] || 0,
      'image_uri' => data['image_uri'] || '',
      'added_date' => Time.now.iso8601
    }

    session[:collection] << card

    json_response(200, { success: true, card: card })
  end

  def api_collection_remove(card_id, session)
    unless session[:collection]
      return json_response(404, { error: 'Collection not found' })
    end

    session[:collection].reject! { |c| c['id'] == card_id }

    json_response(200, { success: true })
  end

  def api_collection_clear(session)
    session[:collection] = []
    json_response(200, { success: true })
  end

  def serve_static(path)
    file_path = File.join(PUBLIC_FOLDER, path)
    
    if File.exist?(file_path) && !File.directory?(file_path)
      mime_type = Rack::Mime.mime_type(File.extname(file_path))
      [200, { 'Content-Type' => mime_type }, [File.read(file_path)]]
    else
      index_path = File.join(PUBLIC_FOLDER, 'index.html')
      
      if File.exist?(index_path)
        [200, { 'Content-Type' => 'text/html' }, [File.read(index_path)]]
      else
        json_response(404, { error: 'Frontend not built. Run: cd frontend && npm run build' })
      end
    end
  end
end

# Run with: ruby app.rb
if __FILE__ == $PROGRAM_NAME
  require 'rack/handler/puma'
  puts "Starting MTG Estimator on http://0.0.0.0:5000"
  Rack::Handler::Puma.run(MTGEstimatorApp.new, Host: '0.0.0.0', Port: 5000)
end
