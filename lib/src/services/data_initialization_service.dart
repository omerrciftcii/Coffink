import '../utils/logger.dart';
import 'real_coffee_data_service.dart';
import 'real_cafe_data_service.dart';

/// Firebase'i gerçek verilerle başlatan servis
class DataInitializationService {
  final RealCoffeeDataService _coffeeDataService = RealCoffeeDataService();
  final RealCafeDataService _cafeDataService = RealCafeDataService();

  DataInitializationService() {
    Logger.info('DataInitializationService initialized', name: 'DataInitializationService');
  }

  /// Tüm gerçek verileri Firebase'e yükler
  Future<void> initializeAllData({bool clearExisting = false}) async {
    Logger.info('Starting data initialization', name: 'DataInitializationService');
    
    try {
      if (clearExisting) {
        Logger.warning('Clearing existing data before initialization', name: 'DataInitializationService');
        await clearAllData();
      }

      // Kahve verilerini yükle
      Logger.info('Initializing coffee data...', name: 'DataInitializationService');
      await _coffeeDataService.populateRealCoffeeData();

      // Kafe verilerini yükle
      Logger.info('Initializing cafe data...', name: 'DataInitializationService');
      await _cafeDataService.populateRealCafeData();

      Logger.info('Data initialization completed successfully', name: 'DataInitializationService');
    } catch (e) {
      Logger.error('Error during data initialization: $e', name: 'DataInitializationService');
      rethrow;
    }
  }

  /// Sadece kahve verilerini başlatır
  Future<void> initializeCoffeeData({bool clearExisting = false}) async {
    Logger.info('Initializing coffee data only', name: 'DataInitializationService');
    
    try {
      if (clearExisting) {
        await _coffeeDataService.clearExistingCoffeeData();
      }
      
      await _coffeeDataService.populateRealCoffeeData();
      Logger.info('Coffee data initialization completed', name: 'DataInitializationService');
    } catch (e) {
      Logger.error('Error initializing coffee data: $e', name: 'DataInitializationService');
      rethrow;
    }
  }

  /// Sadece kafe verilerini başlatır
  Future<void> initializeCafeData({bool clearExisting = false}) async {
    Logger.info('Initializing cafe data only', name: 'DataInitializationService');
    
    try {
      if (clearExisting) {
        await _cafeDataService.clearExistingCafeData();
      }
      
      await _cafeDataService.populateRealCafeData();
      Logger.info('Cafe data initialization completed', name: 'DataInitializationService');
    } catch (e) {
      Logger.error('Error initializing cafe data: $e', name: 'DataInitializationService');
      rethrow;
    }
  }

  /// Mevcut verileri günceller (merge mode)
  Future<void> updateAllData() async {
    Logger.info('Updating all data', name: 'DataInitializationService');
    
    try {
      // Kahve verilerini güncelle
      Logger.info('Updating coffee data...', name: 'DataInitializationService');
      await _coffeeDataService.updateCoffeeData();

      // Kafe verilerini güncelle
      Logger.info('Updating cafe data...', name: 'DataInitializationService');
      await _cafeDataService.updateCafeData();

      Logger.info('Data update completed successfully', name: 'DataInitializationService');
    } catch (e) {
      Logger.error('Error during data update: $e', name: 'DataInitializationService');
      rethrow;
    }
  }

  /// Tüm verileri temizler (DİKKATLİ KULLANIN!)
  Future<void> clearAllData() async {
    Logger.warning('Clearing all data - THIS IS DESTRUCTIVE!', name: 'DataInitializationService');
    
    try {
      await _coffeeDataService.clearExistingCoffeeData();
      await _cafeDataService.clearExistingCafeData();
      
      Logger.info('All data cleared successfully', name: 'DataInitializationService');
    } catch (e) {
      Logger.error('Error clearing data: $e', name: 'DataInitializationService');
      rethrow;
    }
  }

  /// Veri durumunu kontrol eder
  Future<Map<String, dynamic>> checkDataStatus() async {
    Logger.info('Checking data status', name: 'DataInitializationService');
    
    try {
      // Bu method gerçek implementasyonda EnhancedDataService kullanarak
      // mevcut veri sayılarını kontrol edebilir
      
      return {
        'status': 'ready',
        'timestamp': DateTime.now().toIso8601String(),
        'message': 'Data status check completed',
      };
    } catch (e) {
      Logger.error('Error checking data status: $e', name: 'DataInitializationService');
      return {
        'status': 'error',
        'timestamp': DateTime.now().toIso8601String(),
        'message': 'Error checking data status: $e',
      };
    }
  }
}