import 'dart:developer' as dev;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/review_model.dart';

class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Submit a new review
  Future<void> submitReview({
    required String targetId,
    required String targetType,
    required double rating,
    required String comment,
    List<String> photos = const [],
    Map<String, dynamic> metadata = const {},
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User must be logged in to submit review');

    try {
      // Get user profile for name and avatar
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userData = userDoc.data() ?? {};

      // Safely convert user data
      String safeUserName = 'Anonymous User';
      try {
        final nameData = userData['name'] ?? userData['firstName'];
        if (nameData != null) {
          safeUserName = nameData.toString();
        }
      } catch (e) {
        safeUserName = 'Anonymous User';
      }

      String safeUserAvatar = '';
      try {
        final avatarData = userData['profileImageUrl'];
        if (avatarData != null) {
          safeUserAvatar = avatarData.toString();
        }
      } catch (e) {
        safeUserAvatar = '';
      }

      // Ensure all parameters are properly typed
      final safeTargetId = targetId.toString();
      final safeTargetType = targetType.toString();
      final safeComment = comment.toString();
      
      // Ensure photos are all strings
      final safePhotos = photos.map((photo) => photo.toString()).toList();
      
      // Ensure metadata values are safe
      final safeMetadata = <String, dynamic>{};
      metadata.forEach((key, value) {
        safeMetadata[key.toString()] = value;
      });

      final review = Review(
        id: '', // Will be set by Firestore
        userId: user.uid,
        userName: safeUserName,
        userAvatar: safeUserAvatar,
        targetId: safeTargetId,
        targetType: safeTargetType,
        rating: rating,
        comment: safeComment,
        photos: safePhotos,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        metadata: safeMetadata,
      );

      // Add review to Firestore
      final docRef = await _firestore.collection('reviews').add(review.toMap());
      
      // Update review summary
      await _updateReviewSummary(targetId, targetType, rating, isNew: true);
      
      dev.log('Review submitted successfully: ${docRef.id}', 
               name: 'ReviewService', level: 800);
    } catch (e) {
      dev.log('Error submitting review', name: 'ReviewService', error: e, level: 1000);
      rethrow;
    }
  }

  // Update existing review
  Future<void> updateReview({
    required String reviewId,
    required double rating,
    required String comment,
    List<String>? photos,
    Map<String, dynamic>? metadata,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User must be logged in to update review');

    try {
      // Get existing review
      final reviewDoc = await _firestore.collection('reviews').doc(reviewId).get();
      if (!reviewDoc.exists) throw Exception('Review not found');
      
      final existingReview = Review.fromMap(reviewDoc.data()!, reviewDoc.id);
      
      // Check if user owns this review
      if (existingReview.userId != user.uid) {
        throw Exception('You can only update your own reviews');
      }

      // Update review summary (remove old rating, add new rating)
      await _updateReviewSummary(
        existingReview.targetId, 
        existingReview.targetType, 
        existingReview.rating, 
        isNew: false
      );
      await _updateReviewSummary(
        existingReview.targetId, 
        existingReview.targetType, 
        rating, 
        isNew: true
      );

      // Update review document
      await _firestore.collection('reviews').doc(reviewId).update({
        'rating': rating,
        'comment': comment,
        if (photos != null) 'photos': photos,
        if (metadata != null) 'metadata': metadata,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      dev.log('Review updated successfully: $reviewId', 
               name: 'ReviewService', level: 800);
    } catch (e) {
      dev.log('Error updating review', name: 'ReviewService', error: e, level: 1000);
      rethrow;
    }
  }

  // Delete review
  Future<void> deleteReview(String reviewId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User must be logged in to delete review');

    try {
      // Get existing review
      final reviewDoc = await _firestore.collection('reviews').doc(reviewId).get();
      if (!reviewDoc.exists) throw Exception('Review not found');
      
      final existingReview = Review.fromMap(reviewDoc.data()!, reviewDoc.id);
      
      // Check if user owns this review
      if (existingReview.userId != user.uid) {
        throw Exception('You can only delete your own reviews');
      }

      // Update review summary (remove rating)
      await _updateReviewSummary(
        existingReview.targetId, 
        existingReview.targetType, 
        existingReview.rating, 
        isNew: false
      );

      // Delete review document
      await _firestore.collection('reviews').doc(reviewId).delete();

      dev.log('Review deleted successfully: $reviewId', 
               name: 'ReviewService', level: 800);
    } catch (e) {
      dev.log('Error deleting review', name: 'ReviewService', error: e, level: 1000);
      rethrow;
    }
  }

  // Get reviews for a target (coffee or café)
  Stream<List<Review>> getReviewsForTarget(String targetId, String targetType) {
    return _firestore
        .collection('reviews')
        .where('targetId', isEqualTo: targetId)
        .where('targetType', isEqualTo: targetType)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Review.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // Get user's own reviews
  Stream<List<Review>> getUserReviews() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('reviews')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Review.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // Check if user has reviewed a target
  Future<Review?> getUserReviewForTarget(String targetId, String targetType) async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final snapshot = await _firestore
          .collection('reviews')
          .where('userId', isEqualTo: user.uid)
          .where('targetId', isEqualTo: targetId)
          .where('targetType', isEqualTo: targetType)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;
      
      return Review.fromMap(snapshot.docs.first.data(), snapshot.docs.first.id);
    } catch (e) {
      dev.log('Error getting user review', name: 'ReviewService', error: e, level: 1000);
      return null;
    }
  }

  // Get review summary for a target
  Stream<ReviewSummary> getReviewSummary(String targetId, String targetType) {
    return _firestore
        .collection('review_summaries')
        .doc('${targetType}_$targetId')
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        return ReviewSummary(
          averageRating: 0.0,
          totalReviews: 0,
          ratingDistribution: {5: 0, 4: 0, 3: 0, 2: 0, 1: 0},
        );
      }
      return ReviewSummary.fromMap(snapshot.data()!);
    });
  }

  // Private method to update review summary
  Future<void> _updateReviewSummary(String targetId, String targetType, double rating, {required bool isNew}) async {
    final summaryId = '${targetType}_$targetId';
    final summaryRef = _firestore.collection('review_summaries').doc(summaryId);

    await _firestore.runTransaction((transaction) async {
      final summaryDoc = await transaction.get(summaryRef);
      
      ReviewSummary currentSummary;
      if (summaryDoc.exists) {
        currentSummary = ReviewSummary.fromMap(summaryDoc.data()!);
      } else {
        currentSummary = ReviewSummary(
          averageRating: 0.0,
          totalReviews: 0,
          ratingDistribution: {5: 0, 4: 0, 3: 0, 2: 0, 1: 0},
        );
      }

      // Calculate new summary
      final ratingInt = rating.round();
      Map<int, int> newDistribution = Map.from(currentSummary.ratingDistribution);
      
      if (isNew) {
        // Adding new review
        newDistribution[ratingInt] = (newDistribution[ratingInt] ?? 0) + 1;
        final newTotal = currentSummary.totalReviews + 1;
        final newAverage = ((currentSummary.averageRating * currentSummary.totalReviews) + rating) / newTotal;
        
        final newSummary = ReviewSummary(
          averageRating: newAverage,
          totalReviews: newTotal,
          ratingDistribution: newDistribution,
        );
        
        transaction.set(summaryRef, newSummary.toMap());
      } else {
        // Removing existing review
        if (currentSummary.totalReviews > 0) {
          newDistribution[ratingInt] = ((newDistribution[ratingInt] ?? 0) - 1).clamp(0, double.infinity).toInt();
          final newTotal = (currentSummary.totalReviews - 1).clamp(0, double.infinity).toInt();
          
          double newAverage = 0.0;
          if (newTotal > 0) {
            newAverage = ((currentSummary.averageRating * currentSummary.totalReviews) - rating) / newTotal;
          }
          
          final newSummary = ReviewSummary(
            averageRating: newAverage,
            totalReviews: newTotal,
            ratingDistribution: newDistribution,
          );
          
          transaction.set(summaryRef, newSummary.toMap());
        }
      }
    });
  }

  // Get recent reviews across all targets (for home page)
  Stream<List<Review>> getRecentReviews({int limit = 10}) {
    return _firestore
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Review.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }
}