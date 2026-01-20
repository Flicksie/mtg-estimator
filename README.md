# MTG Card Estimator

A Python application to detect Magic: The Gathering cards in images and estimate their market value using the Scryfall API.

## Features

- **Card Detection**: Detect multiple MTG cards in a single image using computer vision
- **Price Estimation**: Fetch current market prices from Scryfall API
- **Multiple Cards Support**: Process and estimate the value of multiple cards at once
- **Set Information**: Identify specific card printings when possible
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

## Usage

The MTG Estimator provides three main commands:

### 1. Estimate Card Values by Name

Estimate the value of cards when you know their names:

```bash
python mtg_estimator.py estimate "Black Lotus" "Lightning Bolt" "Tarmogoyf"
```

### 2. Search for a Specific Card

Search for detailed information about a specific card:

```bash
python mtg_estimator.py search "Lightning Bolt"
```

### 3. Process an Image with Cards

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

2. **Card Recognition**: Currently supports manual card name input. Automatic OCR-based recognition can be added in the future using libraries like Tesseract

3. **Price Fetching**: Queries the Scryfall API to fetch current market prices in USD, EUR, and foil variants

4. **Value Calculation**: Aggregates prices for all detected/specified cards to provide a total estimated value

## API Used

This application uses the [Scryfall API](https://scryfall.com/docs/api) to fetch card information and prices. Scryfall is a comprehensive MTG card database that provides:
- Card names and details
- Set information
- Current market prices from TCGPlayer and other sources
- High-quality card images

## Limitations

- **OCR Recognition**: Automatic card name recognition from images requires OCR integration (not yet implemented)
- **Image Quality**: Card detection works best with clear, well-lit images
- **Price Accuracy**: Prices are fetched from Scryfall and may not reflect real-time market fluctuations
- **Set Detection**: Currently uses the default printing; specific set identification from images requires additional work

## Future Enhancements

- [ ] OCR integration for automatic card name recognition (Tesseract OCR)
- [ ] Machine learning model for better card detection
- [ ] Support for identifying specific card printings from artwork
- [ ] Web interface for easier image uploads
- [ ] Support for more price sources (TCGPlayer direct API, Card Kingdom, etc.)
- [ ] Batch processing of multiple images
- [ ] Export results to CSV/JSON

## Dependencies

- `opencv-python`: Computer vision for card detection
- `numpy`: Numerical operations
- `requests`: HTTP requests to Scryfall API
- `Pillow`: Image processing
- `python-dotenv`: Environment variable management

## License

MIT License - see LICENSE file for details

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Disclaimer

This tool is for estimation purposes only. Actual card values may vary based on condition, market demand, and other factors. Always verify prices with official marketplaces before making purchasing decisions.