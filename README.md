# MTG Card Estimator

A Python application to detect Magic: The Gathering cards in images and estimate their market value using the Scryfall API.

## Features

- **Web Interface**: Modern, responsive web application with Flask
- **Card Detection**: Detect multiple MTG cards in a single image using computer vision
- **OCR Recognition**: Automatic card name extraction using Tesseract OCR
- **Price Estimation**: Fetch current market prices from Scryfall API
- **Card Search**: Search for any MTG card and view detailed information
- **Collection Management**: Track your card collection with pricing
- **Export Functionality**: Export collection data to JSON
- **Multiple Cards Support**: Process and estimate the value of multiple cards at once
- **Set Information**: Identify specific card printings when possible
- **Responsive Design**: Mobile-friendly interface using Bootstrap
- **CLI Interface**: Easy-to-use command-line interface

## Installation

1. Clone the repository:
```bash
git clone https://github.com/Flicksie/mtg-estimator.git
cd mtg-estimator
```

2. Install dependencies:
```bash
pip install -r requirements.txt
```

3. (Optional) Install Tesseract OCR for automatic card name recognition:
   - **Ubuntu/Debian**: `sudo apt-get install tesseract-ocr`
   - **macOS**: `brew install tesseract`
   - **Windows**: Download installer from [GitHub](https://github.com/UB-Mannheim/tesseract/wiki)

## Usage

### Web Application (Recommended)

Run the web server:
```bash
python app.py
```

Then open your browser and navigate to `http://localhost:5000`

The web interface provides:
- **Home/Dashboard**: Overview of your collection and features
- **Card Search**: Search for any MTG card by name
- **Card Scanner**: Upload images of cards for automatic identification
- **Collection View**: Manage your card collection and export data

### Command Line Interface

The MTG Estimator also provides three main CLI commands:

#### 1. Estimate Card Values by Name

Estimate the value of cards when you know their names:

```bash
python mtg_estimator.py estimate "Black Lotus" "Lightning Bolt" "Tarmogoyf"
```

#### 2. Search for a Specific Card

Search for detailed information about a specific card:

```bash
python mtg_estimator.py search "Lightning Bolt"
```

#### 3. Process an Image with Cards

Detect cards in an image and optionally provide their names for pricing:

```bash
# Detect cards in image (card detection only)
python mtg_estimator.py image path/to/cards.jpg

# Detect cards and estimate value with provided names
python mtg_estimator.py image path/to/cards.jpg --cards "Black Lotus" "Mox Sapphire"
```

## Examples

### Example 1: Estimate Card Value
```bash
$ python mtg_estimator.py estimate "Lightning Bolt" "Counterspell"

============================================================
PRICE ESTIMATION
============================================================
  Lightning Bolt: $0.50
  Counterspell: $0.75

Total Estimated Value: $1.25
Found: 2/2
```

### Example 2: Search for a Card
```bash
$ python mtg_estimator.py search "Black Lotus"

============================================================
CARD INFORMATION
============================================================
Name: Black Lotus
Set: Limited Edition Alpha (lea)

Prices:
  usd: $30000.00

More info: https://scryfall.com/card/lea/232/black-lotus
```

### Example 3: Process an Image
```bash
$ python mtg_estimator.py image cards.jpg --cards "Lightning Bolt" "Counterspell"

Processing image: cards.jpg
Detected 2 card(s) in the image

Using provided card names: Lightning Bolt, Counterspell

============================================================
RESULTS
============================================================
  Lightning Bolt: $0.50
  Counterspell: $0.75

Total Estimated Value: $1.25
```

## How It Works

1. **Card Detection**: The application uses OpenCV to detect rectangular shapes that match MTG card dimensions (aspect ratio ~0.714 for portrait orientation)

2. **Card Recognition**: 
   - **Web App**: Upload images and use OCR (Tesseract) to automatically extract card names, or provide names manually
   - **CLI**: Supports manual card name input for identified cards

3. **Price Fetching**: Queries the Scryfall API to fetch current market prices in USD, EUR, and foil variants

4. **Value Calculation**: Aggregates prices for all detected/specified cards to provide a total estimated value

5. **Collection Management**: Store and track your card collection with real-time value updates

## API Used

This application uses the [Scryfall API](https://scryfall.com/docs/api) to fetch card information and prices. Scryfall is a comprehensive MTG card database that provides:
- Card names and details
- Set information
- Current market prices from TCGPlayer and other sources
- High-quality card images

## Limitations

- **OCR Recognition**: Automatic card name recognition works best with clear, well-lit images. Tesseract OCR is optional but recommended
- **Image Quality**: Card detection works best with clear, well-lit images
- **Price Accuracy**: Prices are fetched from Scryfall and may not reflect real-time market fluctuations
- **Set Detection**: Currently uses the default printing; specific set identification from images requires additional work
- **Session Storage**: Collection data is stored in browser sessions (web app). Use export functionality to save your data

## Future Enhancements

- [x] Web interface for easier image uploads
- [x] OCR integration for automatic card name recognition (Tesseract OCR)
- [ ] Machine learning model for better card detection
- [ ] Support for identifying specific card printings from artwork
- [ ] Support for more price sources (TCGPlayer direct API, Card Kingdom, etc.)
- [ ] Batch processing of multiple images
- [ ] Database backend for persistent collection storage
- [ ] User authentication and multi-user support

## Dependencies

- `opencv-python`: Computer vision for card detection
- `numpy`: Numerical operations
- `requests`: HTTP requests to Scryfall API
- `Pillow`: Image processing
- `python-dotenv`: Environment variable management
- `Flask`: Web application framework
- `pytesseract`: OCR for card name extraction (optional, requires Tesseract OCR installed)
- `Werkzeug`: WSGI utilities for Flask

## License

MIT License - see LICENSE file for details

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Disclaimer

This tool is for estimation purposes only. Actual card values may vary based on condition, market demand, and other factors. Always verify prices with official marketplaces before making purchasing decisions.