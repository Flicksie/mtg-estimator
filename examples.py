#!/usr/bin/env python3
"""
Example usage of MTG Card Estimator as a library.
This demonstrates how to use the estimator modules programmatically.
"""
from card_detector import CardDetector
from card_recognizer import CardRecognizer
from price_fetcher import PriceFetcher


def example_price_estimation():
    """Example: Estimate the value of known cards."""
    print("=" * 60)
    print("EXAMPLE 1: Estimate Card Values by Name")
    print("=" * 60)
    
    price_fetcher = PriceFetcher()
    
    # List of cards to estimate
    cards = [
        "Lightning Bolt",
        "Counterspell",
        "Tarmogoyf",
        "Black Lotus"
    ]
    
    print(f"\nEstimating value for {len(cards)} cards...")
    results = price_fetcher.estimate_total_value(cards)
    
    print(f"\nResults:")
    for card in results['cards']:
        name = card['name']
        price = card.get('price_usd')
        if price is not None:
            print(f"  • {name}: ${price:.2f}")
        else:
            print(f"  • {name}: Price not available")
    
    print(f"\nTotal Estimated Value: ${results['total_usd']:.2f}")
    print(f"Successfully priced: {results['found']}/{len(cards)} cards")


def example_card_search():
    """Example: Search for detailed card information."""
    print("\n" + "=" * 60)
    print("EXAMPLE 2: Search for Card Information")
    print("=" * 60)
    
    recognizer = CardRecognizer()
    
    card_name = "Lightning Bolt"
    print(f"\nSearching for: {card_name}")
    
    card_data = recognizer.search_card_by_name(card_name)
    
    if card_data:
        print(f"\nCard Found:")
        print(f"  Name: {card_data.get('name')}")
        print(f"  Set: {card_data.get('set_name')} ({card_data.get('set')})")
        print(f"  Type: {card_data.get('type_line')}")
        print(f"  Mana Cost: {card_data.get('mana_cost', 'N/A')}")
        
        if 'prices' in card_data:
            prices = card_data['prices']
            print(f"\n  Prices:")
            if prices.get('usd'):
                print(f"    USD: ${prices['usd']}")
            if prices.get('usd_foil'):
                print(f"    USD Foil: ${prices['usd_foil']}")
        
        print(f"\n  Scryfall: {card_data.get('scryfall_uri')}")
    else:
        print(f"Card not found: {card_name}")


def example_card_detection():
    """Example: Demonstrate card detection setup."""
    print("\n" + "=" * 60)
    print("EXAMPLE 3: Card Detection Setup")
    print("=" * 60)
    
    detector = CardDetector()
    
    print("\nCard Detector Configuration:")
    print(f"  Minimum Card Area: {detector.min_card_area} pixels")
    print(f"  Card Aspect Ratio: {detector.card_aspect_ratio}")
    print(f"  Aspect Ratio Tolerance: ±{detector.aspect_ratio_tolerance}")
    
    print("\nTo detect cards in an image:")
    print("  detector = CardDetector()")
    print("  card_images = detector.detect_cards('path/to/image.jpg')")
    print("  print(f'Found {len(card_images)} cards')")
    
    print("\nNote: For actual card detection, provide an image path.")
    print("      The detector will return cropped images of individual cards.")


def example_complete_workflow():
    """Example: Complete workflow from card names to price estimation."""
    print("\n" + "=" * 60)
    print("EXAMPLE 4: Complete Workflow")
    print("=" * 60)
    
    # Initialize all components
    recognizer = CardRecognizer()
    price_fetcher = PriceFetcher()
    
    # Step 1: Search for a specific card
    card_name = "Tarmogoyf"
    print(f"\nStep 1: Searching for '{card_name}'...")
    card_data = recognizer.search_card_by_name(card_name)
    
    if card_data:
        print(f"  ✓ Found: {card_data.get('name')}")
        print(f"    Set: {card_data.get('set_name')}")
        
        # Step 2: Get price information
        print(f"\nStep 2: Fetching price information...")
        prices = price_fetcher.get_card_price(card_data)
        
        if prices:
            print(f"  ✓ Price: ${prices.get('usd', 'N/A')}")
        else:
            print(f"  ✗ Price not available")
    else:
        print(f"  ✗ Card not found")
    
    # Step 3: Estimate value of a collection
    print(f"\nStep 3: Estimating collection value...")
    collection = ["Lightning Bolt", "Counterspell", "Dark Ritual"]
    results = price_fetcher.estimate_total_value(collection)
    
    print(f"  Collection: {', '.join(collection)}")
    print(f"  Total Value: ${results['total_usd']:.2f}")
    print(f"  Cards Priced: {results['found']}/{len(collection)}")


def main():
    """Run all examples."""
    print("\n" + "=" * 60)
    print("MTG CARD ESTIMATOR - USAGE EXAMPLES")
    print("=" * 60)
    
    # Note: These examples will attempt to connect to the Scryfall API
    # If you're offline or the API is unavailable, they will fail gracefully
    
    print("\nNote: These examples require an internet connection to")
    print("      access the Scryfall API. If the API is unreachable,")
    print("      the examples will show error handling behavior.\n")
    
    try:
        example_price_estimation()
    except Exception as e:
        print(f"\nExample 1 failed: {e}")
    
    try:
        example_card_search()
    except Exception as e:
        print(f"\nExample 2 failed: {e}")
    
    try:
        example_card_detection()
    except Exception as e:
        print(f"\nExample 3 failed: {e}")
    
    try:
        example_complete_workflow()
    except Exception as e:
        print(f"\nExample 4 failed: {e}")
    
    print("\n" + "=" * 60)
    print("Examples completed!")
    print("=" * 60)


if __name__ == '__main__':
    main()
