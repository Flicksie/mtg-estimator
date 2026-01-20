"""
MTG Card Estimator Package
"""

__version__ = "1.0.0"
__author__ = "Flicksie"
__description__ = "A tool to detect MTG cards in images and estimate their value"

from card_detector import CardDetector
from card_recognizer import CardRecognizer
from price_fetcher import PriceFetcher

__all__ = ['CardDetector', 'CardRecognizer', 'PriceFetcher']
