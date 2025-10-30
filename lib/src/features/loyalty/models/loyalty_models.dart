
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../theme/coffee_theme.dart';

class PointsTransaction {
  final String id;
  final String userId;
  final String type; // 'earned', 'redeemed', 'bonus', 'expired'
  final int points;
  final String description;
  final DateTime createdAt;
  final Map<String, dynamic> metadata; // orderId, cafeId, qrCode, etc.

  PointsTransaction({
    required this.id,
    required this.userId,
    required this.type,
    required this.points,
    required this.description,
    required this.createdAt,
    this.metadata = const {},
  });

  factory PointsTransaction.fromMap(Map<String, dynamic> data, String documentId) {
    return PointsTransaction(
      id: documentId,
      userId: data['userId'] ?? '',
      type: data['type'] ?? 'earned',
      points: data['points'] ?? 0,
      description: data['description'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'type': type,
      'points': points,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'metadata': metadata,
    };
  }
}

class LoyaltyLevel {
  final String name;
  final int requiredPoints;
  final double discountPercentage;
  final List<String> benefits;
  final String badgeIcon;
  final Color color;

  LoyaltyLevel({
    required this.name,
    required this.requiredPoints,
    required this.discountPercentage,
    required this.benefits,
    required this.badgeIcon,
    required this.color,
  });

  static List<LoyaltyLevel> get levels => [
    LoyaltyLevel(
      name: 'Kahve Sevenler',
      requiredPoints: 0,
      discountPercentage: 0.0,
      benefits: ['Puan kazanma', 'Özel teklifler'],
      badgeIcon: '☕',
      color: CoffeeTheme.loyaltyLevelColors[0],
    ),
    LoyaltyLevel(
      name: 'Kahve Dostu',
      requiredPoints: 100,
      discountPercentage: 5.0,
      benefits: ['%5 indirim', 'Doğum günü hediyesi', 'Erken erişim'],
      badgeIcon: '🤝',
      color: CoffeeTheme.loyaltyLevelColors[1],
    ),
    LoyaltyLevel(
      name: 'Kahve Uzmanı',
      requiredPoints: 300,
      discountPercentage: 10.0,
      benefits: ['%10 indirim', 'Ücretsiz kargo', 'VIP destek'],
      badgeIcon: '⭐',
      color: CoffeeTheme.loyaltyLevelColors[2],
    ),
    LoyaltyLevel(
      name: 'Kahve Gurme',
      requiredPoints: 600,
      discountPercentage: 15.0,
      benefits: ['%15 indirim', 'Öncelikli rezervasyon', 'Özel etkinlikler'],
      badgeIcon: '👑',
      color: CoffeeTheme.loyaltyLevelColors[3],
    ),
    LoyaltyLevel(
      name: 'Kahve Ustaları',
      requiredPoints: 1000,
      discountPercentage: 20.0,
      benefits: ['%20 indirim', 'Kişisel danışman', 'Sınırsız avantajlar'],
      badgeIcon: '💎',
      color: CoffeeTheme.loyaltyLevelColors[4],
    ),
  ];

  static LoyaltyLevel getLevelForPoints(int points) {
    for (int i = levels.length - 1; i >= 0; i--) {
      if (points >= levels[i].requiredPoints) {
        return levels[i];
      }
    }
    return levels.first;
  }

  static LoyaltyLevel? getNextLevel(int points) {
    for (int i = 0; i < levels.length; i++) {
      if (points < levels[i].requiredPoints) {
        return levels[i];
      }
    }
    return null; // Already at max level
  }
}

class PointsReward {
  final String id;
  final String name;
  final String description;
  final int requiredPoints;
  final String imageUrl;
  final String type; // 'discount', 'freeItem', 'special'
  final Map<String, dynamic> rewardData;
  final bool isActive;
  final DateTime? expiresAt;

  PointsReward({
    required this.id,
    required this.name,
    required this.description,
    required this.requiredPoints,
    required this.imageUrl,
    required this.type,
    this.rewardData = const {},
    this.isActive = true,
    this.expiresAt,
  });

  factory PointsReward.fromMap(Map<String, dynamic> data, String documentId) {
    return PointsReward(
      id: documentId,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      requiredPoints: data['requiredPoints'] ?? 0,
      imageUrl: data['imageUrl'] ?? '',
      type: data['type'] ?? 'discount',
      rewardData: Map<String, dynamic>.from(data['rewardData'] ?? {}),
      isActive: data['isActive'] ?? true,
      expiresAt: (data['expiresAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'requiredPoints': requiredPoints,
      'imageUrl': imageUrl,
      'type': type,
      'rewardData': rewardData,
      'isActive': isActive,
      if (expiresAt != null) 'expiresAt': Timestamp.fromDate(expiresAt!),
    };
  }

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
}

class UserPointsStats {
  final int totalPoints;
  final int totalEarned;
  final int totalRedeemed;
  final LoyaltyLevel currentLevel;
  final LoyaltyLevel? nextLevel;
  final int pointsToNextLevel;
  final List<PointsTransaction> recentTransactions;

  UserPointsStats({
    required this.totalPoints,
    required this.totalEarned,
    required this.totalRedeemed,
    required this.currentLevel,
    this.nextLevel,
    required this.pointsToNextLevel,
    this.recentTransactions = const [],
  });
}
