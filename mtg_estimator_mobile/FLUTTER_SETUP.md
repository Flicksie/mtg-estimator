# Flutter iOS App Setup

## Project Structure

The Flutter iOS app is now set up with a complete project structure:

```
lib/
├── main.dart                    # App entry point
├── models/
│   ├── card.dart               # MTG Card model
│   └── collection_item.dart    # Collection item model
├── services/
│   └── api_service.dart        # API communication with backend
├── providers/
│   ├── collection_provider.dart # State management for collection
│   └── search_provider.dart     # State management for search
└── screens/
    ├── home_screen.dart        # Main home screen
    ├── search_screen.dart      # Card search and details
    ├── collection_screen.dart  # User's collection view
    └── scanner_screen.dart     # Card scanning (camera integration)
```

## Setup Instructions

### 1. Install Dependencies

```bash
cd mtg_estimator_mobile
flutter pub get
```

### 2. Configure Backend URL

Edit `lib/services/api_service.dart` and update the base URL to match your backend:

```dart
static const String baseUrl = 'http://localhost:3000/api'; // Change to your backend URL
```

### 3. iOS-Specific Setup

#### Camera Permissions (for scanning)
Add to `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>Allow camera access to scan MTG cards</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Allow photo library access to import card images</string>
```

#### Xcode Configuration
Once Xcode is installed:

```bash
# Open the project in Xcode
open ios/Runner.xcworkspace
```

Then:
1. Select "Runner" in the project navigator
2. Update "Bundle Identifier" to match your needs
3. Set your development team under "Signing & Capabilities"
4. Configure provisioning profiles

### 4. Build Commands

```bash
# Run in development mode (requires iOS simulator or device)
flutter run -d ios

# Build for iOS (requires Xcode)
flutter build ios --release

# Build for App Store (requires Xcode and developer account)
flutter build ios --release
# Then follow Xcode submission instructions
```

## Features

### Home Screen
- Collection value overview
- Quick navigation to main features
- Scan, search, and collection management

### Search Screen
- Search cards by name
- View card details (price, rarity, set)
- Add cards to collection with quantity

### Collection Screen
- View all cards in your collection
- Display total collection value
- Remove cards from collection
- Pull-to-refresh functionality

### Scanner Screen
- Placeholder for camera integration
- Will support card identification from photos

## API Integration

The app connects to your Ruby backend with these endpoints:

- `GET /api/search?q=<query>` - Search cards
- `POST /api/identify` - Identify card from image
- `GET /api/collection/list` - Get user's collection
- `POST /api/collection/add` - Add card to collection
- `POST /api/collection/remove` - Remove card from collection
- `GET /api/stats` - Get collection statistics

## State Management

Uses **Provider** package for state management:

- **CollectionProvider**: Manages collection data and operations
- **SearchProvider**: Manages search results and card details

## Architecture

- **Clean separation of concerns** with models, services, providers, and screens
- **Responsive UI** with Material Design 3
- **Light and dark theme** support
- **Error handling** with user feedback
- **Loading states** for async operations

## Next Steps

1. **Install Xcode** (required for iOS builds)
2. **Configure backend URL** in `api_service.dart`
3. **Add camera permissions** to Info.plist
4. **Implement camera integration** in `scanner_screen.dart`
5. **Test with iOS simulator** or physical device

## Additional Packages

Current dependencies:
- `provider: ^6.0.0` - State management
- `http: ^1.1.0` - API communication
- `image_picker: ^1.0.0` - Image selection
- `camera: ^0.10.0` - Camera access
- `intl: ^0.19.0` - Internationalization

## Notes

- The app requires iOS 11.0 or higher
- Backend must be running for full functionality
- Image picker and camera require proper permissions
