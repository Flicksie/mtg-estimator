"""
OCR service for extracting card names from images.
Uses Tesseract OCR to identify card text.
"""
import cv2
import numpy as np
from typing import Optional, List
try:
    import pytesseract
    TESSERACT_AVAILABLE = True
except ImportError:
    TESSERACT_AVAILABLE = False
    print("Warning: pytesseract not available. OCR functionality will be limited.")


class OCRService:
    """Service for extracting text from card images using OCR."""
    
    def __init__(self):
        """Initialize OCR service."""
        self.tesseract_available = TESSERACT_AVAILABLE
    
    def preprocess_image(self, image: np.ndarray) -> np.ndarray:
        """
        Preprocess image for better OCR results.
        
        Args:
            image: OpenCV image
            
        Returns:
            Preprocessed image
        """
        # Convert to grayscale
        if len(image.shape) == 3:
            gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
        else:
            gray = image.copy()
        
        # Apply thresholding to get better text contrast
        _, thresh = cv2.threshold(gray, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)
        
        # Denoise
        denoised = cv2.fastNlMeansDenoising(thresh)
        
        return denoised
    
    def extract_card_name_from_region(self, image: np.ndarray, top_percentage: float = 0.15) -> Optional[str]:
        """
        Extract card name from the top region of a card image.
        MTG card names are typically in the top 15% of the card.
        
        Args:
            image: OpenCV image of the card
            top_percentage: Percentage of card height to consider for name
            
        Returns:
            Extracted card name or None
        """
        if not self.tesseract_available:
            return None
        
        try:
            height, width = image.shape[:2]
            name_region_height = int(height * top_percentage)
            
            # Extract the top region where the card name should be
            name_region = image[0:name_region_height, :]
            
            # Preprocess the region
            processed = self.preprocess_image(name_region)
            
            # Perform OCR
            text = pytesseract.image_to_string(processed, config='--psm 7')
            
            # Clean up the text
            card_name = text.strip()
            
            # Remove common OCR artifacts and non-alphanumeric characters except spaces and commas
            card_name = ''.join(c for c in card_name if c.isalnum() or c in [' ', ',', "'", '-'])
            card_name = ' '.join(card_name.split())  # Normalize whitespace
            
            if card_name and len(card_name) > 2:
                return card_name
            
            return None
            
        except Exception as e:
            print(f"Error extracting card name: {e}")
            return None
    
    def extract_text_from_image(self, image_path: str) -> List[str]:
        """
        Extract all text from an image.
        
        Args:
            image_path: Path to image file
            
        Returns:
            List of extracted text lines
        """
        if not self.tesseract_available:
            return []
        
        try:
            # Read image
            image = cv2.imread(image_path)
            if image is None:
                return []
            
            # Preprocess
            processed = self.preprocess_image(image)
            
            # Perform OCR
            text = pytesseract.image_to_string(processed)
            
            # Split into lines and clean
            lines = [line.strip() for line in text.split('\n') if line.strip()]
            
            return lines
            
        except Exception as e:
            print(f"Error extracting text: {e}")
            return []
    
    def is_available(self) -> bool:
        """Check if OCR functionality is available."""
        return self.tesseract_available
