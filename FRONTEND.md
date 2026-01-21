# Frontend Documentation

## Overview

The MTG Card Estimator frontend is a Single Page Application (SPA) built with Vue.js 3, TypeScript, and Vite. It provides a modern, responsive interface for searching cards, scanning images, and managing collections.

## Technology Stack

- **Framework**: Vue.js 3 with Composition API
- **Language**: TypeScript
- **Build Tool**: Vite 5
- **Routing**: Vue Router 4
- **Styling**: Bulma CSS + Custom CSS
- **Icons**: Font Awesome 6
- **HTTP Client**: Native Fetch API

## Project Structure

```
frontend/
├── src/
│   ├── main.ts              # Application entry point
│   ├── App.vue              # Root component with layout
│   ├── router/
│   │   └── index.ts         # Vue Router configuration
│   ├── views/               # Page components
│   │   ├── Home.vue         # Dashboard/landing page
│   │   ├── Search.vue       # Card search page
│   │   ├── Scanner.vue      # Image scanning page
│   │   └── Collection.vue   # Collection management page
│   ├── components/          # Reusable components
│   │   ├── Navbar.vue       # Navigation bar
│   │   └── Footer.vue       # Footer component
│   ├── services/
│   │   └── api.ts           # API service layer
│   ├── types/
│   │   └── index.ts         # TypeScript type definitions
│   └── assets/
│       └── styles/
│           └── custom.css   # Custom CSS styles
├── index.html               # Entry HTML file
├── package.json             # Dependencies and scripts
├── vite.config.ts           # Vite configuration
└── tsconfig.json            # TypeScript configuration
```

## Key Components

### Views

#### Home.vue
- Dashboard with collection statistics
- Feature cards linking to main pages
- "How It Works" section
- OCR availability warning

#### Search.vue
- Card search with autocomplete
- Display card details (image, name, set, price)
- Add to collection functionality
- Link to Scryfall for more details

#### Scanner.vue
- File upload for card images
- Automatic OCR identification (if available)
- Manual card name entry
- Display identified cards with pricing
- Batch add to collection

#### Collection.vue
- Display all cards in collection
- Total value calculation
- Export to JSON
- Remove individual cards
- Clear entire collection

### Components

#### Navbar.vue
- Responsive navigation bar
- Mobile hamburger menu
- Active route highlighting
- Links to all main pages

#### Footer.vue
- Copyright notice
- Scryfall attribution
- Dynamic year display

## API Service

The `api.ts` service provides a centralized interface for all API calls:

### Methods

- `getStats()` - Fetch collection statistics
- `searchCard(query)` - Search for a card
- `scanImage(file)` - Upload and scan image
- `identifyCards(names)` - Identify cards by name
- `getCollection()` - Get all collection cards
- `addToCollection(card)` - Add card to collection
- `removeFromCollection(id)` - Remove card
- `exportCollection()` - Export as JSON
- `clearCollection()` - Clear all cards

### Configuration

The API base URL is configurable via environment variable:
```typescript
const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:5000'
```

## Development Workflow

### Setup

```bash
cd frontend
npm install
```

### Development Server

```bash
npm run dev
```

Runs Vite dev server on http://localhost:5173 with:
- Hot Module Replacement (HMR)
- API proxy to backend on port 5000
- TypeScript type checking

### Production Build

```bash
npm run build
```

Builds optimized assets to `dist/` directory:
- Minified JavaScript bundles
- Optimized CSS
- Tree-shaking for smaller bundle size
- Static assets with cache busting

### Preview Build

```bash
npm run preview
```

Preview production build locally before deployment.

## Routing

Vue Router is configured with HTML5 history mode:

| Route | Component | Description |
|-------|-----------|-------------|
| `/` | Home.vue | Dashboard |
| `/search` | Search.vue | Card search |
| `/scanner` | Scanner.vue | Image scanner |
| `/collection` | Collection.vue | Collection management |

## State Management

The application uses Vue's Composition API for local state management. Session state (collection) is managed on the backend via cookies.

## Styling

### Bulma CSS

Base styling framework providing:
- Responsive grid system
- Form components
- Buttons and controls
- Cards and boxes
- Notifications and modals

### Custom Styles

Located in `src/assets/styles/custom.css`:
- Card hover effects
- Layout adjustments
- Color overrides
- Responsive breakpoints
- Loading states

## TypeScript Types

All API responses and data structures are typed in `src/types/index.ts`:

- `Card` - Card data structure
- `Prices` - Price information
- `SearchResult` - Search API response
- `Stats` - Statistics data
- `ScanResult` - Scan API response
- `IdentifyResult` - Identify API response
- `CollectionExport` - Export data structure

## Best Practices

1. **Type Safety**: All components use TypeScript with strict mode
2. **Composition API**: Modern Vue 3 syntax with `<script setup>`
3. **API Abstraction**: All API calls go through the centralized service
4. **Error Handling**: Try-catch blocks with user-friendly error messages
5. **Loading States**: Visual feedback for async operations
6. **Responsive Design**: Mobile-first approach with Bulma
7. **Accessibility**: Semantic HTML and ARIA labels

## Building for Production

1. Build the frontend:
   ```bash
   cd frontend
   npm run build
   ```

2. The `dist/` folder is configured as Sinatra's public folder

3. Start the backend to serve the SPA:
   ```bash
   cd ..
   ruby app.rb
   ```

4. The backend serves the built SPA and handles API routes

## Troubleshooting

### API Connection Issues

If the frontend can't reach the API:

1. Check backend is running on port 5000
2. Verify CORS headers in development mode
3. Check Vite proxy configuration in `vite.config.ts`

### Build Errors

If TypeScript errors occur:

1. Run `npm install` to ensure dependencies are installed
2. Check type definitions in `src/types/index.ts`
3. Verify all imported modules exist

### Styling Issues

If styles don't apply:

1. Ensure Bulma is imported in `main.ts`
2. Check custom CSS file is imported
3. Verify Font Awesome CDN is loaded in `index.html`

## Future Enhancements

Potential improvements:

- Vuex/Pinia for advanced state management
- Unit tests with Vitest
- E2E tests with Playwright
- Progressive Web App (PWA) features
- Offline support with service workers
- Advanced card filtering and sorting
- Deck building features
- Price history charts
