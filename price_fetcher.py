"""
Price fetching module for MTG card estimator.
Fetches card prices from various sources.
"""
import requests
from typing import Optional, Dict, Any, List


class PriceFetcher:
    """Fetches MTG card prices from online marketplaces."""
    
    def __init__(self):
        """Initialize the price fetcher."""
        self.scryfall_api_base = "https://api.scryfall.com"
        self.session = requests.Session()
        self.session.headers.update({
            'User-Agent': 'MTG-Estimator/1.0'
        })
    
    def get_card_price(self, card_data: Dict[str, Any]) -> Optional[Dict[str, float]]:
        """
        Get price information for a card.
        
        Args:
            card_data: Card data from Scryfall
            
        Returns:
            Dictionary with price information or None
        """
        if not card_data or 'prices' not in card_data:
            return None
        
        prices = card_data['prices']
        result = {}
        
        # Extract available prices
        if prices.get('usd'):
            try:
                result['usd'] = float(prices['usd'])
            except (ValueError, TypeError):
                pass
        if prices.get('usd_foil'):
            try:
                result['usd_foil'] = float(prices['usd_foil'])
            except (ValueError, TypeError):
                pass
        if prices.get('eur'):
            try:
                result['eur'] = float(prices['eur'])
            except (ValueError, TypeError):
                pass
        if prices.get('eur_foil'):
            try:
                result['eur_foil'] = float(prices['eur_foil'])
            except (ValueError, TypeError):
                pass
        
        return result if result else None
    
    def estimate_card_value(self, card_name: str, set_code: Optional[str] = None) -> Optional[float]:
        """
        Estimate the value of a card.
        
        Args:
            card_name: Name of the card
            set_code: Optional set code for specific printing
            
        Returns:
            Estimated USD price or None
        """
        try:
            # Search for the card
            url = f"{self.scryfall_api_base}/cards/named"
            params = {'fuzzy': card_name}
            
            if set_code:
                params['set'] = set_code
            
            response = self.session.get(url, params=params)
            
            if response.status_code == 200:
                card_data = response.json()
                prices = self.get_card_price(card_data)
                
                if prices and 'usd' in prices:
                    return prices['usd']
            
            return None
        except Exception as e:
            print(f"Error estimating card value: {e}")
            return None
    
    def estimate_total_value(self, card_names: List[str]) -> Dict[str, Any]:
        """
        Estimate the total value of multiple cards.
        
        Args:
            card_names: List of card names
            
        Returns:
            Dictionary with individual prices and total
        """
        results = {
            'cards': [],
            'total_usd': 0.0,
            'found': 0,
            'not_found': 0
        }
        
        for card_name in card_names:
            price = self.estimate_card_value(card_name)
            
            if price is not None:
                results['cards'].append({
                    'name': card_name,
                    'price_usd': price
                })
                results['total_usd'] += price
                results['found'] += 1
            else:
                results['cards'].append({
                    'name': card_name,
                    'price_usd': None,
                    'error': 'Price not found'
                })
                results['not_found'] += 1
        
        results['total_usd'] = round(results['total_usd'], 2)
        return results
