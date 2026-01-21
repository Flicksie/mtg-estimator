#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require_relative 'card_detector'
require_relative 'card_recognizer'
require_relative 'price_fetcher'

# MTGEstimator - Main application class for MTG card estimation
class MTGEstimator
  def initialize
    @detector = CardDetector.new
    @recognizer = CardRecognizer.new
    @price_fetcher = PriceFetcher.new
  end

  # Process an image to detect and estimate card values
  # @param image_path [String] Path to the image file
  # @param card_names [Array<String>, nil] Optional list of card names
  # @return [Hash] Results dictionary
  def process_image(image_path, card_names = nil)
    results = {
      'image_path' => image_path,
      'cards_detected' => 0,
      'cards' => [],
      'total_value' => 0.0
    }

    begin
      puts "Processing image: #{image_path}"
      card_images = @detector.detect_cards(image_path)
      results['cards_detected'] = card_images.length
      puts "Detected #{card_images.length} card(s) in the image"

      if card_names && !card_names.empty?
        puts "\nUsing provided card names: #{card_names.join(', ')}"
        price_results = @price_fetcher.estimate_total_value(card_names)
        results['cards'] = price_results['cards']
        results['total_value'] = price_results['total_usd']
      else
        puts "\nNote: Automatic card recognition from images requires OCR integration."
        puts "Please provide card names manually using the --cards option."
      end

      results
    rescue StandardError => e
      puts "Error processing image: #{e.message}"
      results['error'] = e.message
      results
    end
  end

  # Estimate the value of cards by name
  # @param card_names [Array<String>] List of card names
  # @return [Hash] Pricing results dictionary
  def estimate_cards(card_names)
    puts "Estimating value for #{card_names.length} card(s)..."
    @price_fetcher.estimate_total_value(card_names)
  end

  # Search for a card by name
  # @param query [String] Card name or search query
  # @return [Hash] Card information
  def search_card(query)
    puts "Searching for: #{query}"
    card_data = @recognizer.search_card_by_name(query)

    if card_data
      prices = @price_fetcher.get_card_price(card_data)
      {
        'name' => card_data['name'],
        'set' => card_data['set_name'],
        'set_code' => card_data['set'],
        'prices' => prices,
        'scryfall_uri' => card_data['scryfall_uri']
      }
    else
      { 'error' => 'Card not found' }
    end
  end
end

# Main CLI entry point
def main
  options = {}
  command = nil

  parser = OptionParser.new do |opts|
    opts.banner = "Usage: ruby mtg_estimator.rb [command] [options]"
    
    opts.separator ""
    opts.separator "Commands:"
    opts.separator "  image PATH [--cards CARD1 CARD2 ...]  Process an image with cards"
    opts.separator "  estimate CARD1 CARD2 ...               Estimate card values by name"
    opts.separator "  search QUERY                           Search for a card"
    opts.separator ""
    
    opts.on('--cards CARD1,CARD2', Array, 'Card names (if known)') do |cards|
      options[:cards] = cards
    end
    
    opts.on('-h', '--help', 'Show this help message') do
      puts opts
      exit
    end
  end

  parser.parse!

  if ARGV.empty?
    puts parser
    exit
  end

  command = ARGV.shift
  estimator = MTGEstimator.new

  case command
  when 'image'
    image_path = ARGV.shift
    unless image_path
      puts "Error: Please provide an image path"
      exit 1
    end

    results = estimator.process_image(image_path, options[:cards])

    if results['error']
      puts "\nError: #{results['error']}"
      exit 1
    end

    puts "\n#{'=' * 60}"
    puts "RESULTS"
    puts '=' * 60

    if results['cards'] && !results['cards'].empty?
      results['cards'].each do |card|
        name = card['name']
        price = card['price_usd']
        if price
          puts "  #{name}: $#{format('%.2f', price)}"
        else
          puts "  #{name}: Price not available"
        end
      end

      puts "\nTotal Estimated Value: $#{format('%.2f', results['total_value'])}"
    else
      puts "No pricing information available."
      puts "Use --cards option to specify card names."
    end

  when 'estimate'
    cards = ARGV
    if cards.empty?
      puts "Error: Please provide at least one card name"
      exit 1
    end

    results = estimator.estimate_cards(cards)

    puts "\n#{'=' * 60}"
    puts "PRICE ESTIMATION"
    puts '=' * 60

    results['cards'].each do |card|
      name = card['name']
      price = card['price_usd']
      if price
        puts "  #{name}: $#{format('%.2f', price)}"
      else
        error = card['error'] || 'Unknown error'
        puts "  #{name}: #{error}"
      end
    end

    puts "\nTotal Estimated Value: $#{format('%.2f', results['total_usd'])}"
    puts "Found: #{results['found']}/#{cards.length}"

  when 'search'
    query = ARGV.join(' ')
    if query.empty?
      puts "Error: Please provide a card name to search"
      exit 1
    end

    result = estimator.search_card(query)

    puts "\n#{'=' * 60}"
    puts "CARD INFORMATION"
    puts '=' * 60

    if result['error']
      puts "Error: #{result['error']}"
    else
      puts "Name: #{result['name']}"
      puts "Set: #{result['set']} (#{result['set_code']})"

      if result['prices']
        puts "\nPrices:"
        result['prices'].each do |currency, price|
          puts "  #{currency}: $#{format('%.2f', price)}"
        end
      else
        puts "\nPrices: Not available"
      end

      puts "\nMore info: #{result['scryfall_uri']}"
    end

  else
    puts "Unknown command: #{command}"
    puts parser
    exit 1
  end
end

main if __FILE__ == $PROGRAM_NAME
