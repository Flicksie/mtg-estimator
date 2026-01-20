"""
Card detection module for MTG card estimator.
Detects individual cards in an image using computer vision.
"""
import cv2
import numpy as np
from typing import List, Tuple


class CardDetector:
    """Detects MTG cards in images."""
    
    def __init__(self):
        """Initialize the card detector."""
        self.min_card_area = 10000  # Minimum area for a card in pixels
        self.card_aspect_ratio = 0.714  # Standard MTG card aspect ratio (2.5" x 3.5")
        self.aspect_ratio_tolerance = 0.25
    
    def _is_card_contour(self, contour) -> bool:
        """
        Check if a contour matches card dimensions.
        
        Args:
            contour: OpenCV contour
            
        Returns:
            True if contour matches card aspect ratio and size
        """
        area = cv2.contourArea(contour)
        
        # Skip small contours
        if area < self.min_card_area:
            return False
        
        # Get bounding rectangle
        x, y, w, h = cv2.boundingRect(contour)
        aspect_ratio = w / float(h) if h > 0 else 0
        
        # Check if aspect ratio matches a card (portrait or landscape)
        is_portrait = abs(aspect_ratio - self.card_aspect_ratio) < self.aspect_ratio_tolerance
        is_landscape = abs(aspect_ratio - (1 / self.card_aspect_ratio)) < self.aspect_ratio_tolerance
        
        return is_portrait or is_landscape
    
    def detect_cards(self, image_path: str) -> List[np.ndarray]:
        """
        Detect cards in an image.
        
        Args:
            image_path: Path to the image file
            
        Returns:
            List of cropped card images
        """
        # Read the image
        image = cv2.imread(image_path)
        if image is None:
            raise ValueError(f"Could not read image: {image_path}")
        
        # Preprocess the image
        gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
        blurred = cv2.GaussianBlur(gray, (5, 5), 0)
        edges = cv2.Canny(blurred, 50, 150)
        
        # Find contours
        contours, _ = cv2.findContours(edges, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
        
        # Filter and extract card regions
        card_images = []
        for contour in contours:
            if not self._is_card_contour(contour):
                continue
            
            # Get bounding rectangle and extract card region
            x, y, w, h = cv2.boundingRect(contour)
            card_image = image[y:y+h, x:x+w]
            card_images.append(card_image)
        
        return card_images
    
    def get_card_boundaries(self, image_path: str) -> List[Tuple[int, int, int, int]]:
        """
        Get bounding boxes for detected cards.
        
        Args:
            image_path: Path to the image file
            
        Returns:
            List of bounding boxes as (x, y, width, height) tuples
        """
        # Read the image
        image = cv2.imread(image_path)
        if image is None:
            raise ValueError(f"Could not read image: {image_path}")
        
        # Preprocess the image
        gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
        blurred = cv2.GaussianBlur(gray, (5, 5), 0)
        edges = cv2.Canny(blurred, 50, 150)
        
        # Find contours
        contours, _ = cv2.findContours(edges, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
        
        # Filter and extract bounding boxes
        boundaries = []
        for contour in contours:
            if not self._is_card_contour(contour):
                continue
            
            # Get bounding rectangle
            x, y, w, h = cv2.boundingRect(contour)
            boundaries.append((x, y, w, h))
        
        return boundaries
