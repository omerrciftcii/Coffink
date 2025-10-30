import 'package:cloud_firestore/cloud_firestore.dart';
import 'real_coffee_data_service.dart';
import 'real_cafe_data_service.dart';
import '../utils/logger.dart';

/// Service to populate Firebase with real Turkish coffee and cafe data
class DataPopulationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RealCoffeeDataService _coffeeDataService = RealCoffeeDataService();
  final RealCafeDataService _cafeDataService = RealCafeDataService();

  DataPopulationService() {
    Logger.info('DataPopulationService initialized', name: 'DataPopulationService');
  }

  /// Populates Firebase with all real data (cafes and coffees)
  Future<void> populateAllRealData() async {
    Logger.info('Starting to populate all real data', name: 'DataPopulationService');
    
    try {
      // Populate cafe data first
      await populateRealCafeData();
      
      // Then populate coffee data
      await populateRealCoffeeData();
      
      Logger.info('Successfully populated all real data', name: 'DataPopulationService');
    } catch (e) {
      Logger.error('Error populating all real data: $e', name: 'DataPopulationService');
      rethrow;
    }
  }

  /// Populates Firebase with real Istanbul cafe data
  Future<void> populateRealCafeData() async {
    Logger.info('Populating real cafe data', name: 'DataPopulationService');
    
    try {
      await _cafeDataService.populateRealCafeData();
      Logger.info('Real cafe data populated successfully', name: 'DataPopulationService');
    } catch (e) {
      Logger.error('Error populating cafe data: $e', name: 'DataPopulationService');
      rethrow;
    }
  }

  /// Populates Firebase with real Turkish coffee data
  Future<void> populateRealCoffeeData() async {
    Logger.info('Populating real coffee data', name: 'DataPopulationService');
    
    try {
      await _coffeeDataService.populateRealCoffeeData();
      Logger.info('Real coffee data populated successfully', name: 'DataPopulationService');
    } catch (e) {
      Logger.error('Error populating coffee data: $e', name: 'DataPopulationService');
      rethrow;
    }
  }

  /// Updates existing data with new information
  Future<void> updateAllRealData() async {
    Logger.info('Updating all real data', name: 'DataPopulationService');
    
    try {
      // Update cafe data
      await _cafeDataService.updateCafeData();
      
      // Update coffee data
      await _coffeeDataService.updateCoffeeData();
      
      Logger.info('Successfully updated all real data', name: 'DataPopulationService');
    } catch (e) {
      Logger.error('Error updating all real data: $e', name: 'DataPopulationService');
      rethrow;
    }
  }

  /// Checks if data exists in Firebase collections
  Future<Map<String, int>> checkDataStatus() async {
    Logger.info('Checking data status', name: 'DataPopulationService');
    
    try {
      final cafeSnapshot = await _firestore.collection('cafes').get();
      final coffeeSnapshot = await _firestore.collection('coffees').get();
      
      final status = {
        'cafes': cafeSnapshot.docs.length,
        'coffees': coffeeSnapshot.docs.length,
      };
      
      Logger.info('Data status: $status', name: 'DataPopulationService');
      return status;
    } catch (e) {
      Logger.error('Error checking data status: $e', name: 'DataPopulationService');
      rethrow;
    }
  }

  /// Clears all existing data (use with caution!)
  Future<void> clearAllData() async {
    Logger.warning('Clearing all existing data', name: 'DataPopulationService');
    
    try {
      await _cafeDataService.clearExistingCafeData();
      await _coffeeDataService.clearExistingCoffeeData();
      
      Logger.info('All data cleared successfully', name: 'DataPopulationService');
    } catch (e) {
      Logger.error('Error clearing all data: $e', name: 'DataPopulationService');
      rethrow;
    }
  }
}