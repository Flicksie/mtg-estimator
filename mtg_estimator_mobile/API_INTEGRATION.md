# API Integration Documentation

## Backend Requirements

Your Flutter iOS app connects to your Ruby backend. Ensure these endpoints exist:

### 1. Search Endpoint
```http
GET /api/search?q=card_name
```

**Expected Response:**
```json
{
  "cards": [
    {
      "id": "card_id_123",
      "name": "Black Lotus",
      "set": "Alpha",
      "rarity": "R",
      "price": 50000.00,
      "image_url": "https://..."
    }
  ]
}
```

### 2. Card Identification (from image)
```http
POST /api/identify
Content-Type: multipart/form-data

file: <image_file>
```

**Expected Response:**
```json
{
  "card": {
    "id": "card_id_456",
    "name": "Ancestral Recall",
    "set": "Alpha",
    "rarity": "R",
    "price": 100000.00,
    "image_url": "https://..."
  }
}
```

### 3. Get Collection
```http
GET /api/collection/list
```

**Expected Response:**
```json
{
  "items": [
    {
      "id": "item_789",
      "card": {
        "id": "card_id",
        "name": "Mox Sapphire",
        "set": "Alpha",
        "rarity": "R",
        "price": 12000.00,
        "image_url": "https://..."
      },
      "quantity": 1,
      "added_at": "2026-02-05T01:30:00Z"
    }
  ]
}
```

### 4. Add to Collection
```http
POST /api/collection/add
Content-Type: application/json

{
  "card_id": "card_id_123",
  "quantity": 2
}
```

**Expected Response:**
```json
{
  "success": true,
  "item_id": "item_123"
}
```

### 5. Remove from Collection
```http
POST /api/collection/remove
Content-Type: application/json

{
  "item_id": "item_123"
}
```

**Expected Response:**
```json
{
  "success": true
}
```

### 6. Get Statistics
```http
GET /api/stats
```

**Expected Response:**
```json
{
  "total_cards": 150,
  "total_value": 25000.00,
  "average_card_value": 166.67,
  "rarity_distribution": {
    "Common": 50,
    "Uncommon": 40,
    "Rare": 35,
    "Mythic": 25
  }
}
```

## Configuration

Update the API base URL in `lib/services/api_service.dart`:

```dart
// For local development
static const String baseUrl = 'http://localhost:3000/api';

// For production
static const String baseUrl = 'https://api.yourdomain.com/api';
```

## Error Handling

The app expects HTTP status codes:
- `200`: Success
- `400`: Bad request
- `401`: Unauthorized
- `404`: Not found
- `500`: Server error

Any non-200 response will be treated as an error and displayed to the user.

## Network Configuration

### iOS Network Requirements

For iOS 9+, App Transport Security (ATS) is enabled by default.

**For local development (http://localhost):**
Add to `ios/Runner/Info.plist`:

```xml
<key>NSLocalNetworkUsageDescription</key>
<string>Access local network to connect to development server</string>
<key>NSBonjourServices</key>
<array>
  <string>_http._tcp</string>
  <string>_https._tcp</string>
</array>
```

**For production (https://):**
No additional configuration needed - HTTPS is required.

## Testing the Backend

Use your existing test script:

```bash
ruby test_api.rb
```

Or test individual endpoints:

```bash
# Search
curl "http://localhost:3000/api/search?q=Black%20Lotus"

# Get collection
curl "http://localhost:3000/api/collection/list"

# Get stats
curl "http://localhost:3000/api/stats"
```

## Timeout Configuration

Current timeouts in `api_service.dart`:
- Regular requests: 10 seconds
- Card identification: 30 seconds

Adjust in `api_service.dart` as needed:

```dart
.timeout(const Duration(seconds: 10))
```

## CORS Configuration

If running on different domain/port, ensure your Ruby backend allows CORS:

```ruby
# In config/initializers/cors.rb
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'localhost:3000', 'localhost:8080'
    resource '*', headers: :any, methods: [:get, :post, :put, :delete]
  end
end
```

## Authentication (Future)

To add authentication, modify `api_service.dart`:

```dart
static Future<List<Card>> searchCards(String query, String token) async {
  final response = await http.get(
    Uri.parse('$baseUrl/search?q=$query'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  ).timeout(const Duration(seconds: 10));
  // ...
}
```

## Rate Limiting

Implement rate limiting in your backend if needed. The app makes requests for:
- Each search keystroke (debounce recommended)
- Collection loading on app start
- Manual refresh pulls
- Card additions/removals

Consider implementing:
- Request debouncing (already done with provider)
- API rate limiting
- Response caching
