# frozen_string_literal: true

require 'sinatra/base'
require 'sinatra/json'
require 'json'
require 'fileutils'
require 'securerandom'

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

# MTG Card Estimator - Web Application
# Sinatra web interface for card detection, identification, and pricing
class MTGEstimatorApp < Sinatra::Base
  configure do
    enable :sessions
    set :session_secret, ENV.fetch('SECRET_KEY', SecureRandom.hex(64))
    set :port, 5000
    set :bind, '0.0.0.0'
    set :public_folder, 'frontend/dist'
    set :views, 'views'
    
    # Create uploads directory
    FileUtils.mkdir_p('uploads')
  end

  # CORS configuration for development
  before do
    if settings.development?
      headers['Access-Control-Allow-Origin'] = 'http://localhost:5173'
      headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS'
      headers['Access-Control-Allow-Headers'] = 'Content-Type, Accept'
      headers['Access-Control-Allow-Credentials'] = 'true'
    end
  end

  # Handle CORS preflight requests
  options '*' do
    response.headers['Allow'] = 'GET, POST, PUT, DELETE, OPTIONS'
    response.headers['Access-Control-Allow-Headers'] = 'Content-Type, Accept'
    200
  end

  # Initialize services
  def card_detector
    @card_detector ||= CardDetector.new
  end

  def card_recognizer
    @card_recognizer ||= CardRecognizer.new
  end

  def price_fetcher
    @price_fetcher ||= PriceFetcher.new
  end

  def ocr_service
    @ocr_service ||= OCRService.new
  end

  # API endpoint - Get stats for dashboard
  get '/api/stats' do
    content_type :json
    
    collection = session[:collection] || []
    total_cards = collection.length
    total_value = collection.sum { |card| card['price'] || 0 }

    json({
      'total_cards' => total_cards,
      'total_value' => total_value,
      'ocr_available' => ocr_service.available?
    })
  end

  # API endpoint - Get collection list
  get '/api/collection/list' do
    content_type :json
    
    collection = session[:collection] || []
    json(collection)
  end

  # API endpoint for card search
  post '/api/search' do
    content_type :json
    
    data = JSON.parse(request.body.read)
    query = data['query']&.strip

    if query.nil? || query.empty?
      status 400
      return json({ error: 'Please provide a card name to search' })
    end

    # Search for the card
    card_data = card_recognizer.search_card_by_name(query)

    unless card_data
      status 404
      return json({ error: 'Card not found' })
    end

    # Get price information
    prices = price_fetcher.get_card_price(card_data)

    result = {
      'name' => card_data['name'],
      'set' => card_data['set_name'],
      'set_code' => card_data['set'],
      'mana_cost' => card_data['mana_cost'] || '',
      'type_line' => card_data['type_line'] || '',
      'oracle_text' => card_data['oracle_text'] || '',
      'prices' => prices || {},
      'image_uri' => card_data.dig('image_uris', 'normal') || '',
      'scryfall_uri' => card_data['scryfall_uri'] || ''
    }

    json result
  end

  # API endpoint for card scanning and identification
  post '/api/scan' do
    content_type :json

    unless params[:image]
      status 400
      return json({ error: 'No image file provided' })
    end

    begin
      file = params[:image]
      filename = "#{Time.now.strftime('%Y%m%d_%H%M%S')}_#{file[:filename]}"
      filepath = File.join('uploads', filename)

      # Save the uploaded file
      File.open(filepath, 'wb') do |f|
        f.write(file[:tempfile].read)
      end

      # Detect cards in the image
      card_images = card_detector.detect_cards(filepath)
      num_detected = card_images.length

      results = {
        'num_detected' => num_detected,
        'cards' => [],
        'filename' => filename
      }

      # Try to identify cards using OCR
      if ocr_service.available? && num_detected > 0
        card_images.each_with_index do |_card_image, i|
          # Try OCR on card
          card_name = ocr_service.extract_card_name_from_region(filepath)

          card_info = {
            'index' => i,
            'detected' => true,
            'name' => nil,
            'price' => nil,
            'set' => nil,
            'image_uri' => nil
          }

          if card_name
            # Search for the card
            card_data = card_recognizer.search_card_by_name(card_name)

            if card_data
              prices = price_fetcher.get_card_price(card_data)
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

      json results
    rescue StandardError => e
      status 500
      json({ error: "Error processing image: #{e.message}" })
    end
  end

  # API endpoint for manual card identification
  post '/api/identify' do
    content_type :json

    data = JSON.parse(request.body.read)
    card_names = data['card_names'] || []

    if card_names.empty?
      status 400
      return json({ error: 'No card names provided' })
    end

    results = []
    total_value = 0

    card_names.each do |card_name|
      card_data = card_recognizer.search_card_by_name(card_name)

      if card_data
        prices = price_fetcher.get_card_price(card_data)
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

    json({
      'cards' => results,
      'total_value' => total_value.round(2)
    })
  end

  # Add a card to the collection
  post '/api/collection/add' do
    content_type :json

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

    json({ success: true, card: card })
  end

  # Remove a card from the collection
  delete '/api/collection/remove/:card_id' do
    content_type :json

    card_id = params[:card_id].to_i
    unless session[:collection]
      status 404
      return json({ error: 'Collection not found' })
    end

    session[:collection].reject! { |c| c['id'] == card_id }

    json({ success: true })
  end

  # Export collection as JSON
  get '/api/collection/export' do
    content_type :json

    collection = session[:collection] || []

    export_data = {
      'exported_date' => Time.now.iso8601,
      'total_cards' => collection.length,
      'total_value' => collection.sum { |card| card['price'] || 0 },
      'cards' => collection
    }

    json export_data
  end

  # Clear the entire collection
  post '/api/collection/clear' do
    content_type :json

    session[:collection] = []

    json({ success: true })
  end

  # Error handlers
  error 413 do
    json({ error: 'File is too large. Maximum size is 16MB' })
  end

  # SPA fallback - serve index.html for all non-API routes
  get '*' do
    # Check if the file exists in public folder first
    file_path = File.join(settings.public_folder, request.path_info)
    
    if File.exist?(file_path) && !File.directory?(file_path)
      send_file file_path
    else
      # Serve the SPA index.html
      index_path = File.join(settings.public_folder, 'index.html')
      
      if File.exist?(index_path)
        send_file index_path
      else
        # Fallback for development when frontend isn't built yet
        halt 404, json({ error: 'Frontend not built. Run: cd frontend && npm run build' })
      end
    end
  end

  # Run the app if this file is executed directly
  run! if app_file == $PROGRAM_NAME
end
