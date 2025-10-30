import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import '../models/cafe_model.dart';
import '../../../services/data_service.dart';
import '../../../utils/logger.dart';

class CafeService {
  final DataService _dataService;

  CafeService(this._dataService) {
    Logger.info('CafeService initialized with DataService integration', name: 'CafeService');
  }

  /// Factory constructor to create CafeService with DataService from context
  factory CafeService.fromContext(BuildContext context) {
    final dataService = Provider.of<DataService>(context, listen: false);
    return CafeService(dataService);
  }

  // Get all cafes
  Stream<List<Cafe>> getCafes() {
    Logger.dataOperation('Getting cafes stream via DataService', name: 'CafeService');
    return _dataService.getCafesStream();
  }

  // Get cafes near a location
  Future<List<Cafe>> getNearbyContent(double latitude, double longitude, {double radiusKm = 10}) async {
    Logger.dataOperation('Getting nearby cafes via DataService', name: 'CafeService');
    
    try {
      final userPosition = Position(
        latitude: latitude,
        longitude: longitude,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );
      
      return await _dataService.getNearbyCafes(userPosition, radiusKm: radiusKm);
    } catch (e) {
      Logger.error('Error getting nearby cafes via DataService: $e', name: 'CafeService');
      rethrow;
    }
  }

  // Get partner cafes
  Future<List<Cafe>> getPartnerCafes() async {
    Logger.dataOperation('Getting partner cafes via DataService', name: 'CafeService');
    
    try {
      return await _dataService.getPartnerCafes();
    } catch (e) {
      Logger.error('Error getting partner cafes via DataService: $e', name: 'CafeService');
      rethrow;
    }
  }

  // Get cafe by ID
  Future<Cafe?> getCafeById(String cafeId) async {
    Logger.dataOperation('Getting cafe by ID via DataService: $cafeId', name: 'CafeService');
    
    try {
      return await _dataService.getCafeById(cafeId);
    } catch (e) {
      Logger.error('Error getting cafe by ID via DataService: $e', name: 'CafeService');
      throw Exception('Failed to fetch cafe: $e');
    }
  }

  // Search cafes by name or location
  Future<List<Cafe>> searchCafes(String query) async {
    Logger.dataOperation('Searching cafes via DataService: $query', name: 'CafeService');
    
    try {
      final allCafes = await _dataService.getCafes();
      
      final lowercaseQuery = query.toLowerCase();
      return allCafes.where((cafe) =>
          cafe.name.toLowerCase().contains(lowercaseQuery) ||
          cafe.address.toLowerCase().contains(lowercaseQuery) ||
          cafe.description.toLowerCase().contains(lowercaseQuery)
      ).toList();
    } catch (e) {
      Logger.error('Error searching cafes via DataService: $e', name: 'CafeService');
      rethrow;
    }
  }

  // Get top rated cafes
  Future<List<Cafe>> getTopRatedCafes({int limit = 10}) async {
    Logger.dataOperation('Getting top rated cafes via DataService', name: 'CafeService');
    
    try {
      final allCafes = await _dataService.getCafes();
      
      // Filter and sort by rating
      final topRatedCafes = allCafes
          .where((cafe) => cafe.rating > 4.0)
          .toList()
        ..sort((a, b) {
          final ratingComparison = b.rating.compareTo(a.rating);
          if (ratingComparison != 0) return ratingComparison;
          return b.reviewCount.compareTo(a.reviewCount);
        });
      
      return topRatedCafes.take(limit).toList();
    } catch (e) {
      Logger.error('Error getting top rated cafes via DataService: $e', name: 'CafeService');
      rethrow;
    }
  }

  // Note: Admin functions like addCafe and updateCafe are kept separate
  // from DataService as they are administrative operations

  // Calculate distance between user and cafe
  double calculateDistanceKm(Position userPosition, Cafe cafe) {
    return Geolocator.distanceBetween(
      userPosition.latitude,
      userPosition.longitude,
      cafe.latitude,
      cafe.longitude,
    ) / 1000; // Convert to kilometers
  }

  // Get cafes with specific amenities
  Future<List<Cafe>> getCafesWithAmenities(List<String> amenities) async {
    Logger.dataOperation('Getting cafes with amenities via DataService', name: 'CafeService');
    
    try {
      final allCafes = await _dataService.getCafes();
      
      return allCafes.where((cafe) {
        return amenities.any((amenity) => cafe.amenities.contains(amenity));
      }).toList();
    } catch (e) {
      Logger.error('Error getting cafes with amenities via DataService: $e', name: 'CafeService');
      rethrow;
    }
  }

  // Get cafes that are currently open
  Future<List<Cafe>> getOpenCafes() async {
    Logger.dataOperation('Getting open cafes via DataService', name: 'CafeService');
    
    try {
      final allCafes = await _dataService.getCafes();
      return allCafes.where((cafe) => cafe.isOpen).toList();
    } catch (e) {
      Logger.error('Error getting open cafes via DataService: $e', name: 'CafeService');
      rethrow;
    }
  }
}