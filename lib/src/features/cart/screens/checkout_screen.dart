
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/cart_service.dart';
import '../../order/services/order_service.dart';
import '../../order/models/order_model.dart';
import '../../profile/services/user_profile_service.dart';
import '../../../services/payment_service.dart';
import '../../../services/location_service.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  
  // Order type
  String _orderType = 'pickup'; // pickup or delivery
  
  // Delivery address
  final _addressController = TextEditingController();
  final _instructionsController = TextEditingController();
  
  // Payment
  PaymentMethod _selectedPaymentMethod = PaymentMethod.creditCard;
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardHolderController = TextEditingController();
  
  // Points
  int _pointsToUse = 0;
  
  bool _isProcessing = false;

  @override
  void dispose() {
    _addressController.dispose();
    _instructionsController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _cardHolderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ödeme'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Column(
        children: [
          _buildStepIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentStep = index;
                });
              },
              children: [
                _buildOrderTypeStep(),
                _buildPaymentStep(),
                _buildConfirmationStep(),
              ],
            ),
          ),
          if (!_isProcessing) _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildStepCircle(0, 'Teslimat'),
          Expanded(child: _buildStepLine(0)),
          _buildStepCircle(1, 'Ödeme'),
          Expanded(child: _buildStepLine(1)),
          _buildStepCircle(2, 'Onay'),
        ],
      ),
    );
  }

  Widget _buildStepCircle(int step, String label) {
    final isActive = step <= _currentStep;
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isActive ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surfaceVariant,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: step < _currentStep
                ? Icon(Icons.check, color: Theme.of(context).colorScheme.onPrimary, size: 20)
                : Text(
                    '${step + 1}',
                    style: TextStyle(
                      color: isActive ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(int step) {
    return Container(
      height: 2,
      margin: const EdgeInsets.only(bottom: 20),
      color: step < _currentStep ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surfaceVariant,
    );
  }

  Widget _buildOrderTypeStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Teslimat Türü',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          // Order type selection
          Card(
            child: Column(
              children: [
                RadioListTile<String>(
                  title: const Text('Mağazadan Al'),
                  subtitle: const Text('Hazır olduğunda mağazadan alın'),
                  value: 'pickup',
                  groupValue: _orderType,
                  onChanged: (value) {
                    setState(() {
                      _orderType = value!;
                    });
                  },
                  toggleable: true,
                ),
                const Divider(height: 1),
                RadioListTile<String>(
                  title: const Text('Teslimat'),
                  subtitle: const Text('Adresinize teslim edelim (+15₺)'),
                  value: 'delivery',
                  groupValue: _orderType,
                  onChanged: (value) {
                    setState(() {
                      _orderType = value!;
                    });
                  },
                  toggleable: true,
                ),
              ],
            ),
          ),
          
          // Delivery address (only if delivery is selected)
          if (_orderType == 'delivery') ...[
            const SizedBox(height: 20),
            const Text(
              'Teslimat Adresi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Adres',
                        hintText: 'Tam adresinizi girin',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _instructionsController,
                      decoration: const InputDecoration(
                        labelText: 'Teslimat Notu (Opsiyonel)',
                        hintText: 'Kapı kodu, tarif vb.',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Consumer<LocationService>(
                      builder: (context, locationService, child) {
                        return ElevatedButton.icon(
                          onPressed: () async {
                            final position = await locationService.getCurrentLocation();
                            if (position != null) {
                              _addressController.text = 
                                  'Enlem: ${position.latitude.toStringAsFixed(6)}, '
                                  'Boylam: ${position.longitude.toStringAsFixed(6)}';
                            }
                          },
                          icon: const Icon(Icons.my_location),
                          label: const Text('Mevcut Konumu Kullan'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Consumer<UserProfileService>(
        builder: (context, profileService, child) {
          return StreamBuilder(
            stream: profileService.getCurrentUserProfile(),
            builder: (context, snapshot) {
              final userProfile = snapshot.data;
              final availablePoints = userProfile?.coffeePoints ?? 0;
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ödeme Yöntemi',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  // Payment method selection
                  Card(
                    child: Column(
                      children: PaymentMethod.values.map((method) {
                        final service = Provider.of<PaymentService>(context);
                        return RadioListTile<PaymentMethod>(
                          title: Text(service.getPaymentMethodDisplayName(method)),
                          secondary: Icon(service.getPaymentMethodIcon(method)),
                          value: method,
                          groupValue: _selectedPaymentMethod,
                          onChanged: (value) {
                            setState(() {
                              _selectedPaymentMethod = value!;
                            });
                          },
                          toggleable: true,
                        );
                      }).toList(),
                    ),
                  ),
                  
                  // Credit card form
                  if (_selectedPaymentMethod == PaymentMethod.creditCard ||
                      _selectedPaymentMethod == PaymentMethod.debitCard) ...[
                    const SizedBox(height: 20),
                    const Text(
                      'Kart Bilgileri',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            TextField(
                              controller: _cardNumberController,
                              decoration: const InputDecoration(
                                labelText: 'Kart Numarası',
                                hintText: '1234 5678 9012 3456',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _expiryController,
                                    decoration: const InputDecoration(
                                      labelText: 'Son Kullanma',
                                      hintText: 'MM/YY',
                                      border: OutlineInputBorder(),
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    controller: _cvvController,
                                    decoration: const InputDecoration(
                                      labelText: 'CVV',
                                      hintText: '123',
                                      border: OutlineInputBorder(),
                                    ),
                                    keyboardType: TextInputType.number,
                                    obscureText: true,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _cardHolderController,
                              decoration: const InputDecoration(
                                labelText: 'Kart Sahibi',
                                hintText: 'Ad Soyad',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  
                  // Coffee points section
                  if (availablePoints > 0) ...[
                    const SizedBox(height: 20),
                    const Text(
                      'Coffi Puanları',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Mevcut Puanlar: $availablePoints'),
                                Text('Değer: ${(availablePoints * 0.10).toStringAsFixed(2)} ₺'),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Text('Kullanılacak Puan: '),
                                Expanded(
                                  child: Slider(
                                    value: _pointsToUse.toDouble(),
                                    min: 0,
                                    max: availablePoints.toDouble(),
                                    divisions: availablePoints,
                                    label: '$_pointsToUse puan',
                                    onChanged: (value) {
                                      setState(() {
                                        _pointsToUse = value.round();
                                      });
                                    },
                                  ),
                                ),
                                Text('$_pointsToUse'),
                              ],
                            ),
                            if (_pointsToUse > 0)
                              Text(
                                'İndirim: ${(_pointsToUse * 0.10).toStringAsFixed(2)} ₺',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.secondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildConfirmationStep() {
    return Consumer<CartService>(
      builder: (context, cartService, child) {
        final cart = cartService.cart;
        final orderService = Provider.of<OrderService>(context);
        final totals = orderService.calculateOrderTotals(
          cart.items,
          includeDelivery: _orderType == 'delivery',
          pointsToUse: _pointsToUse,
        );
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sipariş Özeti',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              // Order items
              Card(
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.coffee),
                          SizedBox(width: 8),
                          Text(
                            'Sipariş Detayları',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    ...cart.items.map((item) => ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network(
                          item.coffeeImage,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 40,
                              height: 40,
                              color: Theme.of(context).colorScheme.surfaceVariant,
                              child: const Icon(Icons.coffee, size: 20),
                            );
                          },
                        ),
                      ),
                      title: Text(item.coffeeName),
                      subtitle: Text('${item.sizeDisplayName} x${item.quantity}'),
                      trailing: Text(
                        '${item.totalPrice.toStringAsFixed(0)} ₺',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    )),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Delivery info
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(_orderType == 'delivery' ? Icons.delivery_dining : Icons.store),
                          const SizedBox(width: 8),
                          Text(
                            _orderType == 'delivery' ? 'Teslimat' : 'Mağazadan Al',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (_orderType == 'delivery') ...[
                        Text(_addressController.text),
                        if (_instructionsController.text.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Not: ${_instructionsController.text}',
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                          ),
                        ],
                      ] else ...[
                        const Text('Sipariş hazır olduğunda mağazadan alabilirsiniz.'),
                      ],
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Payment info
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.payment),
                          SizedBox(width: 8),
                          Text(
                            'Ödeme',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(Provider.of<PaymentService>(context)
                          .getPaymentMethodDisplayName(_selectedPaymentMethod)),
                      if (_selectedPaymentMethod == PaymentMethod.creditCard ||
                          _selectedPaymentMethod == PaymentMethod.debitCard) ...[
                        const SizedBox(height: 4),
                        Text(
                          '**** **** **** ${_cardNumberController.text.length >= 4 ? _cardNumberController.text.substring(_cardNumberController.text.length - 4) : '****'}',
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Order total
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildTotalRow('Ara Toplam', totals['subtotal']!),
                      _buildTotalRow('KDV (%18)', totals['tax']!),
                      if (_orderType == 'delivery')
                        _buildTotalRow('Teslimat', totals['deliveryFee']!),
                      if (_pointsToUse > 0)
                        _buildTotalRow('Puan İndirimi', -totals['discount']!, isDiscount: true),
                      const Divider(),
                      _buildTotalRow('Toplam', totals['total']!, isTotal: true),
                    ],
                  ),
                ),
              ),
              
              if (_isProcessing) ...[
                const SizedBox(height: 24),
                const Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Siparişiniz işleniyor...'),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildTotalRow(String label, double amount, {bool isTotal = false, bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isDiscount ? Theme.of(context).colorScheme.secondary : null,
            ),
          ),
          Text(
            '${amount.toStringAsFixed(2)} ₺',
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: FontWeight.bold,
              color: isTotal ? Theme.of(context).colorScheme.primary : (isDiscount ? Theme.of(context).colorScheme.secondary : null),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: const Text('Geri'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _canContinue() ? _handleNextStep : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              child: Text(_currentStep == 2 ? 'Siparişi Tamamla' : 'İleri'),
            ),
          ),
        ],
      ),
    );
  }

  bool _canContinue() {
    switch (_currentStep) {
      case 0: // Order type step
        if (_orderType == 'delivery') {
          return _addressController.text.isNotEmpty;
        }
        return true;
      case 1: // Payment step
        if (_selectedPaymentMethod == PaymentMethod.creditCard ||
            _selectedPaymentMethod == PaymentMethod.debitCard) {
          return _cardNumberController.text.isNotEmpty &&
                 _expiryController.text.isNotEmpty &&
                 _cvvController.text.isNotEmpty &&
                 _cardHolderController.text.isNotEmpty;
        }
        return true;
      case 2: // Confirmation step
        return true;
      default:
        return true;
    }
  }

  void _handleNextStep() {
    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _placeOrder();
    }
  }

  Future<void> _placeOrder() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final cartService = Provider.of<CartService>(context, listen: false);
      final orderService = Provider.of<OrderService>(context, listen: false);
      final paymentService = Provider.of<PaymentService>(context, listen: false);
      
      // Create order
      final orderId = await orderService.createOrder(
        items: cartService.cart.items,
        deliveryAddress: _orderType == 'delivery' ? {
          'address': _addressController.text,
          'instructions': _instructionsController.text,
        } : null,
        specialInstructions: _instructionsController.text,
        pointsToUse: _pointsToUse,
      );
      
      // Process payment
      PaymentResult paymentResult;
      final totals = orderService.calculateOrderTotals(
        cartService.cart.items,
        includeDelivery: _orderType == 'delivery',
        pointsToUse: _pointsToUse,
      );
      
      switch (_selectedPaymentMethod) {
        case PaymentMethod.creditCard:
        case PaymentMethod.debitCard:
          paymentResult = await paymentService.processCardPayment(
            amount: totals['total']!,
            cardNumber: _cardNumberController.text,
            expiryDate: _expiryController.text,
            cvv: _cvvController.text,
            cardHolderName: _cardHolderController.text,
          );
          break;
        case PaymentMethod.applePay:
          paymentResult = await paymentService.processApplePayPayment(
            amount: totals['total']!,
          );
          break;
        case PaymentMethod.googlePay:
          paymentResult = await paymentService.processGooglePayPayment(
            amount: totals['total']!,
          );
          break;
        default:
          paymentResult = PaymentResult(
            success: true,
            transactionId: 'COD_${DateTime.now().millisecondsSinceEpoch}',
          );
      }
      
      // Update order payment status
      await orderService.updatePaymentStatus(
        orderId,
        paymentResult.success ? PaymentStatus.paid : PaymentStatus.failed,
        transactionId: paymentResult.transactionId,
        paymentMethod: paymentService.getPaymentMethodDisplayName(_selectedPaymentMethod),
      );
      
      if (paymentResult.success) {
        // Clear cart
        await cartService.clearCart();
        
        // Show success and navigate back
        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Siparişiniz başarıyla alındı!'),
              backgroundColor: Theme.of(context).colorScheme.secondary,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        throw Exception(paymentResult.errorMessage ?? 'Ödeme başarısız');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sipariş oluşturulurken hata: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
}
