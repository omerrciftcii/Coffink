import 'package:cloud_firestore/cloud_firestore.dart';

class Cafe {
  final String id;
  final String name;
  final String description;
  final String address;
  final double latitude;
  final double longitude;
  final String photoUrl;
  final double rating;
  final int reviewCount;
  final List<String> amenities;
  final Map<String, dynamic> operatingHours;
  final String phoneNumber;
  final String website;
  final bool isPartner;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? distanceFromUser;

  // Computed property for backward compatibility
  String get imageUrl => photoUrl;

  Cafe({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.photoUrl,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.amenities = const [],
    this.operatingHours = const {},
    this.phoneNumber = '',
    this.website = '',
    this.isPartner = false,
    required this.createdAt,
    required this.updatedAt,
    this.distanceFromUser,
  });

  factory Cafe.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Cafe(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      address: data['address'] ?? '',
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
      photoUrl: data['photoUrl'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      amenities: List<String>.from(data['amenities'] ?? []),
      operatingHours: Map<String, dynamic>.from(data['operatingHours'] ?? {}),
      phoneNumber: data['phoneNumber'] ?? '',
      website: data['website'] ?? '',
      isPartner: data['isPartner'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'photoUrl': photoUrl,
      'rating': rating,
      'reviewCount': reviewCount,
      'amenities': amenities,
      'operatingHours': operatingHours,
      'phoneNumber': phoneNumber,
      'website': website,
      'isPartner': isPartner,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  double distanceFrom(double userLat, double userLng) {
    // Simple distance calculation (Haversine formula)
    const double earthRadius = 6371; // km
    double latDiff = (latitude - userLat) * (3.14159 / 180);
    double lngDiff = (longitude - userLng) * (3.14159 / 180);

    double a = (latDiff / 2) * (latDiff / 2) +
        (userLat * 3.14159 / 180) * (latitude * 3.14159 / 180) *
        (lngDiff / 2) * (lngDiff / 2);
    // Simplified Haversine: c = 2 * atan2(sqrt(a), sqrt(1-a))
    // Using approximation for small distances
    double c = 2 * (a < 0.5 ? a.abs() : (1 - a).abs());
    return earthRadius * c;
  }

  bool get isOpen {
    final now = DateTime.now();
    final dayName = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'][now.weekday - 1];
    
    if (!operatingHours.containsKey(dayName)) return false;
    
    final dayHours = operatingHours[dayName];
    if (dayHours == null || dayHours['closed'] == true) return false;
    
    final openTime = dayHours['open'] as String?;
    final closeTime = dayHours['close'] as String?;
    
    if (openTime == null || closeTime == null) return false;
    
    // Simple time comparison (would need more robust parsing in production)
    final currentHour = now.hour;
    final openHour = int.tryParse(openTime.split(':')[0]) ?? 0;
    final closeHour = int.tryParse(closeTime.split(':')[0]) ?? 24;
    
    return currentHour >= openHour && currentHour < closeHour;
  }
}