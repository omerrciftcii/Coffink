
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import '../models/coffee_model.dart';
import '../../../utils/logger.dart';
import '../../../services/data_service.dart';

class CoffeeService {
  final DataService _dataService;

  CoffeeService(this._dataService) {
    Logger.info('CoffeeService initialized with DataService integration', name: 'CoffeeService');
  }

  /// Factory constructor to create CoffeeService with DataService from context
  factory CoffeeService.fromContext(BuildContext context) {
    final dataService = Provider.of<DataService>(context, listen: false);
    return CoffeeService(dataService);
  }

  Stream<List<Coffee>> getCoffees() {
    Logger.dataOperation('Starting to listen for coffee collection changes via DataService', name: 'CoffeeService');
    return _dataService.getCoffeesStream();
  }

  Future<Coffee?> getCoffeeById(String coffeeId) async {
    Logger.logMethodCall('CoffeeService', 'getCoffeeById',
                        parameters: {'coffeeId': coffeeId});

    try {
      return await _dataService.getCoffeeById(coffeeId);
    } catch (e) {
      Logger.dataOperation('Error fetching coffee by ID via DataService: $coffeeId',
                         name: 'CoffeeService', error: e);
      rethrow;
    }
  }

  Future<List<Coffee>> getRandomCoffees(int count) async {
    Logger.logMethodCall('CoffeeService', 'getRandomCoffees',
                        parameters: {'count': count});

    try {
      Logger.dataOperation('Fetching $count random coffees via DataService', name: 'CoffeeService');

      // Get all available coffees first
      final allCoffees = await _dataService.getCoffees();
      
      if (allCoffees.isEmpty) {
        Logger.warning('No coffees found in database', name: 'CoffeeService');
        return [];
      }

      // Randomly select coffees
      final random = <Coffee>[];
      final usedIndices = <int>{};
      final availableCoffees = allCoffees.where((coffee) => coffee.isAvailable).toList();

      while (random.length < count && usedIndices.length < availableCoffees.length) {
        final randomIndex = DateTime.now().millisecondsSinceEpoch % availableCoffees.length;
        
        if (usedIndices.contains(randomIndex)) continue;
        usedIndices.add(randomIndex);

        final coffee = availableCoffees[randomIndex];
        random.add(coffee);
        Logger.dataOperation('Added random coffee: ${coffee.name}', name: 'CoffeeService');
      }

      Logger.dataOperation('Successfully fetched ${random.length} random coffees', name: 'CoffeeService');
      return random;
    } catch (e) {
      Logger.dataOperation('Error fetching random coffees via DataService',
                         name: 'CoffeeService', error: e);
      rethrow;
    }
  }

  /// Gets coffees by category using DataService
  Future<List<Coffee>> getCoffeesByCategory(String category) async {
    Logger.logMethodCall('CoffeeService', 'getCoffeesByCategory',
                        parameters: {'category': category});

    try {
      return await _dataService.getCoffees(category: category);
    } catch (e) {
      Logger.dataOperation('Error fetching coffees by category via DataService: $category',
                         name: 'CoffeeService', error: e);
      rethrow;
    }
  }

  /// Gets popular coffees using DataService
  Future<List<Coffee>> getPopularCoffees({int limit = 10}) async {
    Logger.logMethodCall('CoffeeService', 'getPopularCoffees',
                        parameters: {'limit': limit});

    try {
      return await _dataService.getPopularCoffees(limit: limit);
    } catch (e) {
      Logger.dataOperation('Error fetching popular coffees via DataService',
                         name: 'CoffeeService', error: e);
      rethrow;
    }
  }
}
 