# MTG Card Estimator

A Ruby application to detect Magic: The Gathering cards in images and estimate their market value using the Scryfall API.

## Features

- **Web Interface**: Modern, responsive web application with Sinatra and Vue.js
- **Card Detection**: Detect multiple MTG cards in a single image
- **OCR Recognition**: Automatic card name extraction using Tesseract OCR
- **Price Estimation**: Fetch current market prices from Scryfall API
- **Card Search**: Search for any MTG card and view detailed information
- **Collection Management**: Track your card collection with pricing
- **Responsive Design**: Mobile-friendly interface using Bulma CSS
- **Interactive Frontend**: Vue.js 3 for dynamic user interactions

## Tech Stack

- **Backend**: Ruby with Sinatra web framework
- **Frontend**: Vue.js 3 with Bulma CSS
- **API**: Scryfall API for card data and pricing

## Installation

```bash
git clone https://github.com/Flicksie/mtg-estimator.git
cd mtg-estimator
bundle install
```

## Usage

Run the web server:
```bash
ruby app.rb
```

Then open your browser and navigate to http://localhost:5000

## License

MIT License - see LICENSE file for details
