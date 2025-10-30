import 'dart:developer' as dev;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/loyalty_models.dart';
import '../../profile/services/user_profile_service.dart';

class LoyaltyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserProfileService _userProfileService = UserProfileService();

  // Award points for various actions
  Future<void> awardPoints({
    required int points,
    required String description,
    String type = 'earned',
    Map<String, dynamic>? metadata,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User must be logged in');

    try {
      // Create transaction record
      final transaction = PointsTransaction(
        id: '', // Will be set by Firestore
        userId: user.uid,
        type: type,
        points: points,
        description: description,
        createdAt: DateTime.now(),
        metadata: metadata ?? {},
      );

      // Add transaction to history
      await _firestore
          .collection('points_transactions')
          .add(transaction.toMap());

      // Update user's total points
      await _userProfileService.addCoffeePoints(points);

      dev.log('Awarded $points points to user ${user.uid} for: $description', 
               name: 'LoyaltyService', level: 800);
    } catch (e) {
      dev.log('Error awarding points', name: 'LoyaltyService', error: e, level: 1000);
      rethrow;
    }
  }

  // Redeem points for rewards
  Future<void> redeemPoints({
    required int points,
    required String description,
    Map<String, dynamic>? metadata,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User must be logged in');

    try {
      // Check if user has enough points
      final userProfile = await _userProfileService.getUserProfile(user.uid);
      if (userProfile == null || userProfile.coffeePoints < points) {
        throw Exception('Insufficient points');
      }

      // Create redemption transaction
      final transaction = PointsTransaction(
        id: '', // Will be set by Firestore
        userId: user.uid,
        type: 'redeemed',
        points: -points, // Negative for redemption
        description: description,
        createdAt: DateTime.now(),
        metadata: metadata ?? {},
      );

      // Add transaction to history
      await _firestore
          .collection('points_transactions')
          .add(transaction.toMap());

      // Deduct points from user
      await _userProfileService.addCoffeePoints(-points);

      dev.log('Redeemed $points points for user ${user.uid}: $description', 
               name: 'LoyaltyService', level: 800);
    } catch (e) {
      dev.log('Error redeeming points', name: 'LoyaltyService', error: e, level: 1000);
      rethrow;
    }
  }

  // Get user's points statistics
  Future<UserPointsStats> getUserPointsStats() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User must be logged in');

    try {
      // Get user profile for current points
      final userProfile = await _userProfileService.getUserProfile(user.uid);
      final totalPoints = userProfile?.coffeePoints ?? 0;

      // Get transaction history
      final transactionsSnapshot = await _firestore
          .collection('points_transactions')
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .limit(20)
          .get();

      final transactions = transactionsSnapshot.docs
          .map((doc) => PointsTransaction.fromMap(doc.data(), doc.id))
          .toList();

      // Calculate earned and redeemed totals
      int totalEarned = 0;
      int totalRedeemed = 0;

      for (final transaction in transactions) {
        if (transaction.points > 0) {
          totalEarned += transaction.points;
        } else {
          totalRedeemed += transaction.points.abs();
        }
      }

      // Get current and next loyalty levels
      final currentLevel = LoyaltyLevel.getLevelForPoints(totalPoints);
      final nextLevel = LoyaltyLevel.getNextLevel(totalPoints);
      final pointsToNextLevel = nextLevel != null 
          ? nextLevel.requiredPoints - totalPoints 
          : 0;

      return UserPointsStats(
        totalPoints: totalPoints,
        totalEarned: totalEarned,
        totalRedeemed: totalRedeemed,
        currentLevel: currentLevel,
        nextLevel: nextLevel,
        pointsToNextLevel: pointsToNextLevel,
        recentTransactions: transactions,
      );
    } catch (e) {
      dev.log('Error getting user points stats', name: 'LoyaltyService', error: e, level: 1000);
      rethrow;
    }
  }

  // Get points transaction history
  Stream<List<PointsTransaction>> getTransactionHistory({int limit = 50}) {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('points_transactions')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PointsTransaction.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Get available rewards
  Stream<List<PointsReward>> getAvailableRewards() {
    return _firestore
        .collection('points_rewards')
        .where('isActive', isEqualTo: true)
        .orderBy('requiredPoints')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PointsReward.fromMap(doc.data(), doc.id))
          .where((reward) => !reward.isExpired)
          .toList();
    });
  }

  // Award points for QR code scan
  Future<void> awardQRPoints(String qrCode, String cafeId) async {
    try {
      await awardPoints(
        points: 10,
        description: 'QR kod tarama bonusu',
        type: 'earned',
        metadata: {
          'qrCode': qrCode,
          'cafeId': cafeId,
          'source': 'qr_scan',
        },
      );
    } catch (e) {
      dev.log('Error awarding QR points', name: 'LoyaltyService', error: e, level: 1000);
      rethrow;
    }
  }

  // Award points for order
  Future<void> awardOrderPoints(String orderId, double orderAmount) async {
    try {
      // 1 point per 10 TL spent
      final points = (orderAmount / 10).floor();
      
      if (points > 0) {
        await awardPoints(
          points: points,
          description: 'Sipariş puanı (${orderAmount.toStringAsFixed(0)} ₺)',
          type: 'earned',
          metadata: {
            'orderId': orderId,
            'orderAmount': orderAmount,
            'source': 'order',
          },
        );
      }
    } catch (e) {
      dev.log('Error awarding order points', name: 'LoyaltyService', error: e, level: 1000);
      rethrow;
    }
  }

  // Award points for review
  Future<void> awardReviewPoints(String reviewId, String targetType) async {
    try {
      await awardPoints(
        points: 5,
        description: 'Değerlendirme bonusu',
        type: 'earned',
        metadata: {
          'reviewId': reviewId,
          'targetType': targetType,
          'source': 'review',
        },
      );
    } catch (e) {
      dev.log('Error awarding review points', name: 'LoyaltyService', error: e, level: 1000);
      rethrow;
    }
  }

  // Check if user can afford reward
  Future<bool> canAffordReward(String rewardId) async {
    try {
      final stats = await getUserPointsStats();
      final rewardDoc = await _firestore
          .collection('points_rewards')
          .doc(rewardId)
          .get();
      
      if (!rewardDoc.exists) return false;
      
      final reward = PointsReward.fromMap(rewardDoc.data()!, rewardDoc.id);
      return stats.totalPoints >= reward.requiredPoints && 
             reward.isActive && 
             !reward.isExpired;
    } catch (e) {
      dev.log('Error checking reward affordability', name: 'LoyaltyService', error: e, level: 1000);
      return false;
    }
  }

  // Redeem a specific reward
  Future<void> redeemReward(String rewardId) async {
    try {
      final rewardDoc = await _firestore
          .collection('points_rewards')
          .doc(rewardId)
          .get();
      
      if (!rewardDoc.exists) {
        throw Exception('Reward not found');
      }
      
      final reward = PointsReward.fromMap(rewardDoc.data()!, rewardDoc.id);
      
      if (!reward.isActive || reward.isExpired) {
        throw Exception('Reward is not available');
      }

      final canAfford = await canAffordReward(rewardId);
      if (!canAfford) {
        throw Exception('Insufficient points for this reward');
      }

      await redeemPoints(
        points: reward.requiredPoints,
        description: 'Ödül kullanımı: ${reward.name}',
        metadata: {
          'rewardId': rewardId,
          'rewardType': reward.type,
          'rewardData': reward.rewardData,
        },
      );

      dev.log('Successfully redeemed reward: ${reward.name}', 
               name: 'LoyaltyService', level: 800);
    } catch (e) {
      dev.log('Error redeeming reward', name: 'LoyaltyService', error: e, level: 1000);
      rethrow;
    }
  }

  // Calculate points for amount spent
  static int calculatePointsForAmount(double amount) {
    return (amount / 10).floor(); // 1 point per 10 TL
  }

  // Get points multiplier for loyalty level
  static double getPointsMultiplier(LoyaltyLevel level) {
    switch (level.name) {
      case 'Kahve Dostu':
        return 1.1; // 10% bonus
      case 'Kahve Uzmanı':
        return 1.25; // 25% bonus
      case 'Kahve Gurme':
        return 1.5; // 50% bonus
      case 'Kahve Ustaları':
        return 2.0; // 100% bonus
      default:
        return 1.0; // No bonus
    }
  }
}