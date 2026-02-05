# iOS App Configuration Guide

## Overview

Your Flutter iOS app is now fully structured and ready for development. It integrates with your Ruby on Rails backend API.

## Quick Start

1. **Backend Configuration**
   - Update the API base URL in `lib/services/api_service.dart`
   - Ensure your Ruby backend is running on the configured port

2. **iOS Permissions**
   - Camera and photo library permissions are configured in `ios/Runner/Info.plist`
   - Users will be prompted for permission when needed

3. **Build for iOS**
   ```bash
   cd mtg_estimator_mobile
   flutter build ios --release
   ```

## App Features

### Home Screen
- Collection value summary
- Quick access buttons to main features
- Shows total estimated collection worth

### Search Feature
- Search for MTG cards by name
- View card details (price, rarity, set, image)
- Add cards to collection with quantity

### Collection Management
- View all cards in your collection
- Display total collection value
- Remove cards
- Pull-to-refresh to sync with backend

### Scanner (Placeholder)
- Ready for camera integration
- Will identify cards from photos
- Uses your backend's OCR service

## Backend Integration

The app expects these API endpoints:

```
GET  /api/search?q=card_name
POST /api/identify
GET  /api/collection/list
POST /api/collection/add
POST /api/collection/remove
GET  /api/stats
```

## Configuration Files

### API Service
**File:** `lib/services/api_service.dart`

Update this line with your backend URL:
```dart
static const String baseUrl = 'http://localhost:3000/api';
```

For remote servers:
```dart
static const String baseUrl = 'https://your-domain.com/api';
```

### iOS Info.plist
**Location:** `ios/Runner/Info.plist`

Already configured with:
- Camera usage permission
- Photo library usage permission

### Xcode Project Settings
**Location:** `ios/Runner.xcodeproj`

When opening in Xcode:
1. Set your Team ID
2. Update Bundle Identifier (e.g., `com.yourcompany.mtgestimator`)
3. Configure signing certificates
4. Set minimum iOS deployment target (11.0+)

## State Management

The app uses **Provider** for state management:

### CollectionProvider
Manages:
- List of cards in collection
- Total collection value
- Collection statistics
- Add/remove operations

### SearchProvider
Manages:
- Search results
- Selected card details
- Card identification from images
- Search state and errors

## Testing

### Local Testing
```bash
# Run on iOS simulator
flutter run -d ios

# Run on connected iOS device
flutter run -d ios
```

### API Testing
Use your existing `test_api.rb` script to verify backend endpoints:
```bash
ruby test_api.rb
```

## Build Variants

### Development Build
```bash
flutter run -d ios
```

### Release Build (App Store)
```bash
flutter build ios --release
flutter build ipa
```

## Error Handling

The app includes:
- Network error handling with user feedback
- Loading states during async operations
- Error messages displayed in UI
- Automatic retry mechanisms

## Next Steps

1. ✅ Project structure complete
2. ✅ Dependencies installed
3. ✅ Models and services created
4. ✅ UI screens built
5. ⏳ Install Xcode (required for builds)
6. ⏳ Configure backend URL
7. ⏳ Test with iOS simulator
8. ⏳ Implement camera integration
9. ⏳ Deploy to App Store

## File Structure

```
mtg_estimator_mobile/
├── lib/
│   ├── main.dart                 # App setup and routing
│   ├── models/                   # Data models
│   │   ├── card.dart
│   │   └── collection_item.dart
│   ├── services/                 # API and external services
│   │   └── api_service.dart
│   ├── providers/                # State management
│   │   ├── collection_provider.dart
│   │   └── search_provider.dart
│   └── screens/                  # UI screens
│       ├── home_screen.dart
│       ├── search_screen.dart
│       ├── collection_screen.dart
│       └── scanner_screen.dart
├── ios/                          # iOS-specific code
├── pubspec.yaml                  # Dependencies and configuration
└── FLUTTER_SETUP.md              # Setup documentation
```

## Troubleshooting

### "Application not configured for iOS"
- Xcode is not installed
- Run: `xcode-select --install`

### API Connection Issues
- Verify backend is running
- Check API base URL in `api_service.dart`
- Ensure device/simulator can reach backend

### Build Failures
- Run: `flutter clean`
- Then: `flutter pub get`
- Finally: `flutter build ios --release`

## Support

For issues:
1. Check the Flutter documentation: https://flutter.dev
2. Review your backend API endpoints
3. Check app logs: `flutter logs`
4. Verify iOS simulator or device has network access
