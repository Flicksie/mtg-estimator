#!/usr/bin/env python3
"""
MTG Card Estimator - Main Application
A tool to detect MTG cards in images and estimate their value.
"""
import argparse
import sys
from typing import List
from card_detector import CardDetector
from card_recognizer import CardRecognizer
from price_fetcher import PriceFetcher


class MTGEstimator:
    """Main application class for MTG card estimation."""
    
    def __init__(self):
        """Initialize the MTG estimator."""
        self.detector = CardDetector()
        self.recognizer = CardRecognizer()
        self.price_fetcher = PriceFetcher()
    
    def process_image(self, image_path: str, card_names: List[str] = None) -> dict:
        """
        Process an image to detect and estimate card values.
        
        Args:
            image_path: Path to the image file
            card_names: Optional list of card names if detection is skipped
            
        Returns:
            Dictionary with results
        """
        results = {
            'image_path': image_path,
            'cards_detected': 0,
            'cards': [],
            'total_value': 0.0
        }
        
        try:
            # Detect cards in the image
            print(f"Processing image: {image_path}")
            card_images = self.detector.detect_cards(image_path)
            results['cards_detected'] = len(card_images)
            print(f"Detected {len(card_images)} card(s) in the image")
            
            # If card names are provided manually, use them
            if card_names:
                print(f"\nUsing provided card names: {', '.join(card_names)}")
                price_results = self.price_fetcher.estimate_total_value(card_names)
                results['cards'] = price_results['cards']
                results['total_value'] = price_results['total_usd']
            else:
                print("\nNote: Automatic card recognition from images requires OCR integration.")
                print("Please provide card names manually using the --cards option.")
            
            return results
            
        except Exception as e:
            print(f"Error processing image: {e}")
            results['error'] = str(e)
            return results
    
    def estimate_cards(self, card_names: List[str]) -> dict:
        """
        Estimate the value of cards by name.
        
        Args:
            card_names: List of card names
            
        Returns:
            Dictionary with pricing results
        """
        print(f"Estimating value for {len(card_names)} card(s)...")
        return self.price_fetcher.estimate_total_value(card_names)
    
    def search_card(self, query: str) -> dict:
        """
        Search for a card by name.
        
        Args:
            query: Card name or search query
            
        Returns:
            Card information
        """
        print(f"Searching for: {query}")
        card_data = self.recognizer.search_card_by_name(query)
        
        if card_data:
            prices = self.price_fetcher.get_card_price(card_data)
            return {
                'name': card_data.get('name'),
                'set': card_data.get('set_name'),
                'set_code': card_data.get('set'),
                'prices': prices,
                'scryfall_uri': card_data.get('scryfall_uri')
            }
        else:
            return {'error': 'Card not found'}


def main():
    """Main entry point for the CLI."""
    parser = argparse.ArgumentParser(
        description='MTG Card Estimator - Detect and estimate the value of Magic: The Gathering cards'
    )
    
    subparsers = parser.add_subparsers(dest='command', help='Available commands')
    
    # Image processing command
    image_parser = subparsers.add_parser('image', help='Process an image with cards')
    image_parser.add_argument('image_path', help='Path to the image file')
    image_parser.add_argument('--cards', nargs='+', help='Card names (if known)')
    
    # Estimate command
    estimate_parser = subparsers.add_parser('estimate', help='Estimate card values by name')
    estimate_parser.add_argument('cards', nargs='+', help='Card names to estimate')
    
    # Search command
    search_parser = subparsers.add_parser('search', help='Search for a card')
    search_parser.add_argument('query', help='Card name to search for')
    
    args = parser.parse_args()
    
    if not args.command:
        parser.print_help()
        return
    
    estimator = MTGEstimator()
    
    if args.command == 'image':
        # Process image
        results = estimator.process_image(args.image_path, args.cards)
        
        if 'error' in results:
            print(f"\nError: {results['error']}")
            sys.exit(1)
        
        print(f"\n{'='*60}")
        print("RESULTS")
        print('='*60)
        
        if results['cards']:
            for card in results['cards']:
                name = card['name']
                price = card.get('price_usd')
                if price is not None:
                    print(f"  {name}: ${price:.2f}")
                else:
                    print(f"  {name}: Price not available")
            
            print(f"\nTotal Estimated Value: ${results['total_value']:.2f}")
        else:
            print("No pricing information available.")
            print("Use --cards option to specify card names.")
    
    elif args.command == 'estimate':
        # Estimate card values
        results = estimator.estimate_cards(args.cards)
        
        print(f"\n{'='*60}")
        print("PRICE ESTIMATION")
        print('='*60)
        
        for card in results['cards']:
            name = card['name']
            price = card.get('price_usd')
            if price is not None:
                print(f"  {name}: ${price:.2f}")
            else:
                error = card.get('error', 'Unknown error')
                print(f"  {name}: {error}")
        
        print(f"\nTotal Estimated Value: ${results['total_usd']:.2f}")
        print(f"Found: {results['found']}/{len(args.cards)}")
    
    elif args.command == 'search':
        # Search for a card
        result = estimator.search_card(args.query)
        
        print(f"\n{'='*60}")
        print("CARD INFORMATION")
        print('='*60)
        
        if 'error' in result:
            print(f"Error: {result['error']}")
        else:
            print(f"Name: {result['name']}")
            print(f"Set: {result['set']} ({result['set_code']})")
            
            if result.get('prices'):
                print("\nPrices:")
                for currency, price in result['prices'].items():
                    print(f"  {currency}: ${price:.2f}")
            else:
                print("\nPrices: Not available")
            
            print(f"\nMore info: {result['scryfall_uri']}")


if __name__ == '__main__':
    main()
