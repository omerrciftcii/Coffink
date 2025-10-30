class CoffeeSize {
  final String name;
  final double price;
  final int ml;

  CoffeeSize({
    required this.name,
    required this.price,
    required this.ml,
  });

  factory CoffeeSize.fromMap(Map<String, dynamic> map) {
    return CoffeeSize(
      name: map['name'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      ml: map['ml'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'ml': ml,
    };
  }
}

class NutritionalInfo {
  final int calories;
  final int caffeine;
  final double protein;

  NutritionalInfo({
    required this.calories,
    required this.caffeine,
    required this.protein,
  });

  factory NutritionalInfo.fromMap(Map<String, dynamic> map) {
    return NutritionalInfo(
      calories: map['calories'] ?? 0,
      caffeine: map['caffeine'] ?? 0,
      protein: (map['protein'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'calories': calories,
      'caffeine': caffeine,
      'protein': protein,
    };
  }
}

class Coffee {
  final String id;
  final String name;
  final String description;
  final String detailedDescription;
  final String photoUrl;
  final double basePrice;
  final Map<String, CoffeeSize> sizes;
  final List<String> ingredients;
  final NutritionalInfo? nutritionalInfo;
  final String category;
  final bool isAvailable;
  final int preparationTime;

  Coffee({
    required this.id,
    required this.name,
    required this.description,
    required this.detailedDescription,
    required this.photoUrl,
    required this.basePrice,
    required this.sizes,
    required this.ingredients,
    this.nutritionalInfo,
    required this.category,
    this.isAvailable = true,
    this.preparationTime = 5,
  });

  factory Coffee.fromMap(Map<String, dynamic> data, String documentId) {
    Map<String, CoffeeSize> sizesMap = {};
    if (data['sizes'] != null) {
      try {
        final sizesData = data['sizes'];
        if (sizesData is Map<String, dynamic>) {
          sizesData.forEach((key, value) {
            try {
              if (value is Map<String, dynamic>) {
                sizesMap[key] = CoffeeSize.fromMap(value);
              }
            } catch (e) {
              // Skip invalid size data
            }
          });
        }
      } catch (e) {
        // If sizes conversion fails, use default sizes
      }
    }
    
    // Use default sizes if none were loaded
    if (sizesMap.isEmpty) {
      sizesMap = {
        'small': CoffeeSize(name: 'Küçük', price: 25.0, ml: 250),
        'medium': CoffeeSize(name: 'Orta', price: 35.0, ml: 350),
        'large': CoffeeSize(name: 'Büyük', price: 45.0, ml: 450),
      };
    }

    return Coffee(
      id: documentId,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      detailedDescription: data['detailedDescription'] ?? data['description'] ?? '',
      photoUrl: data['photoUrl'] ?? data['imageUrl'] ?? '',
      basePrice: (data['basePrice'] ?? 25.0).toDouble(),
      sizes: sizesMap,
      ingredients: List<String>.from(data['ingredients'] ?? ['Kahve']),
      nutritionalInfo: data['nutritionalInfo'] != null 
          ? NutritionalInfo.fromMap(data['nutritionalInfo']) 
          : null,
      category: data['category'] ?? 'Kahve',
      isAvailable: data['isAvailable'] ?? true,
      preparationTime: data['preparationTime'] ?? 5,
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> sizesMap = {};
    sizes.forEach((key, value) {
      sizesMap[key] = value.toMap();
    });

    return {
      'name': name,
      'description': description,
      'detailedDescription': detailedDescription,
      'photoUrl': photoUrl,
      'basePrice': basePrice,
      'sizes': sizesMap,
      'ingredients': ingredients,
      'nutritionalInfo': nutritionalInfo?.toMap(),
      'category': category,
      'isAvailable': isAvailable,
      'preparationTime': preparationTime,
    };
  }

  // Helper methods
  double getPriceForSize(String size) {
    return sizes[size]?.price ?? basePrice;
  }

  String getSizeDisplayName(String size) {
    return sizes[size]?.name ?? size;
  }

  List<String> get availableSizes => sizes.keys.toList();

  CoffeeSize? getSizeInfo(String size) {
    return sizes[size];
  }

  // Create a copy with updated values
  Coffee copyWith({
    String? id,
    String? name,
    String? description,
    String? detailedDescription,
    String? photoUrl,
    double? basePrice,
    Map<String, CoffeeSize>? sizes,
    List<String>? ingredients,
    NutritionalInfo? nutritionalInfo,
    String? category,
    bool? isAvailable,
    int? preparationTime,
  }) {
    return Coffee(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      detailedDescription: detailedDescription ?? this.detailedDescription,
      photoUrl: photoUrl ?? this.photoUrl,
      basePrice: basePrice ?? this.basePrice,
      sizes: sizes ?? this.sizes,
      ingredients: ingredients ?? this.ingredients,
      nutritionalInfo: nutritionalInfo ?? this.nutritionalInfo,
      category: category ?? this.category,
      isAvailable: isAvailable ?? this.isAvailable,
      preparationTime: preparationTime ?? this.preparationTime,
    );
  }
}