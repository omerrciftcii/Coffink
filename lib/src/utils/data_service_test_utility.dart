import 'package:geolocator/geolocator.dart';

import '../services/data_service.dart';
import 'logger.dart';

/// Utility class to test DataService functionality and error handling
class DataServiceTestUtility {
  final DataService _dataService;

  DataServiceTestUtility(this._dataService) {
    Logger.info('DataServiceTestUtility initialized', name: 'DataServiceTestUtility');
  }

  /// Comprehensive test of all DataService methods
  Future<void> runComprehensiveTest() async {
    Logger.info('Starting comprehensive DataService test', name: 'DataServiceTestUtility');
    
    try {
      await _testConnectivity();
      await _testCoffeeOperations();
      await _testCafeOperations();
      await _testErrorHandling();
      await _testStreamOperations();
      
      Logger.info('All DataService tests completed successfully', name: 'DataServiceTestUtility');
    } catch (e) {
      Logger.error('DataService test failed: $e', name: 'DataServiceTestUtility');
      rethrow;
    }
  }

  /// Test connectivity functionality
  Future<void> _testConnectivity() async {
    Logger.info('Testing connectivity...', name: 'DataServiceTestUtility');
    
    try {
      final isConnected = await _dataService.checkConnectivity();
      Logger.info('Connectivity test result: $isConnected', name: 'DataServiceTestUtility');
      
      if (!isConnected) {
        Logger.warning('No Firebase connection detected', name: 'DataServiceTestUtility');
      }
    } catch (e) {
      Logger.error('Connectivity test failed: $e', name: 'DataServiceTestUtility');
      throw Exception('Connectivity test failed: $e');
    }
  }

  /// Test coffee-related operations
  Future<void> _testCoffeeOperations() async {
    Logger.info('Testing coffee operations...', name: 'DataServiceTestUtility');
    
    try {
      // Test getCoffees
      Logger.info('Testing getCoffees()', name: 'DataServiceTestUtility');
      final allCoffees = await _dataService.getCoffees();
      Logger.info('Retrieved ${allCoffees.length} coffees', name: 'DataServiceTestUtility');
      
      // Test getCoffees with category
      if (allCoffees.isNotEmpty) {
        final firstCoffeeCategory = allCoffees.first.category;
        Logger.info('Testing getCoffees(category: $firstCoffeeCategory)', name: 'DataServiceTestUtility');
        final categoryCoffees = await _dataService.getCoffees(category: firstCoffeeCategory);
        Logger.info('Retrieved ${categoryCoffees.length} coffees in category $firstCoffeeCategory', 
                   name: 'DataServiceTestUtility');
      }
      
      // Test getCoffeeById
      if (allCoffees.isNotEmpty) {
        final firstCoffeeId = allCoffees.first.id;
        Logger.info('Testing getCoffeeById($firstCoffeeId)', name: 'DataServiceTestUtility');
        final coffee = await _dataService.getCoffeeById(firstCoffeeId);
        
        if (coffee != null) {
          Logger.info('Successfully retrieved coffee: ${coffee.name}', name: 'DataServiceTestUtility');
        } else {
          Logger.warning('getCoffeeById returned null for existing ID', name: 'DataServiceTestUtility');
        }
      }
      
      // Test getPopularCoffees
      Logger.info('Testing getPopularCoffees()', name: 'DataServiceTestUtility');
      final popularCoffees = await _dataService.getPopularCoffees(limit: 5);
      Logger.info('Retrieved ${popularCoffees.length} popular coffees', name: 'DataServiceTestUtility');
      
      // Test invalid coffee ID
      Logger.info('Testing getCoffeeById with invalid ID', name: 'DataServiceTestUtility');
      final invalidCoffee = await _dataService.getCoffeeById('invalid_id_12345');
      if (invalidCoffee == null) {
        Logger.info('Correctly returned null for invalid coffee ID', name: 'DataServiceTestUtility');
      } else {
        Logger.warning('Unexpectedly found coffee with invalid ID', name: 'DataServiceTestUtility');
      }
      
    } catch (e) {
      Logger.error('Coffee operations test failed: $e', name: 'DataServiceTestUtility');
      throw Exception('Coffee operations test failed: $e');
    }
  }

  /// Test cafe-related operations
  Future<void> _testCafeOperations() async {
    Logger.info('Testing cafe operations...', name: 'DataServiceTestUtility');
    
    try {
      // Test getCafes
      Logger.info('Testing getCafes()', name: 'DataServiceTestUtility');
      final allCafes = await _dataService.getCafes();
      Logger.info('Retrieved ${allCafes.length} cafes', name: 'DataServiceTestUtility');
      
      // Test getCafes with user location
      if (allCafes.isNotEmpty) {
        final testPosition = Position(
          latitude: 41.0082, // Istanbul coordinates
          longitude: 28.9784,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        );
        
        Logger.info('Testing getCafes with user location', name: 'DataServiceTestUtility');
        final sortedCafes = await _dataService.getCafes(userLocation: testPosition);
        Logger.info('Retrieved ${sortedCafes.length} cafes sorted by distance', name: 'DataServiceTestUtility');
      }
      
      // Test getCafeById
      if (allCafes.isNotEmpty) {
        final firstCafeId = allCafes.first.id;
        Logger.info('Testing getCafeById($firstCafeId)', name: 'DataServiceTestUtility');
        final cafe = await _dataService.getCafeById(firstCafeId);
        
        if (cafe != null) {
          Logger.info('Successfully retrieved cafe: ${cafe.name}', name: 'DataServiceTestUtility');
        } else {
          Logger.warning('getCafeById returned null for existing ID', name: 'DataServiceTestUtility');
        }
      }
      
      // Test getNearbyCafes
      if (allCafes.isNotEmpty) {
        final testPosition = Position(
          latitude: 41.0082,
          longitude: 28.9784,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        );
        
        Logger.info('Testing getNearbyCafes()', name: 'DataServiceTestUtility');
        final nearbyCafes = await _dataService.getNearbyCafes(testPosition, radiusKm: 10);
        Logger.info('Retrieved ${nearbyCafes.length} nearby cafes within 10km', name: 'DataServiceTestUtility');
      }
      
      // Test getPartnerCafes
      Logger.info('Testing getPartnerCafes()', name: 'DataServiceTestUtility');
      final partnerCafes = await _dataService.getPartnerCafes();
      Logger.info('Retrieved ${partnerCafes.length} partner cafes', name: 'DataServiceTestUtility');
      
      // Test invalid cafe ID
      Logger.info('Testing getCafeById with invalid ID', name: 'DataServiceTestUtility');
      final invalidCafe = await _dataService.getCafeById('invalid_id_12345');
      if (invalidCafe == null) {
        Logger.info('Correctly returned null for invalid cafe ID', name: 'DataServiceTestUtility');
      } else {
        Logger.warning('Unexpectedly found cafe with invalid ID', name: 'DataServiceTestUtility');
      }
      
    } catch (e) {
      Logger.error('Cafe operations test failed: $e', name: 'DataServiceTestUtility');
      throw Exception('Cafe operations test failed: $e');
    }
  }

  /// Test error handling and retry mechanisms
  Future<void> _testErrorHandling() async {
    Logger.info('Testing error handling...', name: 'DataServiceTestUtility');
    
    try {
      // Test with empty string IDs
      Logger.info('Testing error handling with empty IDs', name: 'DataServiceTestUtility');
      
      final emptyCoffee = await _dataService.getCoffeeById('');
      if (emptyCoffee == null) {
        Logger.info('Correctly handled empty coffee ID', name: 'DataServiceTestUtility');
      }
      
      final emptyCafe = await _dataService.getCafeById('');
      if (emptyCafe == null) {
        Logger.info('Correctly handled empty cafe ID', name: 'DataServiceTestUtility');
      }
      
      // Test refresh data
      Logger.info('Testing refreshData()', name: 'DataServiceTestUtility');
      await _dataService.refreshData();
      Logger.info('refreshData() completed successfully', name: 'DataServiceTestUtility');
      
    } catch (e) {
      Logger.error('Error handling test failed: $e', name: 'DataServiceTestUtility');
      throw Exception('Error handling test failed: $e');
    }
  }

  /// Test stream operations
  Future<void> _testStreamOperations() async {
    Logger.info('Testing stream operations...', name: 'DataServiceTestUtility');
    
    try {
      // Test coffee stream
      Logger.info('Testing getCoffeesStream()', name: 'DataServiceTestUtility');
      final coffeeStream = _dataService.getCoffeesStream();
      
      // Listen to first emission
      final coffeeSubscription = coffeeStream.take(1).listen(
        (coffees) {
          Logger.info('Coffee stream emitted ${coffees.length} coffees', name: 'DataServiceTestUtility');
        },
        onError: (error) {
          Logger.error('Coffee stream error: $error', name: 'DataServiceTestUtility');
        },
      );
      
      // Wait a bit for the stream to emit
      await Future.delayed(const Duration(seconds: 2));
      await coffeeSubscription.cancel();
      
      // Test cafe stream
      Logger.info('Testing getCafesStream()', name: 'DataServiceTestUtility');
      final cafeStream = _dataService.getCafesStream();
      
      // Listen to first emission
      final cafeSubscription = cafeStream.take(1).listen(
        (cafes) {
          Logger.info('Cafe stream emitted ${cafes.length} cafes', name: 'DataServiceTestUtility');
        },
        onError: (error) {
          Logger.error('Cafe stream error: $error', name: 'DataServiceTestUtility');
        },
      );
      
      // Wait a bit for the stream to emit
      await Future.delayed(const Duration(seconds: 2));
      await cafeSubscription.cancel();
      
      Logger.info('Stream operations test completed', name: 'DataServiceTestUtility');
      
    } catch (e) {
      Logger.error('Stream operations test failed: $e', name: 'DataServiceTestUtility');
      throw Exception('Stream operations test failed: $e');
    }
  }

  /// Test specific error scenarios
  Future<void> testErrorScenarios() async {
    Logger.info('Testing specific error scenarios...', name: 'DataServiceTestUtility');
    
    try {
      // Test network timeout simulation (this would require mocking)
      Logger.info('Note: Network timeout testing requires mocking', name: 'DataServiceTestUtility');
      
      // Test data parsing errors (this would require corrupted data)
      Logger.info('Note: Data parsing error testing requires corrupted test data', name: 'DataServiceTestUtility');
      
      // Test retry mechanism (this would require controlled failures)
      Logger.info('Note: Retry mechanism testing requires controlled failure simulation', name: 'DataServiceTestUtility');
      
      Logger.info('Error scenario testing completed (limited without mocking)', name: 'DataServiceTestUtility');
      
    } catch (e) {
      Logger.error('Error scenario testing failed: $e', name: 'DataServiceTestUtility');
      throw Exception('Error scenario testing failed: $e');
    }
  }

  /// Generate test report
  Future<Map<String, dynamic>> generateTestReport() async {
    Logger.info('Generating DataService test report...', name: 'DataServiceTestUtility');
    
    final report = <String, dynamic>{
      'timestamp': DateTime.now().toIso8601String(),
      'tests': <String, dynamic>{},
    };
    
    try {
      // Connectivity test
      final isConnected = await _dataService.checkConnectivity();
      report['tests']['connectivity'] = {
        'status': 'passed',
        'connected': isConnected,
      };
      
      // Coffee operations test
      final coffees = await _dataService.getCoffees();
      final popularCoffees = await _dataService.getPopularCoffees(limit: 3);
      
      report['tests']['coffee_operations'] = {
        'status': 'passed',
        'total_coffees': coffees.length,
        'popular_coffees': popularCoffees.length,
        'available_coffees': coffees.where((c) => c.isAvailable).length,
      };
      
      // Cafe operations test
      final cafes = await _dataService.getCafes();
      final partnerCafes = await _dataService.getPartnerCafes();
      
      report['tests']['cafe_operations'] = {
        'status': 'passed',
        'total_cafes': cafes.length,
        'partner_cafes': partnerCafes.length,
      };
      
      report['overall_status'] = 'passed';
      
    } catch (e) {
      report['overall_status'] = 'failed';
      report['error'] = e.toString();
      Logger.error('Test report generation failed: $e', name: 'DataServiceTestUtility');
    }
    
    Logger.info('Test report generated: ${report['overall_status']}', name: 'DataServiceTestUtility');
    return report;
  }
}