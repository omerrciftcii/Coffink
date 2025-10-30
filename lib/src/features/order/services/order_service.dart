import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

import '../../cart/models/cart_item.dart';
import '../../profile/services/user_profile_service.dart';
import '../models/order_model.dart' show Order, OrderStatus, PaymentStatus;

class OrderService {
  final CollectionReference _ordersCollection = 
      FirebaseFirestore.instance.collection('orders');
  final UserProfileService _userProfileService = UserProfileService();

  // Create a new order
  Future<String> createOrder({
    required List<CartItem> items,
    String? cafeId,
    String? cafeName,
    Map<String, dynamic>? deliveryAddress,
    String? specialInstructions,
    int pointsToUse = 0,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      final subtotal = items.fold<double>(0, (total, item) => total + item.totalPrice);
      final tax = subtotal * 0.18; // 18% tax
      final deliveryFee = deliveryAddress != null ? 15.0 : 0.0; // 15 TL delivery fee
      
      // Calculate discount from points (1 point = 0.10 TL)
      final pointsDiscount = pointsToUse * 0.10;
      final discount = pointsDiscount;
      
      final total = subtotal + tax + deliveryFee - discount;
      
      // Calculate points earned (1 TL = 1 point)
      final pointsEarned = total.floor();
      
      final orderId = const Uuid().v4();
      
      final order = Order(
        id: orderId,
        userId: user.uid,
        cafeId: cafeId,
        cafeName: cafeName,
        items: items,
        subtotal: subtotal,
        tax: tax,
        deliveryFee: deliveryFee,
        discount: discount,
        total: total,
        orderDate: DateTime.now(),
        estimatedReadyTime: DateTime.now().add(const Duration(minutes: 25)),
        pointsEarned: pointsEarned,
        pointsUsed: pointsToUse,
        deliveryAddress: deliveryAddress,
        specialInstructions: specialInstructions,
      );

      await _ordersCollection.doc(orderId).set(order.toFirestore());
      
      // Update user's coffee points
      await _updateUserPoints(user.uid, pointsEarned, pointsToUse);
      
      return orderId;
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  // Get user's orders
  Stream<List<Order>> getUserOrders(String userId) {
    return _ordersCollection
        .where('userId', isEqualTo: userId)
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Order.fromFirestore(doc))
            .toList());
  }

  // Get active orders (not completed or cancelled)
  Stream<List<Order>> getActiveOrders(String userId) {
    return _ordersCollection
        .where('userId', isEqualTo: userId)
        .where('status', whereIn: ['pending', 'confirmed', 'preparing', 'ready'])
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Order.fromFirestore(doc))
            .toList());
  }

  // Get order by ID
  Future<Order?> getOrderById(String orderId) async {
    try {
      final doc = await _ordersCollection.doc(orderId).get();
      if (doc.exists) {
        return Order.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch order: $e');
    }
  }

  // Update order status
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      await _ordersCollection.doc(orderId).update({
        'status': status.name,
        'updatedAt': Timestamp.now(),
        if (status == OrderStatus.completed) 'completedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  // Update payment status
  Future<void> updatePaymentStatus(
    String orderId, 
    PaymentStatus paymentStatus, 
    {String? transactionId, String? paymentMethod}
  ) async {
    try {
      final updates = <String, dynamic>{
        'paymentStatus': paymentStatus.name,
        'updatedAt': Timestamp.now(),
      };
      
      if (transactionId != null) updates['paymentTransactionId'] = transactionId;
      if (paymentMethod != null) updates['paymentMethod'] = paymentMethod;
      
      await _ordersCollection.doc(orderId).update(updates);
      
      // If payment is successful, confirm the order
      if (paymentStatus == PaymentStatus.paid) {
        await updateOrderStatus(orderId, OrderStatus.confirmed);
      }
    } catch (e) {
      throw Exception('Failed to update payment status: $e');
    }
  }

  // Cancel order
  Future<void> cancelOrder(String orderId, {String? reason}) async {
    try {
      final order = await getOrderById(orderId);
      if (order == null) throw Exception('Order not found');
      
      if (!order.canBeCancelled) {
        throw Exception('Order cannot be cancelled at this stage');
      }
      
      await _ordersCollection.doc(orderId).update({
        'status': OrderStatus.cancelled.name,
        'updatedAt': Timestamp.now(),
        if (reason != null) 'cancellationReason': reason,
      });
      
      // Refund points if they were used
      if (order.pointsUsed > 0) {
        await _refundPoints(order.userId, order.pointsUsed);
      }
    } catch (e) {
      throw Exception('Failed to cancel order: $e');
    }
  }

  // Calculate order totals
  Map<String, double> calculateOrderTotals(
    List<CartItem> items, 
    {bool includeDelivery = false, int pointsToUse = 0}
  ) {
    final subtotal = items.fold<double>(0, (total, item) => total + item.totalPrice);
    final tax = subtotal * 0.18;
    final deliveryFee = includeDelivery ? 15.0 : 0.0;
    final discount = pointsToUse * 0.10; // 1 point = 0.10 TL
    final total = subtotal + tax + deliveryFee - discount;
    
    return {
      'subtotal': subtotal,
      'tax': tax,
      'deliveryFee': deliveryFee,
      'discount': discount,
      'total': total,
    };
  }

  // Get order statistics for user
  Future<Map<String, dynamic>> getUserOrderStats(String userId) async {
    try {
      final snapshot = await _ordersCollection
          .where('userId', isEqualTo: userId)
          .get();
      
      final orders = snapshot.docs
          .map((doc) => Order.fromFirestore(doc))
          .toList();
        
        final totalOrders = orders.length;
        final completedOrders = orders.where((o) => o.status == OrderStatus.completed).length;
        final totalSpent = orders
            .where((o) => o.status == OrderStatus.completed)
            .fold<double>(0, (acc, order) => acc + order.total);
        final totalPointsEarned = orders
            .where((o) => o.status == OrderStatus.completed)
            .fold<int>(0, (acc, order) => acc + order.pointsEarned);
      
      return {
        'totalOrders': totalOrders,
        'completedOrders': completedOrders,
        'totalSpent': totalSpent,
        'totalPointsEarned': totalPointsEarned,
      };
    } catch (e) {
      throw Exception('Failed to get order statistics: $e');
    }
  }

  // Private method to update user points
  Future<void> _updateUserPoints(String userId, int pointsEarned, int pointsUsed) async {
    try {
      await _userProfileService.updateCoffeePoints(userId, pointsEarned - pointsUsed);
    } catch (e) {
      throw Exception('Failed to update user points: $e');
    }
  }

  // Private method to refund points
  Future<void> _refundPoints(String userId, int pointsToRefund) async {
    try {
      await _userProfileService.updateCoffeePoints(userId, pointsToRefund);
    } catch (e) {
      throw Exception('Failed to refund points: $e');
    }
  }
}