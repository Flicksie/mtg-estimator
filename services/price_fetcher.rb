# frozen_string_literal: true

require 'httparty'

# PriceFetcher - Fetches MTG card prices from online marketplaces
class PriceFetcher
  include HTTParty
  base_uri 'https://api.scryfall.com'

  def initialize
    self.class.headers('User-Agent' => 'MTG-Estimator/1.0')
  end

  # Get price information for a card
  # @param card_data [Hash] Card data from Scryfall
  # @return [Hash, nil] Dictionary with price information or nil
  def get_card_price(card_data)
    return nil unless card_data && card_data['prices']

    prices = card_data['prices']
    result = {}

    # Extract available prices
    result['usd'] = prices['usd'].to_f if prices['usd']
    result['usd_foil'] = prices['usd_foil'].to_f if prices['usd_foil']
    result['eur'] = prices['eur'].to_f if prices['eur']
    result['eur_foil'] = prices['eur_foil'].to_f if prices['eur_foil']

    result.empty? ? nil : result
  end

  # Estimate the value of a card
  # @param card_name [String] Name of the card
  # @param set_code [String, nil] Optional set code for specific printing
  # @return [Float, nil] Estimated USD price or nil
  def estimate_card_value(card_name, set_code = nil)
    params = { fuzzy: card_name }
    params[:set] = set_code if set_code

    response = self.class.get('/cards/named', query: params)

    if response.success?
      card_data = response.parsed_response
      prices = get_card_price(card_data)
      
      return prices['usd'] if prices && prices['usd']
    end

    nil
  rescue StandardError => e
    puts "Error estimating card value: #{e.message}"
    nil
  end

  # Estimate the total value of multiple cards
  # @param card_names [Array<String>] List of card names
  # @return [Hash] Dictionary with individual prices and total
  def estimate_total_value(card_names)
    results = {
      'cards' => [],
      'total_usd' => 0.0,
      'found' => 0,
      'not_found' => 0
    }

    card_names.each do |card_name|
      price = estimate_card_value(card_name)

      if price
        results['cards'] << {
          'name' => card_name,
          'price_usd' => price
        }
        results['total_usd'] += price
        results['found'] += 1
      else
        results['cards'] << {
          'name' => card_name,
          'price_usd' => nil,
          'error' => 'Price not found'
        }
        results['not_found'] += 1
      end
    end

    results['total_usd'] = results['total_usd'].round(2)
    results
  end
end
