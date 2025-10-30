import 'package:cloud_firestore/cloud_firestore.dart';

import '../../cart/models/cart_item.dart';

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  ready,
  completed,
  cancelled,
}

enum PaymentStatus {
  pending,
  paid,
  failed,
  refunded,
}

class Order {
  final String id;
  final String userId;
  final String? cafeId;
  final String? cafeName;
  final List<CartItem> items;
  final double subtotal;
  final double tax;
  final double deliveryFee;
  final double discount;
  final double total;
  final OrderStatus status;
  final PaymentStatus paymentStatus;
  final String? paymentMethod;
  final String? paymentTransactionId;
  final Map<String, dynamic>? deliveryAddress;
  final String? specialInstructions;
  final DateTime orderDate;
  final DateTime? estimatedReadyTime;
  final DateTime? completedAt;
  final int pointsEarned;
  final int pointsUsed;

  Order({
    required this.id,
    required this.userId,
    this.cafeId,
    this.cafeName,
    required this.items,
    required this.subtotal,
    required this.tax,
    this.deliveryFee = 0.0,
    this.discount = 0.0,
    required this.total,
    this.status = OrderStatus.pending,
    this.paymentStatus = PaymentStatus.pending,
    this.paymentMethod,
    this.paymentTransactionId,
    this.deliveryAddress,
    this.specialInstructions,
    required this.orderDate,
    this.estimatedReadyTime,
    this.completedAt,
    this.pointsEarned = 0,
    this.pointsUsed = 0,
  });

  factory Order.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Order(
      id: doc.id,
      userId: data['userId'] ?? '',
      cafeId: data['cafeId'],
      cafeName: data['cafeName'],
      items: (data['items'] as List<dynamic>?)
          ?.map((item) => CartItem.fromMap(Map<String, dynamic>.from(item)))
          .toList() ?? [],
      subtotal: (data['subtotal'] ?? 0.0).toDouble(),
      tax: (data['tax'] ?? 0.0).toDouble(),
      deliveryFee: (data['deliveryFee'] ?? 0.0).toDouble(),
      discount: (data['discount'] ?? 0.0).toDouble(),
      total: (data['total'] ?? 0.0).toDouble(),
      status: OrderStatus.values.firstWhere(
        (e) => e.toString() == 'OrderStatus.${data['status']}',
        orElse: () => OrderStatus.pending,
      ),
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.toString() == 'PaymentStatus.${data['paymentStatus']}',
        orElse: () => PaymentStatus.pending,
      ),
      paymentMethod: data['paymentMethod'],
      paymentTransactionId: data['paymentTransactionId'],
      deliveryAddress: data['deliveryAddress'] != null 
          ? Map<String, dynamic>.from(data['deliveryAddress'])
          : null,
      specialInstructions: data['specialInstructions'],
      orderDate: (data['orderDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      estimatedReadyTime: (data['estimatedReadyTime'] as Timestamp?)?.toDate(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      pointsEarned: data['pointsEarned'] ?? 0,
      pointsUsed: data['pointsUsed'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'cafeId': cafeId,
      'cafeName': cafeName,
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'deliveryFee': deliveryFee,
      'discount': discount,
      'total': total,
      'status': status.name,
      'paymentStatus': paymentStatus.name,
      'paymentMethod': paymentMethod,
      'paymentTransactionId': paymentTransactionId,
      'deliveryAddress': deliveryAddress,
      'specialInstructions': specialInstructions,
      'orderDate': Timestamp.fromDate(orderDate),
      'estimatedReadyTime': estimatedReadyTime != null 
          ? Timestamp.fromDate(estimatedReadyTime!)
          : null,
      'completedAt': completedAt != null 
          ? Timestamp.fromDate(completedAt!)
          : null,
      'pointsEarned': pointsEarned,
      'pointsUsed': pointsUsed,
    };
  }

  String get statusDisplayName {
    switch (status) {
      case OrderStatus.pending:
        return 'Beklemede';
      case OrderStatus.confirmed:
        return 'Onaylandı';
      case OrderStatus.preparing:
        return 'Hazırlanıyor';
      case OrderStatus.ready:
        return 'Hazır';
      case OrderStatus.completed:
        return 'Tamamlandı';
      case OrderStatus.cancelled:
        return 'İptal Edildi';
    }
  }

  String get paymentStatusDisplayName {
    switch (paymentStatus) {
      case PaymentStatus.pending:
        return 'Ödeme Bekleniyor';
      case PaymentStatus.paid:
        return 'Ödendi';
      case PaymentStatus.failed:
        return 'Ödeme Başarısız';
      case PaymentStatus.refunded:
        return 'İade Edildi';
    }
  }

  bool get canBeCancelled {
    return status == OrderStatus.pending || status == OrderStatus.confirmed;
  }

  bool get isActive {
    return status != OrderStatus.completed && status != OrderStatus.cancelled;
  }
}