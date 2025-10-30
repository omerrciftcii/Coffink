import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../features/home/models/coffee_model.dart';
import '../features/cafe/models/cafe_model.dart';
import '../utils/logger.dart';

/// Firebase'den gerçek veri çeken, error handling ve retry mekanizması olan gelişmiş veri servisi
class EnhancedDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);

  EnhancedDataService() {
    Logger.info('EnhancedDataService initialized', name: 'EnhancedDataService');
  }

  // COFFEE OPERATIONS

  /// Tüm kahveleri Firebase'den çeker (retry mekanizması ile)
  Future<List<Coffee>> getCoffees({String? category}) async {
    Logger.logMethodCall('EnhancedDataService', 'getCoffees',
                        parameters: {'category': category});

    return await _retryOperation(() async {
      Logger.dataOperation('Fetching coffees from Firebase', name: 'EnhancedDataService');

      Query query = _firestore.collection('coffees');
      
      if (category != null && category.isNotEmpty) {
        query = query.where('category', isEqualTo: category);
        Logger.dataOperation('Filtering by category: $category', name: 'EnhancedDataService');
      }

      final snapshot = await Logger.timeOperation(
        'Fetch Coffees Query',
        () => query.get(),
        name: 'EnhancedDataService',
      );

      if (snapshot.docs.isEmpty) {
        Logger.warning('No coffees found in database', name: 'EnhancedDataService');
        return <Coffee>[];
      }

      final coffees = <Coffee>[];
      for (final doc in snapshot.docs) {
        try {
          final coffee = Coffee.fromMap(doc.data() as Map<String, dynamic>, doc.id);
          if (coffee.isAvailable) {
            coffees.add(coffee);
          }
        } catch (e) {
          Logger.error('Error parsing coffee document ${doc.id}: $e', name: 'EnhancedDataService');
          // Continue with other documents instead of failing completely
        }
      }

      Logger.dataOperation('Successfully fetched ${coffees.length} available coffees', 
                         name: 'EnhancedDataService');
      return coffees;
    });
  }

  /// Belirli bir kahveyi ID ile çeker
  Future<Coffee?> getCoffeeById(String coffeeId) async {
    Logger.logMethodCall('EnhancedDataService', 'getCoffeeById',
                        parameters: {'coffeeId': coffeeId});

    if (coffeeId.isEmpty) {
      Logger.warning('Empty coffee ID provided', name: 'EnhancedDataService');
      return null;
    }

    return await _retryOperation(() async {
      Logger.dataOperation('Fetching coffee by ID: $coffeeId', name: 'EnhancedDataService');

      final doc = await Logger.timeOperation(
        'Fetch Coffee by ID',
        () => _firestore.collection('coffees').doc(coffeeId).get(),
        name: 'EnhancedDataService',
      );

      if (!doc.exists || doc.data() == null) {
        Logger.warning('Coffee not found with ID: $coffeeId', name: 'EnhancedDataService');
        return null;
      }

      try {
        final coffee = Coffee.fromMap(doc.data()!, doc.id);
        Logger.dataOperation('Successfully fetched coffee: ${coffee.name}', name: 'EnhancedDataService');
        return coffee;
      } catch (e) {
        Logger.error('Error parsing coffee document $coffeeId: $e', name: 'EnhancedDataService');
        return null;
      }
    });
  }

  /// Kategoriye göre kahveleri çeker
  Future<List<Coffee>> getCoffeesByCategory(String category) async {
    Logger.logMethodCall('EnhancedDataService', 'getCoffeesByCategory',
                        parameters: {'category': category});

    return await getCoffees(category: category);
  }

  /// Popüler kahveleri çeker (rating ve review count'a göre)
  Future<List<Coffee>> getPopularCoffees({int limit = 10}) async {
    Logger.logMethodCall('EnhancedDataService', 'getPopularCoffees',
                        parameters: {'limit': limit});

    return await _retryOperation(() async {
      Logger.dataOperation('Fetching popular coffees', name: 'EnhancedDataService');

      final snapshot = await Logger.timeOperation(
        'Fetch Popular Coffees',
        () => _firestore.collection('coffees')
            .where('isAvailable', isEqualTo: true)
            .orderBy('basePrice') // Basit sıralama, gerçek uygulamada popularity score olabilir
            .limit(limit)
            .get(),
        name: 'EnhancedDataService',
      );

      final coffees = <Coffee>[];
      for (final doc in snapshot.docs) {
        try {
          final coffee = Coffee.fromMap(doc.data(), doc.id);
          coffees.add(coffee);
        } catch (e) {
          Logger.error('Error parsing popular coffee document ${doc.id}: $e', name: 'EnhancedDataService');
        }
      }

      Logger.dataOperation('Successfully fetched ${coffees.length} popular coffees', 
                         name: 'EnhancedDataService');
      return coffees;
    });
  }

  // CAFE OPERATIONS

  /// Tüm kafeleri Firebase'den çeker
  Future<List<Cafe>> getCafes({Position? userLocation}) async {
    Logger.logMethodCall('EnhancedDataService', 'getCafes',
                        parameters: {'hasUserLocation': userLocation != null});

    return await _retryOperation(() async {
      Logger.dataOperation('Fetching cafes from Firebase', name: 'EnhancedDataService');

      final snapshot = await Logger.timeOperation(
        'Fetch Cafes Query',
        () => _firestore.collection('cafes').get(),
        name: 'EnhancedDataService',
      );

      if (snapshot.docs.isEmpty) {
        Logger.warning('No cafes found in database', name: 'EnhancedDataService');
        return <Cafe>[];
      }

      final cafes = <Cafe>[];
      for (final doc in snapshot.docs) {
        try {
          final cafe = Cafe.fromFirestore(doc);

          // TODO: Kullanıcı konumu varsa mesafe hesapla ve cafe objesine ekle
          // Mesafe bilgisini cafe objesine eklemek için copyWith methodu gerekebilir

          cafes.add(cafe);
        } catch (e) {
          Logger.error('Error parsing cafe document ${doc.id}: $e', name: 'EnhancedDataService');
        }
      }

      // Kullanıcı konumu varsa mesafeye göre sırala
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
        Logger.dataOperation('Sorted cafes by distance from user location', name: 'EnhancedDataService');
      }

      Logger.dataOperation('Successfully fetched ${cafes.length} cafes', 
                         name: 'EnhancedDataService');
      return cafes;
    });
  }

  /// Belirli bir kafeyi ID ile çeker
  Future<Cafe?> getCafeById(String cafeId) async {
    Logger.logMethodCall('EnhancedDataService', 'getCafeById',
                        parameters: {'cafeId': cafeId});

    if (cafeId.isEmpty) {
      Logger.warning('Empty cafe ID provided', name: 'EnhancedDataService');
      return null;
    }

    return await _retryOperation(() async {
      Logger.dataOperation('Fetching cafe by ID: $cafeId', name: 'EnhancedDataService');

      final doc = await Logger.timeOperation(
        'Fetch Cafe by ID',
        () => _firestore.collection('cafes').doc(cafeId).get(),
        name: 'EnhancedDataService',
      );

      if (!doc.exists) {
        Logger.warning('Cafe not found with ID: $cafeId', name: 'EnhancedDataService');
        return null;
      }

      try {
        final cafe = Cafe.fromFirestore(doc);
        Logger.dataOperation('Successfully fetched cafe: ${cafe.name}', name: 'EnhancedDataService');
        return cafe;
      } catch (e) {
        Logger.error('Error parsing cafe document $cafeId: $e', name: 'EnhancedDataService');
        return null;
      }
    });
  }

  /// Yakındaki kafeleri çeker (belirli bir yarıçap içinde)
  Future<List<Cafe>> getNearbyCafes(Position userLocation, {double radiusKm = 5.0}) async {
    Logger.logMethodCall('EnhancedDataService', 'getNearbyCafes',
                        parameters: {
                          'latitude': userLocation.latitude,
                          'longitude': userLocation.longitude,
                          'radiusKm': radiusKm,
                        });

    return await _retryOperation(() async {
      Logger.dataOperation('Fetching nearby cafes within ${radiusKm}km', name: 'EnhancedDataService');

      // Firebase'de coğrafi sorgular için GeoFlutterFire kullanılabilir
      // Şimdilik tüm kafeleri çekip mesafeye göre filtreliyoruz
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
                         name: 'EnhancedDataService');
      return nearbyCafes;
    });
  }

  /// Partner kafeleri çeker
  Future<List<Cafe>> getPartnerCafes() async {
    Logger.logMethodCall('EnhancedDataService', 'getPartnerCafes');

    return await _retryOperation(() async {
      Logger.dataOperation('Fetching partner cafes', name: 'EnhancedDataService');

      final snapshot = await Logger.timeOperation(
        'Fetch Partner Cafes',
        () => _firestore.collection('cafes')
            .where('isPartner', isEqualTo: true)
            .get(),
        name: 'EnhancedDataService',
      );

      final cafes = <Cafe>[];
      for (final doc in snapshot.docs) {
        try {
          final cafe = Cafe.fromFirestore(doc);
          cafes.add(cafe);
        } catch (e) {
          Logger.error('Error parsing partner cafe document ${doc.id}: $e', name: 'EnhancedDataService');
        }
      }

      Logger.dataOperation('Successfully fetched ${cafes.length} partner cafes', 
                         name: 'EnhancedDataService');
      return cafes;
    });
  }

  // UTILITY METHODS

  /// İki nokta arasındaki mesafeyi hesaplar (Haversine formülü)
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000; // km cinsinden
  }

  /// Retry mekanizması ile operasyon çalıştırır
  Future<T> _retryOperation<T>(Future<T> Function() operation) async {
    int attempts = 0;
    
    while (attempts < _maxRetries) {
      try {
        return await operation();
      } catch (e) {
        attempts++;
        Logger.warning('Operation failed (attempt $attempts/$_maxRetries): $e', 
                      name: 'EnhancedDataService');
        
        if (attempts >= _maxRetries) {
          Logger.error('Operation failed after $attempts attempts: $e', 
                      name: 'EnhancedDataService');
          rethrow;
        }
        
        // Exponential backoff
        final delay = Duration(milliseconds: _retryDelay.inMilliseconds * attempts);
        Logger.info('Retrying in ${delay.inMilliseconds}ms...', name: 'EnhancedDataService');
        await Future.delayed(delay);
      }
    }
    
    throw Exception('Retry operation failed unexpectedly');
  }

  /// Bağlantı durumunu kontrol eder
  Future<bool> checkConnectivity() async {
    try {
      // Basit bir Firestore sorgusu ile bağlantıyı test et
      await _firestore.collection('_connectivity_test').limit(1).get();
      Logger.info('Connectivity check passed', name: 'EnhancedDataService');
      return true;
    } catch (e) {
      Logger.warning('Connectivity check failed: $e', name: 'EnhancedDataService');
      return false;
    }
  }

  /// Veri yenileme işlemi
  Future<void> refreshData() async {
    Logger.info('Refreshing all data', name: 'EnhancedDataService');
    
    try {
      // Cache'i temizle (eğer cache servisi varsa)
      // await _cacheService.clearCache();
      
      Logger.info('Data refresh completed', name: 'EnhancedDataService');
    } catch (e) {
      Logger.error('Error refreshing data: $e', name: 'EnhancedDataService');
      rethrow;
    }
  }

  // STREAM OPERATIONS (Real-time data)

  /// Kahveleri real-time olarak dinler
  Stream<List<Coffee>> getCoffeesStream({String? category}) {
    Logger.info('Starting coffee stream', name: 'EnhancedDataService');
    
    Query query = _firestore.collection('coffees');
    
    if (category != null && category.isNotEmpty) {
      query = query.where('category', isEqualTo: category);
    }

    return query.snapshots().map((snapshot) {
      final coffees = <Coffee>[];
      
      for (final doc in snapshot.docs) {
        try {
          final coffee = Coffee.fromMap(doc.data() as Map<String, dynamic>, doc.id);
          if (coffee.isAvailable) {
            coffees.add(coffee);
          }
        } catch (e) {
          Logger.error('Error parsing coffee in stream ${doc.id}: $e', name: 'EnhancedDataService');
        }
      }
      
      Logger.dataOperation('Stream updated with ${coffees.length} coffees', 
                         name: 'EnhancedDataService');
      return coffees;
    }).handleError((error) {
      Logger.error('Error in coffee stream: $error', name: 'EnhancedDataService');
    });
  }

  /// Kafeleri real-time olarak dinler
  Stream<List<Cafe>> getCafesStream() {
    Logger.info('Starting cafe stream', name: 'EnhancedDataService');
    
    return _firestore.collection('cafes').snapshots().map((snapshot) {
      final cafes = <Cafe>[];
      
      for (final doc in snapshot.docs) {
        try {
          final cafe = Cafe.fromFirestore(doc);
          cafes.add(cafe);
        } catch (e) {
          Logger.error('Error parsing cafe in stream ${doc.id}: $e', name: 'EnhancedDataService');
        }
      }
      
      Logger.dataOperation('Stream updated with ${cafes.length} cafes', 
                         name: 'EnhancedDataService');
      return cafes;
    }).handleError((error) {
      Logger.error('Error in cafe stream: $error', name: 'EnhancedDataService');
    });
  }
}