import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final String targetId; // Coffee ID or Café ID
  final String targetType; // 'coffee' or 'cafe'
  final double rating;
  final String comment;
  final List<String> photos;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata; // Additional info like order ID, size, etc.

  Review({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.targetId,
    required this.targetType,
    required this.rating,
    required this.comment,
    this.photos = const [],
    required this.createdAt,
    required this.updatedAt,
    this.metadata = const {},
  });

  factory Review.fromMap(Map<String, dynamic> data, String documentId) {
    // Safely convert photos array to List<String>
    List<String> safePhotos = [];
    try {
      final photosData = data['photos'];
      if (photosData != null) {
        if (photosData is List) {
          safePhotos = photosData.map((e) {
            if (e is String) {
              return e;
            } else {
              return e.toString();
            }
          }).toList();
        }
      }
    } catch (e) {
      // If photos conversion fails, use empty list
      safePhotos = [];
    }

    // Safely convert metadata
    Map<String, dynamic> safeMetadata = {};
    try {
      final metadataData = data['metadata'];
      if (metadataData != null && metadataData is Map) {
        // Create a new map with string conversion
        metadataData.forEach((key, value) {
          safeMetadata[key.toString()] = value;
        });
      }
    } catch (e) {
      // If metadata conversion fails, use empty map
      safeMetadata = {};
    }

    // Safely convert string fields
    String safeUserId = '';
    try {
      final userIdData = data['userId'];
      safeUserId = (userIdData ?? '').toString();
    } catch (e) {
      safeUserId = '';
    }

    String safeUserName = 'Anonymous';
    try {
      final userNameData = data['userName'];
      safeUserName = (userNameData ?? 'Anonymous').toString();
    } catch (e) {
      safeUserName = 'Anonymous';
    }

    String safeUserAvatar = '';
    try {
      final userAvatarData = data['userAvatar'];
      safeUserAvatar = (userAvatarData ?? '').toString();
    } catch (e) {
      safeUserAvatar = '';
    }

    String safeTargetId = '';
    try {
      final targetIdData = data['targetId'];
      safeTargetId = (targetIdData ?? '').toString();
    } catch (e) {
      safeTargetId = '';
    }

    String safeTargetType = 'coffee';
    try {
      final targetTypeData = data['targetType'];
      safeTargetType = (targetTypeData ?? 'coffee').toString();
    } catch (e) {
      safeTargetType = 'coffee';
    }

    String safeComment = '';
    try {
      final commentData = data['comment'];
      safeComment = (commentData ?? '').toString();
    } catch (e) {
      safeComment = '';
    }

    // Safely convert rating
    double safeRating = 0.0;
    try {
      final ratingData = data['rating'];
      if (ratingData != null) {
        if (ratingData is double) {
          safeRating = ratingData;
        } else if (ratingData is int) {
          safeRating = ratingData.toDouble();
        } else {
          safeRating = double.tryParse(ratingData.toString()) ?? 0.0;
        }
      }
    } catch (e) {
      safeRating = 0.0;
    }

    // Safely convert timestamps
    DateTime safeCreatedAt = DateTime.now();
    try {
      final createdAtData = data['createdAt'];
      if (createdAtData is Timestamp) {
        safeCreatedAt = createdAtData.toDate();
      } else {
        safeCreatedAt = DateTime.now();
      }
    } catch (e) {
      safeCreatedAt = DateTime.now();
    }

    DateTime safeUpdatedAt = DateTime.now();
    try {
      final updatedAtData = data['updatedAt'];
      if (updatedAtData is Timestamp) {
        safeUpdatedAt = updatedAtData.toDate();
      } else {
        safeUpdatedAt = DateTime.now();
      }
    } catch (e) {
      safeUpdatedAt = DateTime.now();
    }

    return Review(
      id: documentId,
      userId: safeUserId,
      userName: safeUserName,
      userAvatar: safeUserAvatar,
      targetId: safeTargetId,
      targetType: safeTargetType,
      rating: safeRating,
      comment: safeComment,
      photos: safePhotos,
      createdAt: safeCreatedAt,
      updatedAt: safeUpdatedAt,
      metadata: safeMetadata,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'targetId': targetId,
      'targetType': targetType,
      'rating': rating,
      'comment': comment,
      'photos': photos,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'metadata': metadata,
    };
  }

  Review copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userAvatar,
    String? targetId,
    String? targetType,
    double? rating,
    String? comment,
    List<String>? photos,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return Review(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      targetId: targetId ?? this.targetId,
      targetType: targetType ?? this.targetType,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      photos: photos ?? this.photos,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }
}

class ReviewSummary {
  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingDistribution; // {5: 10, 4: 5, 3: 2, 2: 1, 1: 0}

  ReviewSummary({
    required this.averageRating,
    required this.totalReviews,
    required this.ratingDistribution,
  });

  factory ReviewSummary.fromMap(Map<String, dynamic> data) {
    // Safely convert rating distribution
    Map<int, int> safeRatingDistribution = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    
    try {
      final distributionData = data['ratingDistribution'];
      if (distributionData != null && distributionData is Map) {
        // Handle both string keys and int keys from Firestore
        distributionData.forEach((key, value) {
          // Safely convert key to int
          int? intKey;
          if (key is int) {
            intKey = key;
          } else if (key is String) {
            intKey = int.tryParse(key);
          } else {
            intKey = int.tryParse(key.toString());
          }
          
          // Safely convert value to int
          int? intValue;
          if (value is int) {
            intValue = value;
          } else if (value is String) {
            intValue = int.tryParse(value);
          } else {
            intValue = int.tryParse(value.toString());
          }
          
          // Only use valid ratings (1-5)
          if (intKey != null && intValue != null && intKey >= 1 && intKey <= 5) {
            safeRatingDistribution[intKey] = intValue;
          }
        });
      }
    } catch (e) {
      // If conversion fails, use default distribution
      safeRatingDistribution = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    }

    // Safely convert averageRating
    double safeAverageRating = 0.0;
    try {
      final avgData = data['averageRating'];
      if (avgData != null) {
        if (avgData is double) {
          safeAverageRating = avgData;
        } else if (avgData is int) {
          safeAverageRating = avgData.toDouble();
        } else {
          safeAverageRating = double.tryParse(avgData.toString()) ?? 0.0;
        }
      }
    } catch (e) {
      safeAverageRating = 0.0;
    }

    // Safely convert totalReviews
    int safeTotalReviews = 0;
    try {
      final totalData = data['totalReviews'];
      if (totalData != null) {
        if (totalData is int) {
          safeTotalReviews = totalData;
        } else if (totalData is double) {
          safeTotalReviews = totalData.toInt();
        } else {
          safeTotalReviews = int.tryParse(totalData.toString()) ?? 0;
        }
      }
    } catch (e) {
      safeTotalReviews = 0;
    }

    return ReviewSummary(
      averageRating: safeAverageRating,
      totalReviews: safeTotalReviews,
      ratingDistribution: safeRatingDistribution,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'ratingDistribution': ratingDistribution,
    };
  }

  double getRatingPercentage(int rating) {
    if (totalReviews == 0) return 0.0;
    return (ratingDistribution[rating] ?? 0) / totalReviews;
  }
}