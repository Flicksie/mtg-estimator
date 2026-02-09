# frozen_string_literal: true

require 'httparty'

class CardRecognizer
  include HTTParty
  base_uri 'https://api.scryfall.com'

  def initialize
    self.class.headers('User-Agent' => 'MTG-Estimator/1.0')
  end

  # Search for a card by name using Scryfall API
  # @param card_name [String] Name of the card to search for
  # @return [Hash, nil] Card data from Scryfall or nil if not found
  def search_card_by_name(card_name)
    response = self.class.get('/cards/named', query: { fuzzy: card_name })
    
    return response.parsed_response if response.success?
    
    nil
  rescue StandardError => e
    puts "Error searching for card: #{e.message}"
    nil
  end

  # Get detailed card information by Scryfall ID
  # @param scryfall_id [String] Scryfall UUID for the card
  # @return [Hash, nil] Card data from Scryfall or nil if not found
  def get_card_info(scryfall_id)
    response = self.class.get("/cards/#{scryfall_id}")
    
    return response.parsed_response if response.success?
    
    nil
  rescue StandardError => e
    puts "Error getting card info: #{e.message}"
    nil
  end

  # Search for cards using Scryfall search syntax
  # @param query [String] Search query
  # @param page [Integer] Page number for pagination
  # @return [Hash] Search results from Scryfall
  def search_cards(query, page = 1)
    response = self.class.get('/cards/search', query: { q: query, page: page })
    
    return response.parsed_response if response.success?
    
    { 'object' => 'error', 'details' => 'Search failed' }
  rescue StandardError => e
    puts "Error searching cards: #{e.message}"
    { 'object' => 'error', 'details' => e.message }
  end
end
