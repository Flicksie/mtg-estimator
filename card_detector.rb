# frozen_string_literal: true

# CardDetector - Detects MTG cards in images
# Note: Currently returns a single card placeholder since Gemini handles multi-card detection
class CardDetector
  def initialize
    # Placeholder - Gemini OCR handles card detection directly
  end

  # Detect cards in an image
  # @param image_path [String] Path to the image file
  # @return [Array<Hash>] List of detected card regions (placeholder - Gemini handles detection)
  def detect_cards(image_path)
    # Return a single placeholder entry - Gemini OCR will detect all cards in the image
    return [] unless File.exist?(image_path)
    [{ placeholder: true }]
  end

end
