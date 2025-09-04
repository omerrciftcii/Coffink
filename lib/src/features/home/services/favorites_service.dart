
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/coffee_model.dart';

class FavoritesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<Coffee>> getFavorites() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }
    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .snapshots()
        .asyncMap((snapshot) async {
      final coffeeFutures = snapshot.docs.map((doc) async {
        final coffeeDoc = await _firestore.collection('coffees').doc(doc.id).get();
        return Coffee.fromMap(coffeeDoc.data()!, coffeeDoc.id);
      }).toList();
      return await Future.wait(coffeeFutures);
    });
  }

  Future<void> addToFavorites(String coffeeId) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(coffeeId)
          .set({});
    }
  }

  Future<void> removeFromFavorites(String coffeeId) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(coffeeId)
          .delete();
    }
  }

  Stream<bool> isFavorite(String coffeeId) {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value(false);
    }
    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(coffeeId)
        .snapshots()
        .map((snapshot) => snapshot.exists);
  }
}
