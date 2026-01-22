# MTG Card Estimator

A Ruby application to detect Magic: The Gathering cards in images and estimate their market value using the Scryfall API.

## Features

- **Web Interface**: Modern, responsive Vue.js 3 SPA with Vite
- **Card Detection**: Detect multiple MTG cards in a single image
- **OCR Recognition**: Automatic card name extraction using Gemini Vision AI
- **Price Estimation**: Fetch current market prices from Scryfall API
- **Card Search**: Search for any MTG card and view detailed information
- **Collection Management**: Track your card collection with pricing
- **Responsive Design**: Mobile-friendly interface using Bulma CSS
- **Interactive Frontend**: Vue.js 3 with TypeScript and Vue Router

## Tech Stack

- **Backend**: Ruby 3.2+ with Sinatra web framework (API server)
- **Frontend**: Vue.js 3 with TypeScript, Vue Router, and Vite
- **Styling**: Bulma CSS
- **API**: Scryfall API for card data and pricing

## Installation

### Prerequisites

- Ruby 3.2+
- Node.js 18+ and npm
- Gemini API key for automatic card recognition

### Clone and Setup

```bash
git clone https://github.com/Flicksie/mtg-estimator.git
cd mtg-estimator
```

### Backend Setup

```bash
# Install Ruby dependencies
bundle install
```

### Frontend Setup

```bash
# Navigate to frontend directory
cd frontend

# Install Node dependencies
npm install

# Build for production
npm run build
```

## Usage

### Development Mode

For development, you'll run the backend and frontend servers separately:

#### Start Backend API Server (Terminal 1)

```bash
ruby app.rb
```

This starts the API server on http://localhost:5000

#### Start Frontend Dev Server (Terminal 2)

```bash
cd frontend
npm run dev
```

This starts the Vite dev server on http://localhost:5173

The Vite dev server proxies API requests to the backend, so you can develop with hot module replacement.

### Production Mode

For production, build the frontend and serve everything from the backend:

```bash
# Build frontend
cd frontend
npm run build
cd ..

# Start backend (which serves the built frontend)
ruby app.rb
```

Then open your browser and navigate to http://localhost:5000

## API Endpoints

### Statistics
- `GET /api/stats` - Get collection statistics and OCR status

### Card Search
- `POST /api/search` - Search for a card by name

### Card Scanner
- `POST /api/scan` - Upload and scan card images
- `POST /api/identify` - Identify cards from manual names

### Collection Management
- `GET /api/collection/list` - Get all cards in collection
- `POST /api/collection/add` - Add a card to collection
- `DELETE /api/collection/remove/:card_id` - Remove a card
- `GET /api/collection/export` - Export collection as JSON
- `POST /api/collection/clear` - Clear entire collection

## Project Structure

```
mtg-estimator/
├── frontend/              # Vue.js 3 SPA
│   ├── src/
│   │   ├── components/   # Reusable Vue components
│   │   ├── views/        # Page components
│   │   ├── router/       # Vue Router configuration
│   │   ├── services/     # API service layer
│   │   ├── types/        # TypeScript type definitions
│   │   └── assets/       # Static assets and styles
│   ├── index.html        # Entry HTML
│   ├── package.json      # Frontend dependencies
│   └── vite.config.ts    # Vite configuration
├── app.rb                # Sinatra application (API server)
├── card_detector.rb      # Card detection service
├── card_recognizer.rb    # Card recognition service
├── price_fetcher.rb      # Price fetching service
├── ocr_service.rb        # OCR service
└── Gemfile               # Backend dependencies
```

## License

MIT License - see LICENSE file for details
