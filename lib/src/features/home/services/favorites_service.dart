
import 'dart:developer' as dev;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/coffee_model.dart';
import '../../cafe/models/cafe_model.dart';

class FavoriteItem {
  final String id;
  final String type; // 'coffee' or 'cafe'
  final DateTime addedAt;
  final Map<String, dynamic> metadata;

  FavoriteItem({
    required this.id,
    required this.type,
    required this.addedAt,
    this.metadata = const {},
  });

  factory FavoriteItem.fromMap(Map<String, dynamic> data, String documentId) {
    return FavoriteItem(
      id: documentId,
      type: data['type'] ?? 'coffee',
      addedAt: (data['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'addedAt': Timestamp.fromDate(addedAt),
      'metadata': metadata,
    };
  }
}

class FavoritesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get all favorite items
  Stream<List<FavoriteItem>> getFavoriteItems() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }
    
    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return FavoriteItem.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // Get favorite coffees
  Stream<List<Coffee>> getFavoriteCoffees() {
    return getFavoriteItems().asyncMap((favorites) async {
      final coffeeIds = favorites
          .where((fav) => fav.type == 'coffee')
          .map((fav) => fav.id)
          .toList();
      
      if (coffeeIds.isEmpty) return [];
      
      try {
        final coffeeFutures = coffeeIds.map((id) async {
          final coffeeDoc = await _firestore.collection('coffees').doc(id).get();
          if (coffeeDoc.exists) {
            return Coffee.fromMap(coffeeDoc.data()!, coffeeDoc.id);
          }
          return null;
        }).toList();
        
        final coffees = await Future.wait(coffeeFutures);
        return coffees.where((coffee) => coffee != null).cast<Coffee>().toList();
      } catch (e) {
        dev.log('Error fetching favorite coffees', name: 'FavoritesService', error: e, level: 1000);
        return [];
      }
    });
  }

  // Get favorite cafés
  Stream<List<Cafe>> getFavoriteCafes() {
    return getFavoriteItems().asyncMap((favorites) async {
      final cafeIds = favorites
          .where((fav) => fav.type == 'cafe')
          .map((fav) => fav.id)
          .toList();
      
      if (cafeIds.isEmpty) return [];
      
      try {
        final cafeFutures = cafeIds.map((id) async {
          final cafeDoc = await _firestore.collection('cafes').doc(id).get();
          if (cafeDoc.exists) {
            return Cafe.fromFirestore(cafeDoc);
          }
          return null;
        }).toList();
        
        final cafes = await Future.wait(cafeFutures);
        return cafes.where((cafe) => cafe != null).cast<Cafe>().toList();
      } catch (e) {
        dev.log('Error fetching favorite cafes', name: 'FavoritesService', error: e, level: 1000);
        return [];
      }
    });
  }

  // Legacy method for backward compatibility
  Stream<List<Coffee>> getFavorites() {
    return getFavoriteCoffees();
  }

  // Add item to favorites
  Future<void> addToFavorites(String itemId, {String type = 'coffee', Map<String, dynamic>? metadata}) async {
    final user = _auth.currentUser;
    if (user == null) {
      dev.log('User not logged in', name: 'FavoritesService', level: 900);
      return;
    }

    try {
      final favoriteItem = FavoriteItem(
        id: itemId,
        type: type,
        addedAt: DateTime.now(),
        metadata: metadata ?? {},
      );

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(itemId)
          .set(favoriteItem.toMap());

      dev.log('Added $type $itemId to favorites', name: 'FavoritesService', level: 800);
    } catch (e) {
      dev.log('Error adding to favorites', name: 'FavoritesService', error: e, level: 1000);
      rethrow;
    }
  }

  // Remove item from favorites
  Future<void> removeFromFavorites(String itemId) async {
    final user = _auth.currentUser;
    if (user == null) {
      dev.log('User not logged in', name: 'FavoritesService', level: 900);
      return;
    }

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(itemId)
          .delete();

      dev.log('Removed $itemId from favorites', name: 'FavoritesService', level: 800);
    } catch (e) {
      dev.log('Error removing from favorites', name: 'FavoritesService', error: e, level: 1000);
      rethrow;
    }
  }

  // Check if item is favorite
  Stream<bool> isFavorite(String itemId) {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value(false);
    }
    
    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(itemId)
        .snapshots()
        .map((snapshot) => snapshot.exists);
  }

  // Get favorite count
  Future<int> getFavoriteCount() async {
    final user = _auth.currentUser;
    if (user == null) return 0;

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .get();
      
      return snapshot.docs.length;
    } catch (e) {
      dev.log('Error getting favorite count', name: 'FavoritesService', error: e, level: 1000);
      return 0;
    }
  }

  // Get favorite count by type
  Future<Map<String, int>> getFavoriteCountByType() async {
    final user = _auth.currentUser;
    if (user == null) return {'coffee': 0, 'cafe': 0};

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .get();
      
      final counts = {'coffee': 0, 'cafe': 0};
      
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final type = data['type'] ?? 'coffee';
        counts[type] = (counts[type] ?? 0) + 1;
      }
      
      return counts;
    } catch (e) {
      dev.log('Error getting favorite count by type', name: 'FavoritesService', error: e, level: 1000);
      return {'coffee': 0, 'cafe': 0};
    }
  }

  // Clear all favorites
  Future<void> clearAllFavorites() async {
    final user = _auth.currentUser;
    if (user == null) {
      dev.log('User not logged in', name: 'FavoritesService', level: 900);
      return;
    }

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .get();
      
      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
      
      dev.log('Cleared all favorites', name: 'FavoritesService', level: 800);
    } catch (e) {
      dev.log('Error clearing favorites', name: 'FavoritesService', error: e, level: 1000);
      rethrow;
    }
  }
}
