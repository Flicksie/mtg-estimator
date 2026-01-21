# frozen_string_literal: true

begin
  require 'rmagick'
  RMAGICK_AVAILABLE = true
rescue LoadError
  RMAGICK_AVAILABLE = false
  puts "Warning: RMagick not available. Card detection functionality will be limited."
end

# CardDetector - Detects MTG cards in images
class CardDetector
  MIN_CARD_AREA = 10_000 # Minimum area for a card in pixels
  CARD_ASPECT_RATIO = 0.714 # Standard MTG card aspect ratio (2.5" x 3.5")
  ASPECT_RATIO_TOLERANCE = 0.25

  def initialize
    @rmagick_available = RMAGICK_AVAILABLE
  end

  # Check if a rectangle matches card dimensions
  # @param width [Integer] Width of the rectangle
  # @param height [Integer] Height of the rectangle
  # @param area [Integer] Area of the rectangle
  # @return [Boolean] True if rectangle matches card aspect ratio and size
  def card_dimensions?(width, height, area)
    return false if area < MIN_CARD_AREA

    aspect_ratio = width.to_f / height
    
    # Check if aspect ratio matches a card (portrait or landscape)
    is_portrait = (aspect_ratio - CARD_ASPECT_RATIO).abs < ASPECT_RATIO_TOLERANCE
    is_landscape = (aspect_ratio - (1.0 / CARD_ASPECT_RATIO)).abs < ASPECT_RATIO_TOLERANCE
    
    is_portrait || is_landscape
  end

  # Detect cards in an image (simplified version without OpenCV)
  # @param image_path [String] Path to the image file
  # @return [Array<Hash>] List of detected card regions
  def detect_cards(image_path)
    unless @rmagick_available
      puts "RMagick not available. Returning empty detection result."
      return []
    end

    begin
      # Read the image
      image = Magick::Image.read(image_path).first
      
      # For simplicity, we'll return a basic detection result
      # In a production environment, you would implement edge detection
      # and contour finding similar to the Python OpenCV version
      
      # This is a placeholder that indicates cards were detected
      # In reality, you'd need to implement proper image processing
      [{ width: image.columns, height: image.rows }]
    rescue StandardError => e
      puts "Error detecting cards: #{e.message}"
      []
    end
  end

  # Get bounding boxes for detected cards (simplified)
  # @param image_path [String] Path to the image file
  # @return [Array<Hash>] List of bounding boxes
  def get_card_boundaries(image_path)
    detect_cards(image_path)
  end

  # Check if card detection is available
  # @return [Boolean] True if RMagick is available
  def available?
    @rmagick_available
  end
end
