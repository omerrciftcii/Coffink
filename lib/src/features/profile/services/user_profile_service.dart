import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_profile.dart';

class UserProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<UserProfile?> getCurrentUserProfile() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(null);

    return _firestore
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return null;
      return UserProfile.fromMap(snapshot.data()!, snapshot.id);
    });
  }

  Future<void> createUserProfile(UserProfile profile) async {
    await _firestore
        .collection('users')
        .doc(profile.id)
        .set(profile.toMap());
  }

  Future<void> updateUserProfile(UserProfile profile) async {
    await _firestore
        .collection('users')
        .doc(profile.id)
        .update(profile.copyWith(updatedAt: DateTime.now()).toMap());
  }

  Future<void> updateTastePreferences(Map<String, dynamic> preferences) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    await _firestore.collection('users').doc(user.uid).update({
      'tastePreferences': preferences,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> addCoffeePoints(int points) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    await _firestore.collection('users').doc(user.uid).update({
      'coffeePoints': FieldValue.increment(points),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateCoffeePoints(String userId, int pointsChange) async {
    await _firestore.collection('users').doc(userId).update({
      'coffeePoints': FieldValue.increment(pointsChange),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<UserProfile?> getUserProfile(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .get();
    
    if (!snapshot.exists) return null;
    return UserProfile.fromMap(snapshot.data()!, snapshot.id);
  }
}