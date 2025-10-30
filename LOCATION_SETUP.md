# Location and Maps Setup Guide

## Android Permissions Setup ✅

The following permissions have been added to `android/app/src/main/AndroidManifest.xml`:

### Location Permissions
- `ACCESS_FINE_LOCATION` - For precise location (GPS)
- `ACCESS_COARSE_LOCATION` - For approximate location (Network)
- `ACCESS_BACKGROUND_LOCATION` - For background location updates

### Additional Permissions
- `INTERNET` - For network requests and maps
- `ACCESS_NETWORK_STATE` - For checking network connectivity
- `CAMERA` - For QR code scanning (Phase 3)
- `WRITE_EXTERNAL_STORAGE` - For saving photos/files
- `READ_EXTERNAL_STORAGE` - For reading photos/files

## Google Maps API Setup

### 1. Get Google Maps API Key
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing project
3. Enable the following APIs:
   - Maps SDK for Android
   - Maps SDK for iOS
   - Maps JavaScript API (for web)
   - Places API (optional, for place search)
   - Geocoding API (optional, for address conversion)

### 2. Create API Key
1. Go to "Credentials" in Google Cloud Console
2. Click "Create Credentials" > "API Key"
3. Copy the generated API key

### 3. Configure API Key

#### For Android:
Replace `YOUR_GOOGLE_MAPS_API_KEY` in `android/app/src/main/AndroidManifest.xml`:
```xml
<meta-data android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_ACTUAL_API_KEY_HERE"/>
```

#### For iOS:
Add to `ios/Runner/AppDelegate.swift`:
```swift
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("YOUR_ACTUAL_API_KEY_HERE")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

#### For Web:
Add to `web/index.html` before `</head>`:
```html
<script src="https://maps.googleapis.com/maps/api/js?key=YOUR_ACTUAL_API_KEY_HERE"></script>
```

## Location Service Features

The enhanced `LocationService` now includes:

### ✅ Robust Error Handling
- Graceful handling of disabled location services
- Permission denial detection
- Fallback to lower accuracy when needed
- Automatic retry mechanisms

### ✅ Multiple Accuracy Levels
- High accuracy (GPS) as primary
- Medium accuracy as fallback
- Configurable distance filters

### ✅ Permission Management
- Runtime permission requests
- Permanent denial detection
- Settings page navigation

### ✅ Service Status Checking
- Location service availability
- Network connectivity
- Battery optimization checks

## Testing Location Features

### Web Testing
- Chrome will request location permission
- Allow when prompted to test nearby cafés
- Works with IP-based approximate location

### Mobile Testing
- Install on physical device for best results
- GPS accuracy varies by environment
- Indoor locations may use network positioning

## Troubleshooting

### Common Issues:
1. **"Location services disabled"** - User needs to enable GPS in device settings
2. **"Permission denied forever"** - User needs to manually enable in app settings
3. **"No location found"** - Check network connection and try again
4. **Maps not loading** - Verify API key is correctly configured

### Debug Information:
The LocationService provides detailed debug logs:
- Permission status changes
- Location accuracy fallbacks
- Error conditions and retries

## Security Best Practices

### API Key Security:
- Restrict API key to specific platforms
- Set usage quotas and monitoring
- Never commit API keys to version control
- Use environment variables in production

### Location Privacy:
- Request permissions only when needed
- Explain why location is required
- Provide opt-out options
- Handle permission denials gracefully

## Next Steps

1. **Set up Google Maps API key** following the guide above
2. **Test on physical device** for accurate GPS
3. **Configure API restrictions** for security
4. **Monitor API usage** to stay within quotas

The location and maps features are now ready for production use!