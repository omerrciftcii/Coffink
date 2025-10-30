import 'cart_item.dart';

class Cart {
  final List<CartItem> items;
  final DateTime updatedAt;

  Cart({
    this.items = const [],
    required this.updatedAt,
  });

  factory Cart.empty() {
    return Cart(
      items: [],
      updatedAt: DateTime.now(),
    );
  }

  factory Cart.fromMap(Map<String, dynamic> map) {
    return Cart(
      items: (map['items'] as List<dynamic>?)
          ?.map((item) => CartItem.fromMap(item as Map<String, dynamic>))
          .toList() ?? [],
      updatedAt: DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'items': items.map((item) => item.toMap()).toList(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice => items.fold(0.0, (sum, item) => sum + item.totalPrice);

  double get subtotal => totalPrice;

  double get tax => totalPrice * 0.18; // KDV %18

  double get total => subtotal + tax;

  bool get isEmpty => items.isEmpty;

  bool get isNotEmpty => items.isNotEmpty;

  Cart addItem(CartItem item) {
    List<CartItem> updatedItems = List.from(items);
    
    // Check if item with same coffee, size, and customizations already exists
    final existingIndex = updatedItems.indexWhere((existing) => 
      existing.coffeeId == item.coffeeId && 
      existing.size == item.size &&
      _areCustomizationsSame(existing.customizations, item.customizations)
    );

    if (existingIndex != -1) {
      // Update quantity of existing item
      updatedItems[existingIndex] = updatedItems[existingIndex].copyWith(
        quantity: updatedItems[existingIndex].quantity + item.quantity,
      );
    } else {
      // Add as new item
      updatedItems.add(item);
    }

    return Cart(
      items: updatedItems,
      updatedAt: DateTime.now(),
    );
  }

  Cart removeItem(String itemId) {
    return Cart(
      items: items.where((item) => item.id != itemId).toList(),
      updatedAt: DateTime.now(),
    );
  }

  Cart updateItemQuantity(String itemId, int newQuantity) {
    if (newQuantity <= 0) {
      return removeItem(itemId);
    }

    final updatedItems = items.map((item) {
      if (item.id == itemId) {
        return item.copyWith(quantity: newQuantity);
      }
      return item;
    }).toList();

    return Cart(
      items: updatedItems,
      updatedAt: DateTime.now(),
    );
  }

  Cart clearCart() {
    return Cart(
      items: [],
      updatedAt: DateTime.now(),
    );
  }

  CartItem? getItem(String itemId) {
    try {
      return items.firstWhere((item) => item.id == itemId);
    } catch (e) {
      return null;
    }
  }

  bool containsItem(String itemId) {
    return items.any((item) => item.id == itemId);
  }

  List<CartItem> get sortedItems {
    List<CartItem> sorted = List.from(items);
    sorted.sort((a, b) => b.addedAt.compareTo(a.addedAt)); // Most recent first
    return sorted;
  }

  Cart copyWith({
    List<CartItem>? items,
    DateTime? updatedAt,
  }) {
    return Cart(
      items: items ?? this.items,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool _areCustomizationsSame(CartCustomizations a, CartCustomizations b) {
    return a.milkType == b.milkType &&
           a.sweetness == b.sweetness &&
           a.temperature == b.temperature &&
           a.extraShots == b.extraShots;
  }

  @override
  String toString() {
    return 'Cart(items: ${items.length}, total: $total TL)';
  }
}