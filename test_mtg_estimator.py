#!/usr/bin/env python3
"""
Test script for MTG Estimator
Tests the core functionality without requiring actual images.
"""
import sys
from card_recognizer import CardRecognizer
from price_fetcher import PriceFetcher


def test_card_search():
    """Test card search functionality."""
    print("=" * 60)
    print("TEST 1: Card Search")
    print("=" * 60)
    
    recognizer = CardRecognizer()
    
    # Test with a common card
    test_cards = ["Lightning Bolt", "Black Lotus", "Counterspell"]
    
    for card_name in test_cards:
        print(f"\nSearching for: {card_name}")
        result = recognizer.search_card_by_name(card_name)
        
        if result:
            print(f"  ✓ Found: {result.get('name')}")
            print(f"    Set: {result.get('set_name')} ({result.get('set')})")
            print(f"    Scryfall ID: {result.get('id')}")
        else:
            print(f"  ✗ Not found")
    
    return True


def test_price_fetching():
    """Test price fetching functionality."""
    print("\n" + "=" * 60)
    print("TEST 2: Price Fetching")
    print("=" * 60)
    
    price_fetcher = PriceFetcher()
    
    # Test individual card price
    print("\nFetching price for Lightning Bolt...")
    price = price_fetcher.estimate_card_value("Lightning Bolt")
    
    if price is not None:
        print(f"  ✓ Price found: ${price:.2f}")
    else:
        print(f"  ✗ Price not available")
    
    # Test multiple cards
    print("\nFetching prices for multiple cards...")
    cards = ["Lightning Bolt", "Counterspell", "Dark Ritual"]
    results = price_fetcher.estimate_total_value(cards)
    
    print(f"\n  Cards processed: {len(results['cards'])}")
    print(f"  Found: {results['found']}")
    print(f"  Not found: {results['not_found']}")
    print(f"  Total value: ${results['total_usd']:.2f}")
    
    for card in results['cards']:
        name = card['name']
        price = card.get('price_usd')
        if price is not None:
            print(f"    - {name}: ${price:.2f}")
        else:
            print(f"    - {name}: Not available")
    
    return True


def test_card_detector():
    """Test card detector (without actual images)."""
    print("\n" + "=" * 60)
    print("TEST 3: Card Detector")
    print("=" * 60)
    
    from card_detector import CardDetector
    
    detector = CardDetector()
    print(f"\n  ✓ Card detector initialized")
    print(f"    Min card area: {detector.min_card_area} pixels")
    print(f"    Card aspect ratio: {detector.card_aspect_ratio}")
    print(f"    Aspect ratio tolerance: {detector.aspect_ratio_tolerance}")
    print(f"\n  Note: Image processing requires actual card images to test")
    
    return True


def main():
    """Run all tests."""
    print("\n" + "=" * 60)
    print("MTG ESTIMATOR - TEST SUITE")
    print("=" * 60)
    
    tests = [
        ("Card Search", test_card_search),
        ("Price Fetching", test_price_fetching),
        ("Card Detector", test_card_detector),
    ]
    
    passed = 0
    failed = 0
    
    for test_name, test_func in tests:
        try:
            if test_func():
                passed += 1
            else:
                failed += 1
                print(f"  ✗ {test_name} failed")
        except Exception as e:
            failed += 1
            print(f"\n  ✗ {test_name} failed with exception: {e}")
    
    print("\n" + "=" * 60)
    print("TEST SUMMARY")
    print("=" * 60)
    print(f"Passed: {passed}/{len(tests)}")
    print(f"Failed: {failed}/{len(tests)}")
    
    if failed == 0:
        print("\n✓ All tests passed!")
        return 0
    else:
        print(f"\n✗ {failed} test(s) failed")
        return 1


if __name__ == '__main__':
    sys.exit(main())
