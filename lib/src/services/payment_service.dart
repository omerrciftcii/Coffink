import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

enum PaymentMethod {
  creditCard,
  debitCard,
  applePay,
  googlePay,
  cashOnDelivery,
  coffeePoints,
}

class PaymentResult {
  final bool success;
  final String? transactionId;
  final String? errorMessage;
  final Map<String, dynamic>? rawResponse;

  PaymentResult({
    required this.success,
    this.transactionId,
    this.errorMessage,
    this.rawResponse,
  });
}

class PaymentService {

  // Process credit/debit card payment
  Future<PaymentResult> processCardPayment({
    required double amount,
    required String cardNumber,
    required String expiryDate,
    required String cvv,
    required String cardHolderName,
    String currency = 'TRY',
  }) async {
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));
      
      // Mock validation
      if (cardNumber.length < 16) {
        return PaymentResult(
          success: false,
          errorMessage: 'Geçersiz kart numarası',
        );
      }
      
      if (cvv.length < 3) {
        return PaymentResult(
          success: false,
          errorMessage: 'Geçersiz CVV',
        );
      }
      
      // Simulate random success/failure (90% success rate)
      final random = Random();
      final isSuccessful = random.nextDouble() > 0.1;
      
      if (isSuccessful) {
        final transactionId = _generateTransactionId();
        return PaymentResult(
          success: true,
          transactionId: transactionId,
          rawResponse: {
            'transaction_id': transactionId,
            'amount': amount,
            'currency': currency,
            'status': 'completed',
            'timestamp': DateTime.now().toIso8601String(),
          },
        );
      } else {
        return PaymentResult(
          success: false,
          errorMessage: 'Ödeme işlemi başarısız oldu. Lütfen tekrar deneyin.',
        );
      }
    } catch (e) {
      return PaymentResult(
        success: false,
        errorMessage: 'Ödeme işlemi sırasında bir hata oluştu: $e',
      );
    }
  }

  // Process Apple Pay payment
  Future<PaymentResult> processApplePayPayment({
    required double amount,
    String currency = 'TRY',
  }) async {
    try {
      // Simulate Apple Pay processing
      await Future.delayed(const Duration(seconds: 1));
      
      final transactionId = _generateTransactionId();
      return PaymentResult(
        success: true,
        transactionId: transactionId,
        rawResponse: {
          'transaction_id': transactionId,
          'amount': amount,
          'currency': currency,
          'payment_method': 'apple_pay',
          'status': 'completed',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      return PaymentResult(
        success: false,
        errorMessage: 'Apple Pay ödemesi başarısız oldu: $e',
      );
    }
  }

  // Process Google Pay payment
  Future<PaymentResult> processGooglePayPayment({
    required double amount,
    String currency = 'TRY',
  }) async {
    try {
      // Simulate Google Pay processing
      await Future.delayed(const Duration(seconds: 1));
      
      final transactionId = _generateTransactionId();
      return PaymentResult(
        success: true,
        transactionId: transactionId,
        rawResponse: {
          'transaction_id': transactionId,
          'amount': amount,
          'currency': currency,
          'payment_method': 'google_pay',
          'status': 'completed',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      return PaymentResult(
        success: false,
        errorMessage: 'Google Pay ödemesi başarısız oldu: $e',
      );
    }
  }

  // Validate coffee points payment
  Future<PaymentResult> processCoffeePointsPayment({
    required double amount,
    required int availablePoints,
  }) async {
    try {
      final pointsRequired = (amount / 0.10).ceil(); // 1 point = 0.10 TL
      
      if (availablePoints < pointsRequired) {
        return PaymentResult(
          success: false,
          errorMessage: 'Yetersiz kahve puanı. Gerekli: $pointsRequired, Mevcut: $availablePoints',
        );
      }
      
      await Future.delayed(const Duration(milliseconds: 500));
      
      final transactionId = _generateTransactionId();
      return PaymentResult(
        success: true,
        transactionId: transactionId,
        rawResponse: {
          'transaction_id': transactionId,
          'amount': amount,
          'points_used': pointsRequired,
          'payment_method': 'coffee_points',
          'status': 'completed',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      return PaymentResult(
        success: false,
        errorMessage: 'Kahve puanı ödemesi başarısız oldu: $e',
      );
    }
  }

  // Refund payment
  Future<PaymentResult> refundPayment({
    required String transactionId,
    required double amount,
  }) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      
      final refundId = _generateTransactionId();
      return PaymentResult(
        success: true,
        transactionId: refundId,
        rawResponse: {
          'refund_id': refundId,
          'original_transaction_id': transactionId,
          'refund_amount': amount,
          'status': 'refunded',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      return PaymentResult(
        success: false,
        errorMessage: 'İade işlemi başarısız oldu: $e',
      );
    }
  }

  // Get supported payment methods based on device and region
  List<PaymentMethod> getSupportedPaymentMethods() {
    // In a real app, this would check device capabilities and regional support
    return [
      PaymentMethod.creditCard,
      PaymentMethod.debitCard,
      PaymentMethod.applePay, // Only on iOS devices
      PaymentMethod.googlePay, // Only on Android devices
      PaymentMethod.cashOnDelivery,
      PaymentMethod.coffeePoints,
    ];
  }

  // Get payment method display name
  String getPaymentMethodDisplayName(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.creditCard:
        return 'Kredi Kartı';
      case PaymentMethod.debitCard:
        return 'Banka Kartı';
      case PaymentMethod.applePay:
        return 'Apple Pay';
      case PaymentMethod.googlePay:
        return 'Google Pay';
      case PaymentMethod.cashOnDelivery:
        return 'Kapıda Ödeme';
      case PaymentMethod.coffeePoints:
        return 'Coffi Puanları';
    }
  }

  // Get payment method icon
  IconData getPaymentMethodIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.creditCard:
      case PaymentMethod.debitCard:
        return Icons.credit_card;
      case PaymentMethod.applePay:
        return Icons.apple;
      case PaymentMethod.googlePay:
        return Icons.payment;
      case PaymentMethod.cashOnDelivery:
        return Icons.money;
      case PaymentMethod.coffeePoints:
        return Icons.star;
    }
  }

  // Calculate coffee points needed for amount
  int calculatePointsNeeded(double amount) {
    return (amount / 0.10).ceil(); // 1 point = 0.10 TL
  }

  // Calculate amount from coffee points
  double calculateAmountFromPoints(int points) {
    return points * 0.10; // 1 point = 0.10 TL
  }

  // Generate a mock transaction ID
  String _generateTransactionId() {
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomPart = random.nextInt(999999).toString().padLeft(6, '0');
    return 'TXN_${timestamp}_$randomPart';
  }

  // Validate card number using Luhn algorithm
  bool validateCardNumber(String cardNumber) {
    final cleanNumber = cardNumber.replaceAll(RegExp(r'\s+'), '');
    if (cleanNumber.length < 13 || cleanNumber.length > 19) return false;
    
    int sum = 0;
    bool alternate = false;
    
    for (int i = cleanNumber.length - 1; i >= 0; i--) {
      int digit = int.parse(cleanNumber[i]);
      
      if (alternate) {
        digit *= 2;
        if (digit > 9) digit -= 9;
      }
      
      sum += digit;
      alternate = !alternate;
    }
    
    return sum % 10 == 0;
  }

  // Format card number for display
  String formatCardNumber(String cardNumber) {
    final cleanNumber = cardNumber.replaceAll(RegExp(r'\s+'), '');
    final buffer = StringBuffer();
    
    for (int i = 0; i < cleanNumber.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(cleanNumber[i]);
    }
    
    return buffer.toString();
  }
}