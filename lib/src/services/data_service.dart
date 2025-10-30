import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'dart:io';

import '../features/home/models/coffee_model.dart';
import '../features/cafe/models/cafe_model.dart';
import '../utils/logger.dart';

/// Comprehensive data service that integrates with Firebase
/// Provides error handling, retry mechanisms, and real data access
class DataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Retry configuration
  static const int _maxRetries = 3;
  static const Duration _baseRetryDelay = Duration(seconds: 1);
  static const Duration _connectionTimeout = Duration(seconds: 10);
  
  // Cache for connection status
  bool _isConnected = true;
  Timer? _connectionCheckTimer;

  DataService() {
    Logger.info('DataService initialized with enhanced error handling', name: 'DataService');
    _startConnectionMonitoring();
  }

  // CONNECTION MANAGEMENT

  /// Starts monitoring Firebase connection status
  void _startConnectionMonitoring() {
    _connectionCheckTimer = Timer.periodic(Duration(minutes: 1), (_) {
      _checkConnectionStatus();
    });
  }

  /// Checks Firebase connection status
  Future<void> _checkConnectionStatus() async {
    try {
      await _firestore.collection('_connection_test')
          .limit(1)
          .get()
          .timeout(_connectionTimeout);
      
      if (!_isConnected) {
        _isConnected = true;
        Logger.info('Firebase connection restored', name: 'DataService');
      }
    } catch (e) {
      if (_isConnected) {
        _isConnected = false;
        Logger.warning('Firebase connection lost: $e', name: 'DataService');
      }
    }
  }

  /// Public method to check connectivity
  Future<bool> checkConnectivity() async {
    try {
      await _firestore.collection('_connection_test')
          .limit(1)
          .get()
          .timeout(_connectionTimeout);
      _isConnected = true;
      return true;
    } catch (e) {
      _isConnected = false;
      Logger.warning('Connectivity check failed: $e', name: 'DataService');
      return false;
    }
  }

  // COFFEE OPERATIONS

  /// Gets all coffees with enhanced error handling and retry
  Future<List<Coffee>> getCoffees({String? category}) async {
    Logger.logMethodCall('DataService', 'getCoffees', 
                        parameters: {'category': category});

    return await _executeWithRetry<List<Coffee>>(
      operation: () async {
        Logger.dataOperation('Fetching coffees from Firebase', name: 'DataService');

        Query query = _firestore.collection('coffees');
        
        if (category != null && category.isNotEmpty) {
          query = query.where('category', isEqualTo: category);
          Logger.dataOperation('Filtering by category: $category', name: 'DataService');
        }

        final snapshot = await query
            .get()
            .timeout(_connectionTimeout);

        if (snapshot.docs.isEmpty) {
          Logger.warning('No coffees found in database', name: 'DataService');
          return <Coffee>[];
        }

        final coffees = <Coffee>[];
        final errors = <String>[];

        for (final doc in snapshot.docs) {
          try {
            final coffee = Coffee.fromMap(doc.data() as Map<String, dynamic>, doc.id);
            if (coffee.isAvailable) {
              coffees.add(coffee);
            }
          } catch (e) {
            errors.add('Error parsing coffee document ${doc.id}: $e');
            Logger.error('Error parsing coffee document ${doc.id}: $e', name: 'DataService');
          }
        }

        // Log parsing errors summary
        if (errors.isNotEmpty) {
          Logger.warning('${errors.length} coffee documents failed to parse', name: 'DataService');
        }

        Logger.dataOperation('Successfully fetched ${coffees.length} available coffees', 
                           name: 'DataService');
        return coffees;
      },
      operationName: 'getCoffees',
    );
  }

  /// Gets coffee by ID with enhanced error handling
  Future<Coffee?> getCoffeeById(String coffeeId) async {
    Logger.logMethodCall('DataService', 'getCoffeeById',
                        parameters: {'coffeeId': coffeeId});

    if (coffeeId.isEmpty) {
      Logger.warning('Empty coffee ID provided', name: 'DataService');
      return null;
    }

    return await _executeWithRetry<Coffee?>(
      operation: () async {
        Logger.dataOperation('Fetching coffee by ID: $coffeeId', name: 'DataService');

        final doc = await _firestore.collection('coffees')
            .doc(coffeeId)
            .get()
            .timeout(_connectionTimeout);

        if (!doc.exists || doc.data() == null) {
          Logger.warning('Coffee not found with ID: $coffeeId', name: 'DataService');
          return null;
        }

        try {
          final coffee = Coffee.fromMap(doc.data()!, doc.id);
          Logger.dataOperation('Successfully fetched coffee: ${coffee.name}', name: 'DataService');
          return coffee;
        } catch (e) {
          Logger.error('Error parsing coffee document $coffeeId: $e', name: 'DataService');
          throw DataParsingException('Failed to parse coffee data: $e');
        }
      },
      operationName: 'getCoffeeById',
    );
  }

  /// Gets popular coffees with enhanced error handling
  Future<List<Coffee>> getPopularCoffees({int limit = 10}) async {
    Logger.logMethodCall('DataService', 'getPopularCoffees',
                        parameters: {'limit': limit});

    return await _executeWithRetry<List<Coffee>>(
      operation: () async {
        Logger.dataOperation('Fetching popular coffees', name: 'DataService');

        final snapshot = await _firestore.collection('coffees')
            .where('isAvailable', isEqualTo: true)
            .orderBy('basePrice')
            .limit(limit)
            .get()
            .timeout(_connectionTimeout);

        final coffees = <Coffee>[];
        for (final doc in snapshot.docs) {
          try {
            final coffee = Coffee.fromMap(doc.data(), doc.id);
            coffees.add(coffee);
          } catch (e) {
            Logger.error('Error parsing popular coffee document ${doc.id}: $e', name: 'DataService');
          }
        }

        Logger.dataOperation('Successfully fetched ${coffees.length} popular coffees', 
                           name: 'DataService');
        return coffees;
      },
      operationName: 'getPopularCoffees',
    );
  }

  /// Gets coffee stream with error handling
  Stream<List<Coffee>> getCoffeesStream({String? category}) {
    Logger.info('Starting coffee stream', name: 'DataService');
    
    Query query = _firestore.collection('coffees');
    
    if (category != null && category.isNotEmpty) {
      query = query.where('category', isEqualTo: category);
    }

    return query.snapshots().map((snapshot) {
      final coffees = <Coffee>[];
      final errors = <String>[];
      
      for (final doc in snapshot.docs) {
        try {
          final coffee = Coffee.fromMap(doc.data() as Map<String, dynamic>, doc.id);
          if (coffee.isAvailable) {
            coffees.add(coffee);
          }
        } catch (e) {
          errors.add('Error parsing coffee in stream ${doc.id}: $e');
          Logger.error('Error parsing coffee in stream ${doc.id}: $e', name: 'DataService');
        }
      }
      
      if (errors.isNotEmpty) {
        Logger.warning('${errors.length} coffee documents failed to parse in stream', name: 'DataService');
      }
      
      Logger.dataOperation('Stream updated with ${coffees.length} coffees', 
                         name: 'DataService');
      return coffees;
    }).handleError((error) {
      Logger.error('Error in coffee stream: $error', name: 'DataService');
      // Return empty list on stream error
      return <Coffee>[];
    });
  }

  // CAFE OPERATIONS

  /// Gets all cafes with enhanced error handling
  Future<List<Cafe>> getCafes({Position? userLocation}) async {
    Logger.logMethodCall('DataService', 'getCafes',
                        parameters: {'hasUserLocation': userLocation != null});

    return await _executeWithRetry<List<Cafe>>(
      operation: () async {
        Logger.dataOperation('Fetching cafes from Firebase', name: 'DataService');

        final snapshot = await _firestore.collection('cafes')
            .get()
            .timeout(_connectionTimeout);

        if (snapshot.docs.isEmpty) {
          Logger.warning('No cafes found in database', name: 'DataService');
          return <Cafe>[];
        }

        final cafes = <Cafe>[];
        final errors = <String>[];

        for (final doc in snapshot.docs) {
          try {
            final cafe = Cafe.fromFirestore(doc);
            cafes.add(cafe);
          } catch (e) {
            errors.add('Error parsing cafe document ${doc.id}: $e');
            Logger.error('Error parsing cafe document ${doc.id}: $e', name: 'DataService');
          }
        }

        // Log parsing errors summary
        if (errors.isNotEmpty) {
          Logger.warning('${errors.length} cafe documents failed to parse', name: 'DataService');
        }

        // Sort by distance if user location is provided
        if (userLocation != null) {
          cafes.sort((a, b) {
            final distanceA = _calculateDistance(
              userLocation.latitude, userLocation.longitude,
              a.latitude, a.longitude,
            );
            final distanceB = _calculateDistance(
              userLocation.latitude, userLocation.longitude,
              b.latitude, b.longitude,
            );
            return distanceA.compareTo(distanceB);
          });
          Logger.dataOperation('Sorted cafes by distance from user location', name: 'DataService');
        }

        Logger.dataOperation('Successfully fetched ${cafes.length} cafes', 
                           name: 'DataService');
        return cafes;
      },
      operationName: 'getCafes',
    );
  }

  /// Gets cafe by ID with enhanced error handling
  Future<Cafe?> getCafeById(String cafeId) async {
    Logger.logMethodCall('DataService', 'getCafeById',
                        parameters: {'cafeId': cafeId});

    if (cafeId.isEmpty) {
      Logger.warning('Empty cafe ID provided', name: 'DataService');
      return null;
    }

    return await _executeWithRetry<Cafe?>(
      operation: () async {
        Logger.dataOperation('Fetching cafe by ID: $cafeId', name: 'DataService');

        final doc = await _firestore.collection('cafes')
            .doc(cafeId)
            .get()
            .timeout(_connectionTimeout);

        if (!doc.exists) {
          Logger.warning('Cafe not found with ID: $cafeId', name: 'DataService');
          return null;
        }

        try {
          final cafe = Cafe.fromFirestore(doc);
          Logger.dataOperation('Successfully fetched cafe: ${cafe.name}', name: 'DataService');
          return cafe;
        } catch (e) {
          Logger.error('Error parsing cafe document $cafeId: $e', name: 'DataService');
          throw DataParsingException('Failed to parse cafe data: $e');
        }
      },
      operationName: 'getCafeById',
    );
  }

  /// Gets nearby cafes with enhanced error handling
  Future<List<Cafe>> getNearbyCafes(Position userLocation, {double radiusKm = 5.0}) async {
    Logger.logMethodCall('DataService', 'getNearbyCafes',
                        parameters: {
                          'latitude': userLocation.latitude,
                          'longitude': userLocation.longitude,
                          'radiusKm': radiusKm,
                        });

    return await _executeWithRetry<List<Cafe>>(
      operation: () async {
        Logger.dataOperation('Fetching nearby cafes within ${radiusKm}km', name: 'DataService');

        // Get all cafes first, then filter by distance
        final allCafes = await getCafes(userLocation: userLocation);
        
        final nearbyCafes = allCafes.where((cafe) {
          final distance = _calculateDistance(
            userLocation.latitude,
            userLocation.longitude,
            cafe.latitude,
            cafe.longitude,
          );
          return distance <= radiusKm;
        }).toList();

        Logger.dataOperation('Found ${nearbyCafes.length} cafes within ${radiusKm}km', 
                           name: 'DataService');
        return nearbyCafes;
      },
      operationName: 'getNearbyCafes',
    );
  }

  /// Gets partner cafes with enhanced error handling
  Future<List<Cafe>> getPartnerCafes() async {
    Logger.logMethodCall('DataService', 'getPartnerCafes');

    return await _executeWithRetry<List<Cafe>>(
      operation: () async {
        Logger.dataOperation('Fetching partner cafes', name: 'DataService');

        final snapshot = await _firestore.collection('cafes')
            .where('isPartner', isEqualTo: true)
            .get()
            .timeout(_connectionTimeout);

        final cafes = <Cafe>[];
        for (final doc in snapshot.docs) {
          try {
            final cafe = Cafe.fromFirestore(doc);
            cafes.add(cafe);
          } catch (e) {
            Logger.error('Error parsing partner cafe document ${doc.id}: $e', name: 'DataService');
          }
        }

        Logger.dataOperation('Successfully fetched ${cafes.length} partner cafes', 
                           name: 'DataService');
        return cafes;
      },
      operationName: 'getPartnerCafes',
    );
  }

  /// Gets cafe stream with error handling
  Stream<List<Cafe>> getCafesStream() {
    Logger.info('Starting cafe stream', name: 'DataService');
    
    return _firestore.collection('cafes').snapshots().map((snapshot) {
      final cafes = <Cafe>[];
      final errors = <String>[];
      
      for (final doc in snapshot.docs) {
        try {
          final cafe = Cafe.fromFirestore(doc);
          cafes.add(cafe);
        } catch (e) {
          errors.add('Error parsing cafe in stream ${doc.id}: $e');
          Logger.error('Error parsing cafe in stream ${doc.id}: $e', name: 'DataService');
        }
      }
      
      if (errors.isNotEmpty) {
        Logger.warning('${errors.length} cafe documents failed to parse in stream', name: 'DataService');
      }
      
      Logger.dataOperation('Stream updated with ${cafes.length} cafes', 
                         name: 'DataService');
      return cafes;
    }).handleError((error) {
      Logger.error('Error in cafe stream: $error', name: 'DataService');
      // Return empty list on stream error
      return <Cafe>[];
    });
  }

  // UTILITY METHODS

  /// Calculates distance between two points using Haversine formula
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000; // km
  }

  /// Enhanced retry mechanism with exponential backoff and specific error handling
  Future<T> _executeWithRetry<T>({
    required Future<T> Function() operation,
    required String operationName,
  }) async {
    int attempts = 0;
    Exception? lastException;
    
    while (attempts < _maxRetries) {
      try {
        // Check connection before attempting operation
        if (!_isConnected && attempts > 0) {
          await _checkConnectionStatus();
          if (!_isConnected) {
            throw NetworkException('No Firebase connection available');
          }
        }

        return await operation();
        
      } catch (e) {
        attempts++;
        lastException = e is Exception ? e : Exception(e.toString());
        
        Logger.warning('$operationName failed (attempt $attempts/$_maxRetries): $e', 
                      name: 'DataService');
        
        // Don't retry certain types of errors
        if (_shouldNotRetry(e)) {
          Logger.error('$operationName failed with non-retryable error: $e', 
                      name: 'DataService');
          throw lastException;
        }
        
        if (attempts >= _maxRetries) {
          Logger.error('$operationName failed after $attempts attempts: $e', 
                      name: 'DataService');
          throw DataServiceException('$operationName failed after $attempts attempts', lastException);
        }
        
        // Exponential backoff with jitter
        final delay = Duration(
          milliseconds: _baseRetryDelay.inMilliseconds * (1 << (attempts - 1)) + 
                       (DateTime.now().millisecondsSinceEpoch % 1000)
        );
        
        Logger.info('Retrying $operationName in ${delay.inMilliseconds}ms...', name: 'DataService');
        await Future.delayed(delay);
      }
    }
    
    throw DataServiceException('$operationName failed unexpectedly', lastException);
  }

  /// Determines if an error should not be retried
  bool _shouldNotRetry(dynamic error) {
    // Don't retry parsing errors
    if (error is DataParsingException) return true;
    
    // Don't retry permission errors
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
        case 'unauthenticated':
        case 'invalid-argument':
          return true;
      }
    }
    
    // Don't retry timeout errors after first attempt (they're likely persistent)
    if (error is TimeoutException) return false;
    
    // Don't retry socket errors (network issues)
    if (error is SocketException) return false;
    
    return false;
  }

  /// Refreshes all cached data
  Future<void> refreshData() async {
    Logger.info('Refreshing all data', name: 'DataService');
    
    try {
      // Force connection check
      await _checkConnectionStatus();
      
      if (!_isConnected) {
        throw NetworkException('Cannot refresh data: No Firebase connection');
      }
      
      Logger.info('Data refresh completed', name: 'DataService');
    } catch (e) {
      Logger.error('Error refreshing data: $e', name: 'DataService');
      throw DataServiceException('Failed to refresh data', e is Exception ? e : Exception(e.toString()));
    }
  }

  /// Disposes resources
  void dispose() {
    _connectionCheckTimer?.cancel();
    Logger.info('DataService disposed', name: 'DataService');
  }
}

// CUSTOM EXCEPTIONS

/// Base exception for data service errors
class DataServiceException implements Exception {
  final String message;
  final Exception? cause;
  
  const DataServiceException(this.message, [this.cause]);
  
  @override
  String toString() => 'DataServiceException: $message${cause != null ? ' (caused by: $cause)' : ''}';
}

/// Exception for data parsing errors
class DataParsingException implements Exception {
  final String message;
  
  const DataParsingException(this.message);
  
  @override
  String toString() => 'DataParsingException: $message';
}

/// Exception for network-related errors
class NetworkException implements Exception {
  final String message;
  
  const NetworkException(this.message);
  
  @override
  String toString() => 'NetworkException: $message';
}