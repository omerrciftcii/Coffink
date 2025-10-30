class CartCustomizations {
  final String milkType;
  final int sweetness;
  final String temperature;
  final int extraShots;

  CartCustomizations({
    this.milkType = 'Tam Yağlı Süt',
    this.sweetness = 3,
    this.temperature = 'Sıcak',
    this.extraShots = 0,
  });

  factory CartCustomizations.fromMap(Map<String, dynamic> map) {
    return CartCustomizations(
      milkType: map['milkType'] ?? 'Tam Yağlı Süt',
      sweetness: map['sweetness'] ?? 3,
      temperature: map['temperature'] ?? 'Sıcak',
      extraShots: map['extraShots'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'milkType': milkType,
      'sweetness': sweetness,
      'temperature': temperature,
      'extraShots': extraShots,
    };
  }

  CartCustomizations copyWith({
    String? milkType,
    int? sweetness,
    String? temperature,
    int? extraShots,
  }) {
    return CartCustomizations(
      milkType: milkType ?? this.milkType,
      sweetness: sweetness ?? this.sweetness,
      temperature: temperature ?? this.temperature,
      extraShots: extraShots ?? this.extraShots,
    );
  }

  String getSweetnessLabel() {
    switch (sweetness) {
      case 1: return 'Şekersiz';
      case 2: return 'Az Tatlı';
      case 3: return 'Orta Tatlı';
      case 4: return 'Tatlı';
      case 5: return 'Çok Tatlı';
      default: return 'Orta Tatlı';
    }
  }
}

class CartItem {
  final String id;
  final String coffeeId;
  final String coffeeName;
  final String coffeeImage;
  final String size;
  final double basePrice;
  final int quantity;
  final CartCustomizations customizations;
  final DateTime addedAt;

  CartItem({
    required this.id,
    required this.coffeeId,
    required this.coffeeName,
    required this.coffeeImage,
    required this.size,
    required this.basePrice,
    this.quantity = 1,
    required this.customizations,
    required this.addedAt,
  });

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'] ?? '',
      coffeeId: map['coffeeId'] ?? '',
      coffeeName: map['coffeeName'] ?? '',
      coffeeImage: map['coffeeImage'] ?? '',
      size: map['size'] ?? 'medium',
      basePrice: (map['basePrice'] ?? 0.0).toDouble(),
      quantity: map['quantity'] ?? 1,
      customizations: CartCustomizations.fromMap(map['customizations'] ?? {}),
      addedAt: DateTime.parse(map['addedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'coffeeId': coffeeId,
      'coffeeName': coffeeName,
      'coffeeImage': coffeeImage,
      'size': size,
      'basePrice': basePrice,
      'quantity': quantity,
      'customizations': customizations.toMap(),
      'addedAt': addedAt.toIso8601String(),
    };
  }

  double get totalPrice {
    double extraShotPrice = customizations.extraShots * 5.0; // 5 TL per extra shot
    return (basePrice + extraShotPrice) * quantity;
  }

  String get sizeDisplayName {
    switch (size) {
      case 'small': return 'Küçük';
      case 'medium': return 'Orta';
      case 'large': return 'Büyük';
      default: return size;
    }
  }

  CartItem copyWith({
    String? id,
    String? coffeeId,
    String? coffeeName,
    String? coffeeImage,
    String? size,
    double? basePrice,
    int? quantity,
    CartCustomizations? customizations,
    DateTime? addedAt,
  }) {
    return CartItem(
      id: id ?? this.id,
      coffeeId: coffeeId ?? this.coffeeId,
      coffeeName: coffeeName ?? this.coffeeName,
      coffeeImage: coffeeImage ?? this.coffeeImage,
      size: size ?? this.size,
      basePrice: basePrice ?? this.basePrice,
      quantity: quantity ?? this.quantity,
      customizations: customizations ?? this.customizations,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}