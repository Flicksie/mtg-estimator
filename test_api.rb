#!/usr/bin/env ruby
# Test the API endpoints

require 'net/http'
require 'json'
require 'uri'

base_url = 'http://localhost:5000'

# Test /api/stats
puts "Testing /api/stats..."
uri = URI("#{base_url}/api/stats")
http = Net::HTTP.new(uri.host, uri.port)
request = Net::HTTP::Get.new(uri.path)
response = http.request(request)
puts "Status: #{response.code}"
puts "Body: #{response.body}"
puts "---\n"
