#!/usr/bin/env python3
"""
MTG Card Estimator - Web Application
Flask web interface for card detection, identification, and pricing.
"""
import os
import json
from datetime import datetime
from werkzeug.utils import secure_filename
from flask import Flask, render_template, request, jsonify, redirect, url_for, flash, session
from card_detector import CardDetector
from card_recognizer import CardRecognizer
from price_fetcher import PriceFetcher
from ocr_service import OCRService
import cv2
import base64

# Initialize Flask app
app = Flask(__name__)
app.secret_key = os.environ.get('SECRET_KEY', 'dev-secret-key-change-in-production')
app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024  # 16MB max file size
app.config['UPLOAD_FOLDER'] = 'uploads'
app.config['ALLOWED_EXTENSIONS'] = {'png', 'jpg', 'jpeg', 'gif'}

# Create uploads directory if it doesn't exist
os.makedirs(app.config['UPLOAD_FOLDER'], exist_ok=True)

# Initialize services
detector = CardDetector()
recognizer = CardRecognizer()
price_fetcher = PriceFetcher()
ocr_service = OCRService()


def allowed_file(filename):
    """Check if file extension is allowed."""
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in app.config['ALLOWED_EXTENSIONS']


@app.route('/')
def index():
    """Home page / Dashboard."""
    # Get collection statistics
    collection = session.get('collection', [])
    total_cards = len(collection)
    total_value = sum(card.get('price', 0) for card in collection)
    
    stats = {
        'total_cards': total_cards,
        'total_value': total_value,
        'ocr_available': ocr_service.is_available()
    }
    
    return render_template('index.html', stats=stats)


@app.route('/search')
def search():
    """Card search page."""
    return render_template('search.html')


@app.route('/api/search', methods=['POST'])
def api_search():
    """API endpoint for card search."""
    data = request.get_json()
    query = data.get('query', '').strip()
    
    if not query:
        return jsonify({'error': 'Please provide a card name to search'}), 400
    
    # Search for the card
    card_data = recognizer.search_card_by_name(query)
    
    if not card_data:
        return jsonify({'error': 'Card not found'}), 404
    
    # Get price information
    prices = price_fetcher.get_card_price(card_data)
    
    result = {
        'name': card_data.get('name'),
        'set': card_data.get('set_name'),
        'set_code': card_data.get('set'),
        'mana_cost': card_data.get('mana_cost', ''),
        'type_line': card_data.get('type_line', ''),
        'oracle_text': card_data.get('oracle_text', ''),
        'prices': prices or {},
        'image_uri': card_data.get('image_uris', {}).get('normal', ''),
        'scryfall_uri': card_data.get('scryfall_uri', '')
    }
    
    return jsonify(result)


@app.route('/scanner')
def scanner():
    """Card scanner page."""
    return render_template('scanner.html', ocr_available=ocr_service.is_available())


@app.route('/api/scan', methods=['POST'])
def api_scan():
    """API endpoint for card scanning and identification."""
    if 'image' not in request.files:
        return jsonify({'error': 'No image file provided'}), 400
    
    file = request.files['image']
    
    if file.filename == '':
        return jsonify({'error': 'No file selected'}), 400
    
    if not allowed_file(file.filename):
        return jsonify({'error': 'Invalid file type. Allowed types: PNG, JPG, JPEG, GIF'}), 400
    
    try:
        # Save the uploaded file
        filename = secure_filename(f"{datetime.now().strftime('%Y%m%d_%H%M%S')}_{file.filename}")
        filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)
        file.save(filepath)
        
        # Detect cards in the image
        card_images = detector.detect_cards(filepath)
        num_detected = len(card_images)
        
        results = {
            'num_detected': num_detected,
            'cards': [],
            'filename': filename
        }
        
        # Try to identify cards using OCR
        if ocr_service.is_available() and num_detected > 0:
            for i, card_image in enumerate(card_images):
                # Try OCR on card
                card_name = ocr_service.extract_card_name_from_region(card_image)
                
                card_info = {
                    'index': i,
                    'detected': True,
                    'name': None,
                    'price': None,
                    'set': None,
                    'image_uri': None
                }
                
                if card_name:
                    # Search for the card
                    card_data = recognizer.search_card_by_name(card_name)
                    
                    if card_data:
                        prices = price_fetcher.get_card_price(card_data)
                        price_usd = prices.get('usd', 0) if prices else 0
                        
                        card_info.update({
                            'name': card_data.get('name'),
                            'price': price_usd,
                            'set': card_data.get('set_name'),
                            'set_code': card_data.get('set'),
                            'image_uri': card_data.get('image_uris', {}).get('normal', '')
                        })
                
                results['cards'].append(card_info)
        else:
            # No OCR available or no cards detected
            results['message'] = 'Cards detected but OCR not available. Please provide card names manually.'
        
        return jsonify(results)
        
    except Exception as e:
        return jsonify({'error': f'Error processing image: {str(e)}'}), 500


@app.route('/api/identify', methods=['POST'])
def api_identify():
    """API endpoint for manual card identification."""
    data = request.get_json()
    card_names = data.get('card_names', [])
    
    if not card_names:
        return jsonify({'error': 'No card names provided'}), 400
    
    results = []
    total_value = 0
    
    for card_name in card_names:
        card_data = recognizer.search_card_by_name(card_name)
        
        if card_data:
            prices = price_fetcher.get_card_price(card_data)
            price_usd = prices.get('usd', 0) if prices else 0
            
            card_info = {
                'name': card_data.get('name'),
                'price': price_usd,
                'set': card_data.get('set_name'),
                'set_code': card_data.get('set'),
                'image_uri': card_data.get('image_uris', {}).get('normal', ''),
                'found': True
            }
            
            total_value += price_usd
        else:
            card_info = {
                'name': card_name,
                'found': False,
                'error': 'Card not found'
            }
        
        results.append(card_info)
    
    return jsonify({
        'cards': results,
        'total_value': round(total_value, 2)
    })


@app.route('/collection')
def collection():
    """Collection view page."""
    collection = session.get('collection', [])
    total_value = sum(card.get('price', 0) for card in collection)
    
    return render_template('collection.html', 
                          collection=collection, 
                          total_value=total_value)


@app.route('/api/collection/add', methods=['POST'])
def api_add_to_collection():
    """Add a card to the collection."""
    data = request.get_json()
    
    if 'collection' not in session:
        session['collection'] = []
    
    card = {
        'id': len(session['collection']) + 1,
        'name': data.get('name'),
        'set': data.get('set'),
        'price': data.get('price', 0),
        'image_uri': data.get('image_uri', ''),
        'added_date': datetime.now().isoformat()
    }
    
    session['collection'].append(card)
    session.modified = True
    
    return jsonify({'success': True, 'card': card})


@app.route('/api/collection/remove/<int:card_id>', methods=['DELETE'])
def api_remove_from_collection(card_id):
    """Remove a card from the collection."""
    if 'collection' not in session:
        return jsonify({'error': 'Collection not found'}), 404
    
    session['collection'] = [c for c in session['collection'] if c.get('id') != card_id]
    session.modified = True
    
    return jsonify({'success': True})


@app.route('/api/collection/export', methods=['GET'])
def api_export_collection():
    """Export collection as JSON."""
    collection = session.get('collection', [])
    
    export_data = {
        'exported_date': datetime.now().isoformat(),
        'total_cards': len(collection),
        'total_value': sum(card.get('price', 0) for card in collection),
        'cards': collection
    }
    
    return jsonify(export_data)


@app.route('/api/collection/clear', methods=['POST'])
def api_clear_collection():
    """Clear the entire collection."""
    session['collection'] = []
    session.modified = True
    
    return jsonify({'success': True})


@app.errorhandler(413)
def too_large(e):
    """Handle file too large error."""
    return jsonify({'error': 'File is too large. Maximum size is 16MB'}), 413


if __name__ == '__main__':
    # Run the app in debug mode for development
    app.run(debug=True, host='0.0.0.0', port=5000)
