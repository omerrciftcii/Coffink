# Google Maps API Setup for Coffink

## Issue
The map screen was crashing because the Google Maps API key is missing or invalid.

## What I Fixed
1. **Added Error Handling**: The map screen now gracefully handles missing API key
2. **Added Fallback UI**: Shows a user-friendly error message instead of crashing
3. **Added Cafe List**: Alternative way to view cafes when map fails
4. **Enhanced Crashlytics**: Better error reporting for map-related issues

## Current Status
- App won't crash anymore when clicking the map screen
- Shows "Harita Yüklenemedi" (Map Could Not Load) message
- Provides "Kafe Listesi" (Cafe List) as alternative
- All crashes are now reported to Firebase Crashlytics

## To Enable Google Maps (Optional)

### Step 1: Get Google Maps API Key
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project or create a new one
3. Enable "Maps SDK for Android" API
4. Go to "Credentials" → "Create Credentials" → "API Key"
5. Restrict the API key to "Maps SDK for Android"
6. Add your app's package name: `com.example.coffink`
7. Add your app's SHA-1 fingerprint

### Step 2: Update AndroidManifest.xml
Replace `PLACEHOLDER_API_KEY` in `android/app/src/main/AndroidManifest.xml`:

```xml
<meta-data android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_ACTUAL_API_KEY_HERE"/>
```

### Step 3: Rebuild the App
```bash
flutter clean
flutter build apk --release
```

## Testing
- The app now works without crashes
- Map functionality is gracefully disabled when API key is missing
- Users can still access cafe information through the list view
- All errors are tracked in Firebase Crashlytics

## Alternative Solutions
If you don't want to set up Google Maps:
1. **Use the cafe list**: Works perfectly without maps
2. **Remove map screen**: Can be hidden from navigation
3. **Use OpenStreetMap**: Alternative mapping solution

The app is now stable and crash-free!