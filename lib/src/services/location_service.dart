import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationService extends ChangeNotifier {
  Position? _currentPosition;
  bool _isLocationServiceEnabled = false;
  bool _hasLocationPermission = false;
  StreamSubscription<Position>? _positionStreamSubscription;

  Position? get currentPosition => _currentPosition;
  bool get isLocationServiceEnabled => _isLocationServiceEnabled;
  bool get hasLocationPermission => _hasLocationPermission;

  Future<void> initialize() async {
    try {
      _isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
      
      if (!_isLocationServiceEnabled) {
        debugPrint('Location services are disabled');
        notifyListeners();
        return;
      }
      
      await _checkLocationPermission();
      
      if (_isLocationServiceEnabled && _hasLocationPermission) {
        await getCurrentLocation();
        _startLocationTracking();
      }
    } catch (e) {
      debugPrint('Error initializing location service: $e');
    }
    
    notifyListeners();
  }

  Future<void> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately
      _hasLocationPermission = false;
      debugPrint('Location permissions are permanently denied');
      return;
    }

    _hasLocationPermission = permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
        
    if (!_hasLocationPermission) {
      debugPrint('Location permission denied: $permission');
    }
  }

  Future<Position?> getCurrentLocation() async {
    if (!_isLocationServiceEnabled) {
      debugPrint('Location services are disabled');
      return null;
    }
    
    if (!_hasLocationPermission) {
      debugPrint('Location permission not granted');
      return null;
    }

    try {
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      notifyListeners();
      return _currentPosition;
    } catch (e) {
      debugPrint('Error getting current location: $e');
      // Try with lower accuracy if high accuracy fails
      try {
        _currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 15),
        );
        notifyListeners();
        return _currentPosition;
      } catch (e2) {
        debugPrint('Error getting location with medium accuracy: $e2');
        return null;
      }
    }
  }

  void _startLocationTracking() {
    try {
      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 100, // Update when user moves 100 meters
          timeLimit: Duration(seconds: 10),
        ),
      ).listen(
        (Position position) {
          _currentPosition = position;
          notifyListeners();
        },
        onError: (error) {
          debugPrint('Error in location stream: $error');
          // Try to restart with lower accuracy
          _restartLocationTracking();
        },
      );
    } catch (e) {
      debugPrint('Error starting location tracking: $e');
    }
  }
  
  void _restartLocationTracking() {
    _positionStreamSubscription?.cancel();
    
    // Restart with medium accuracy
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        distanceFilter: 200, // Update when user moves 200 meters
        timeLimit: Duration(seconds: 15),
      ),
    ).listen(
      (Position position) {
        _currentPosition = position;
        notifyListeners();
      },
      onError: (error) {
        debugPrint('Error in location stream (medium accuracy): $error');
      },
    );
  }

  Future<void> requestLocationPermission() async {
    try {
      // First check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _isLocationServiceEnabled = false;
        debugPrint('Location services are disabled');
        notifyListeners();
        return;
      }
      
      _isLocationServiceEnabled = true;
      
      // Check current permission status
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.deniedForever) {
        // Permissions are denied forever, user needs to enable manually
        debugPrint('Location permissions are permanently denied, please enable manually in app settings');
        _hasLocationPermission = false;
        notifyListeners();
        return;
      }
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      
      _hasLocationPermission = permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;
      
      if (_hasLocationPermission) {
        await getCurrentLocation();
        _startLocationTracking();
      } else {
        debugPrint('Location permission denied: $permission');
      }
    } catch (e) {
      debugPrint('Error requesting location permission: $e');
      _hasLocationPermission = false;
    }
    
    notifyListeners();
  }

  Future<void> openLocationSettings() async {
    try {
      await Geolocator.openLocationSettings();
    } catch (e) {
      debugPrint('Error opening location settings: $e');
    }
  }
  
  Future<void> openAppSettings() async {
    try {
      await Geolocator.openAppSettings();
    } catch (e) {
      debugPrint('Error opening app settings: $e');
    }
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000; // km
  }

  String formatDistance(double distanceInKm) {
    if (distanceInKm < 1) {
      return '${(distanceInKm * 1000).round()} m';
    } else {
      return '${distanceInKm.toStringAsFixed(1)} km';
    }
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }
}