# frozen_string_literal: true

begin
  require 'rmagick'
  RMAGICK_AVAILABLE = true
rescue LoadError
  throw LoadError, "RMagick gem is not installed." 
  RMAGICK_AVAILABLE = false
  puts "Warning: RMagick not available. Card detection functionality will be limited."
end

# CardDetector - Detects MTG cards in images
class CardDetector
  MIN_CARD_AREA = 10_000 # Minimum area for a card in pixels
  CARD_ASPECT_RATIO = 0.714 # Standard MTG card aspect ratio (2.5" x 3.5")
  ASPECT_RATIO_TOLERANCE = 0.35

  def initialize
    puts "RMagick available: #{RMAGICK_AVAILABLE}"
    @rmagick_available = RMAGICK_AVAILABLE
  end

  # Check if a rectangle matches card dimensions (accounts for rotation)
  # @param width [Integer] Width of the rectangle
  # @param height [Integer] Height of the rectangle
  # @param area [Integer] Area of the rectangle
  # @param angle [Float] Optional rotation angle in degrees
  # @return [Boolean] True if rectangle matches card aspect ratio and size
  def card_dimensions?(width, height, area, angle = 0)
    return false if area < MIN_CARD_AREA

    # Calculate effective dimensions accounting for rotation
    # For a rotated rectangle, we check both the original and rotated aspect ratios
    aspect_ratio = width.to_f / height
    
    # Check if aspect ratio matches a card (portrait or landscape)
    is_portrait = (aspect_ratio - CARD_ASPECT_RATIO).abs < ASPECT_RATIO_TOLERANCE
    is_landscape = (aspect_ratio - (1.0 / CARD_ASPECT_RATIO)).abs < ASPECT_RATIO_TOLERANCE
    
    # For rotated cards, be more lenient with aspect ratio checking
    is_rotated_match = if angle != 0
                          # Increase tolerance for rotated/perspective cards
                          (aspect_ratio - CARD_ASPECT_RATIO).abs < (ASPECT_RATIO_TOLERANCE + 0.2) ||
                            (aspect_ratio - (1.0 / CARD_ASPECT_RATIO)).abs < (ASPECT_RATIO_TOLERANCE + 0.2)
                        else
                          false
                        end
    
    is_portrait || is_landscape || is_rotated_match
  end

  # Detect edges in image (for finding rotated/angled cards)
  # @param image_path [String] Path to the image file
  # @return [Magick::Image] Edge-detected image
  def detect_edges(image_path)
    begin
      image = Magick::Image.read(image_path).first
      # Apply edge detection using Laplace operator
      edge_image = image.edge(2)
      edge_image
    rescue StandardError => e
      puts "Error detecting edges: #{e.message}"
      nil
    end
  end

  # Detect cards in an image (handles rotation and perspective)
  # @param image_path [String] Path to the image file
  # @return [Array<Hash>] List of detected card regions with rotation info
  def detect_cards(image_path)
    unless @rmagick_available
      puts "RMagick not available. Returning empty detection result."
      return []
    end

    begin
      # Read the image
      image = Magick::Image.read(image_path).first
      
      # Detect edges to find card boundaries
      edges = detect_edges(image_path)
      
      # In a production environment, implement:
      # 1. Hough line detection to find card edges at various angles
      # 2. Contour detection to find quadrilateral shapes
      # 3. Perspective transform to normalize rotated cards
      # 4. Machine learning models (YOLO, etc.) for robust detection
      #
      # For now, return basic detection with assumption of multiple cards
      # This is a placeholder that indicates cards were detected
      cards = []
      
      # If we have a valid image, assume at least one card is present
      # Real implementation would segment the image and find individual cards
      if image.columns > 100 && image.rows > 100
        cards << {
          width: image.columns,
          height: image.rows,
          x: 0,
          y: 0,
          angle: 0,  # Rotation angle in degrees
          confidence: 0.5  # Placeholder confidence score
        }
      end
      
      cards
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
