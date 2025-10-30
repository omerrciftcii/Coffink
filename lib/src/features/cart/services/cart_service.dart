import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/cart.dart';
import '../models/cart_item.dart';
import '../../home/models/coffee_model.dart';
import '../../../utils/logger.dart';

class CartService extends ChangeNotifier {
  static const String _cartKey = 'user_cart';
  Cart _cart = Cart.empty();
  bool _isLoading = false;

  Cart get cart => _cart;
  bool get isLoading => _isLoading;
  int get itemCount => _cart.totalItems;
  double get totalPrice => _cart.totalPrice;

  CartService() {
    _loadCart();
  }

  Future<void> _loadCart() async {
    try {
      _logInfo('Loading cart from local storage');
      _isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString(_cartKey);
      
      if (cartJson != null) {
        final cartMap = jsonDecode(cartJson) as Map<String, dynamic>;
        _cart = Cart.fromMap(cartMap);
        _logInfo('Cart loaded successfully: ${_cart.totalItems} items');
      } else {
        _cart = Cart.empty();
        _logInfo('No saved cart found, starting with empty cart');
      }
    } catch (e) {
      _logError('Error loading cart from storage', e);
      _cart = Cart.empty();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveCart() async {
    try {
      _logDebug('Saving cart to local storage');
      final prefs = await SharedPreferences.getInstance();
      final cartJson = jsonEncode(_cart.toMap());
      await prefs.setString(_cartKey, cartJson);
      _logDebug('Cart saved successfully');
    } catch (e) {
      _logError('Error saving cart to storage', e);
    }
  }

  Future<void> addToCart(Coffee coffee, String size, CartCustomizations customizations, {int quantity = 1}) async {
    try {
      _logInfo('Adding to cart: ${coffee.name}, Size: $size, Quantity: $quantity');
      
      final sizeInfo = coffee.getSizeInfo(size);
      if (sizeInfo == null) {
        throw Exception('Invalid size selected: $size');
      }

      final cartItem = CartItem(
        id: _generateCartItemId(),
        coffeeId: coffee.id,
        coffeeName: coffee.name,
        coffeeImage: coffee.photoUrl,
        size: size,
        basePrice: sizeInfo.price,
        quantity: quantity,
        customizations: customizations,
        addedAt: DateTime.now(),
      );

      _cart = _cart.addItem(cartItem);
      await _saveCart();
      
      _logInfo('Item added to cart successfully. Total items: ${_cart.totalItems}');
      notifyListeners();
    } catch (e) {
      _logError('Error adding item to cart', e);
      rethrow;
    }
  }

  Future<void> removeFromCart(String itemId) async {
    try {
      _logInfo('Removing item from cart: $itemId');
      _cart = _cart.removeItem(itemId);
      await _saveCart();
      
      _logInfo('Item removed from cart successfully. Total items: ${_cart.totalItems}');
      notifyListeners();
    } catch (e) {
      _logError('Error removing item from cart', e);
      rethrow;
    }
  }

  Future<void> updateQuantity(String itemId, int newQuantity) async {
    try {
      _logInfo('Updating item quantity: $itemId, New quantity: $newQuantity');
      _cart = _cart.updateItemQuantity(itemId, newQuantity);
      await _saveCart();
      
      _logInfo('Item quantity updated successfully');
      notifyListeners();
    } catch (e) {
      _logError('Error updating item quantity', e);
      rethrow;
    }
  }

  Future<void> clearCart() async {
    try {
      _logInfo('Clearing cart');
      _cart = _cart.clearCart();
      await _saveCart();
      
      _logInfo('Cart cleared successfully');
      notifyListeners();
    } catch (e) {
      _logError('Error clearing cart', e);
      rethrow;
    }
  }

  Future<void> increaseQuantity(String itemId) async {
    final item = _cart.getItem(itemId);
    if (item != null) {
      await updateQuantity(itemId, item.quantity + 1);
    }
  }

  Future<void> decreaseQuantity(String itemId) async {
    final item = _cart.getItem(itemId);
    if (item != null && item.quantity > 1) {
      await updateQuantity(itemId, item.quantity - 1);
    } else if (item != null) {
      await removeFromCart(itemId);
    }
  }

  bool isItemInCart(String coffeeId, String size, CartCustomizations customizations) {
    return _cart.items.any((item) =>
        item.coffeeId == coffeeId &&
        item.size == size &&
        _areCustomizationsSame(item.customizations, customizations));
  }

  CartItem? getCartItem(String coffeeId, String size, CartCustomizations customizations) {
    try {
      return _cart.items.firstWhere((item) =>
          item.coffeeId == coffeeId &&
          item.size == size &&
          _areCustomizationsSame(item.customizations, customizations));
    } catch (e) {
      return null;
    }
  }

  String _generateCartItemId() {
    return 'cart_${DateTime.now().millisecondsSinceEpoch}_${_cart.items.length}';
  }

  bool _areCustomizationsSame(CartCustomizations a, CartCustomizations b) {
    return a.milkType == b.milkType &&
           a.sweetness == b.sweetness &&
           a.temperature == b.temperature &&
           a.extraShots == b.extraShots;
  }

  // Logging methods
  void _logDebug(String message) {
    Logger.debug(message, name: 'CartService', category: LogCategory.cart);
  }

  void _logInfo(String message) {
    Logger.cartAction(message, name: 'CartService');
  }

  void _logError(String message, [dynamic error]) {
    Logger.cartAction(message, name: 'CartService', error: error);
  }
}