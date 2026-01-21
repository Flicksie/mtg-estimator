# frozen_string_literal: true

# OCRService - Service for extracting text from card images using OCR
class OCRService
  def initialize
    @tesseract_available = check_tesseract
  end

  # Check if Tesseract OCR is available
  # @return [Boolean] True if Tesseract is installed
  def check_tesseract
    system('which tesseract > /dev/null 2>&1')
  end

  # Extract card name from the top region of a card image
  # MTG card names are typically in the top 15% of the card
  # @param image_path [String] Path to the card image
  # @param top_percentage [Float] Percentage of card height to consider for name
  # @return [String, nil] Extracted card name or nil
  def extract_card_name_from_region(image_path, top_percentage = 0.15)
    return nil unless @tesseract_available

    begin
      # Use Tesseract to extract text from image
      # Using --psm 7 for single line of text
      text = `tesseract "#{image_path}" stdout --psm 7 2>/dev/null`.strip
      
      # Clean up the text
      card_name = text.gsub(/[^a-zA-Z0-9\s,'\-]/, '').squeeze(' ').strip
      
      return card_name if card_name.length > 2
      
      nil
    rescue StandardError => e
      puts "Error extracting card name: #{e.message}"
      nil
    end
  end

  # Extract all text from an image
  # @param image_path [String] Path to image file
  # @return [Array<String>] List of extracted text lines
  def extract_text_from_image(image_path)
    return [] unless @tesseract_available

    begin
      text = `tesseract "#{image_path}" stdout 2>/dev/null`
      text.split("\n").map(&:strip).reject(&:empty?)
    rescue StandardError => e
      puts "Error extracting text: #{e.message}"
      []
    end
  end

  # Check if OCR functionality is available
  # @return [Boolean] True if Tesseract is available
  def available?
    @tesseract_available
  end
end
