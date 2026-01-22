# frozen_string_literal: true

require 'json'
require 'net/http'
require 'uri'
require 'base64'
require 'openssl'

# OCRService - Service for extracting text from card images using OCR
# Uses Gemini Vision (preferred) for title extraction; no local OCR dependencies.
class OCRService
  def initialize
    @gemini_key = ENV['GEMINI_API_KEY']
    @backend = choose_backend
    puts "[OCR] initialized backend=#{@backend} gemini_key_present=#{!@gemini_key.to_s.empty?}"
  end

  # Which OCR backend is currently active (gemini or unavailable)
  # @return [String]
  def backend
    @backend
  end

  # Decide which backend to use based on env preference and availability
  def choose_backend
    return 'gemini' if @gemini_key && !@gemini_key.empty?
    'unavailable'
  end

  # Extract card name from the top region of a card image
  # @param image_path [String] Path to the card image
  # @param top_percentage [Float] Percentage of card height to consider for name (kept for API compatibility)
  # @return [String, nil] Extracted card name or nil
  def extract_card_name_from_region(image_path, top_percentage = 0.15)
    puts "[OCR] backend=#{@backend} image=#{image_path} mode=title"
    return extract_card_name_with_gemini(image_path) if @backend == 'gemini'
    nil
  end

  # Extract all text from an image
  # @param image_path [String] Path to image file
  # @return [Array<String>] List of extracted text lines
  def extract_text_from_image(image_path)
    puts "[OCR] backend=#{@backend} image=#{image_path} mode=full"
    return extract_all_text_with_gemini(image_path) if @backend == 'gemini'
    []
  end

  # Check if OCR functionality is available
  # @return [Boolean] True if any backend is available
  def available?
    @backend != 'unavailable'
  end

  private

  def extract_card_name_with_gemini(image_path)
    payload = gemini_request(image_path, mode: 'title')
    titles = Array(payload['titles'])
    best = payload['title'] || payload['best_text']

    cleaned_titles = titles.map { |t| t.to_s.gsub(/[^a-zA-Z0-9\s,'\-]/, '').squeeze(' ').strip }
                         .reject { |t| t.length < 3 }
                         .uniq

    if cleaned_titles.any?
      puts "[Gemini] extracted_titles=#{cleaned_titles.inspect}"
      return cleaned_titles
    end

    puts "[Gemini] extracted_title_raw=#{best.inspect}"
    return nil unless best

    cleaned = best.to_s.gsub(/[^a-zA-Z0-9\s,'\-]/, '').squeeze(' ').strip
    cleaned.length > 2 ? cleaned : nil
  rescue StandardError => e
    puts "Gemini OCR error: #{e.message}"
    nil
  end

  def extract_all_text_with_gemini(image_path)
    payload = gemini_request(image_path, mode: 'full')
    lines = payload['lines'] || []
    lines.map { |l| l.to_s.strip }.reject(&:empty?)
  rescue StandardError => e
    puts "Gemini OCR error: #{e.message}"
    []
  end

  def gemini_request(image_path, mode: 'title')
    raise 'GEMINI_API_KEY is not set' unless @gemini_key && !@gemini_key.empty?

    model = ENV['GEMINI_MODEL'] || 'gemini-2.5-flash'
    uri = URI.parse("https://generativelanguage.googleapis.com/v1/models/#{model}:generateContent")
    image_b64 = Base64.strict_encode64(File.binread(image_path))
    puts "[Gemini] mode=#{mode} image_size_bytes=#{File.size(image_path)} payload_b64_len=#{image_b64.length}"

    prompt = if mode == 'title'
               'Return only the Magic: The Gathering cards titles you see.There might be several cards. Respond as JSON {"titles":["...","..."]}. If unsure, use null.'
             else
               'Extract all readable text as an array of strings. Respond as JSON {"lines":["..."]}.'
             end

    body = {
      contents: [
        {
          parts: [
            { text: prompt },
            { inline_data: { mime_type: 'image/jpeg', data: image_b64 } }
          ]
        }
      ]
    }

    request = Net::HTTP::Post.new(uri)
    request['Content-Type'] = 'application/json'
    request['x-goog-api-key'] = @gemini_key
    request.body = JSON.generate(body)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    response = http.request(request)

    puts "[Gemini] status=#{response.code}"
    raise "Gemini request failed: #{response.code} #{response.body}" unless response.is_a?(Net::HTTPSuccess)

    parsed = JSON.parse(response.body)
    puts "[Gemini->] raw_response_preview=#{response.body[0,2000]}"
    text = parsed.dig('candidates', 0, 'content', 'parts', 0, 'text') || '{}'
    # Strip markdown fences if the model returned ```json ... ```
    if text.start_with?('```')
      text = text.gsub(/^```json\s*/i, '').gsub(/^```/, '').gsub(/```\s*$/, '')
    end
    puts "[Gemini] raw_text_response_preview=#{text[0,200]}"
    JSON.parse(text) rescue { 'raw' => text }
  end
end
