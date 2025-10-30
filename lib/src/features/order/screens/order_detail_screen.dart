import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/order_model.dart';
import '../services/order_service.dart';

class OrderDetailScreen extends StatefulWidget {
  final Order order;

  const OrderDetailScreen({
    super.key,
    required this.order,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late Order _currentOrder;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentOrder = widget.order;
    dev.log('OrderDetailScreen initialized for order: ${widget.order.id}', 
             name: 'OrderDetailScreen', level: 800);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sipariş #${_currentOrder.id.substring(0, 8)}'),
        backgroundColor: Colors.brown[700],
        foregroundColor: Colors.white,
        actions: [
          if (_currentOrder.canBeCancelled)
            IconButton(
              icon: const Icon(Icons.cancel_outlined),
              onPressed: () => _cancelOrder(),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderStatusCard(),
            const SizedBox(height: 16),
            _buildOrderInfoCard(),
            const SizedBox(height: 16),
            _buildOrderItemsCard(),
            const SizedBox(height: 16),
            _buildPricingCard(),
            if (_currentOrder.deliveryAddress != null) ...[
              const SizedBox(height: 16),
              _buildDeliveryAddressCard(),
            ],
            if (_currentOrder.specialInstructions?.isNotEmpty == true) ...[
              const SizedBox(height: 16),
              _buildSpecialInstructionsCard(),
            ],
            const SizedBox(height: 16),
            _buildPointsCard(),
            if (_currentOrder.canBeCancelled) ...[
              const SizedBox(height: 24),
              _buildActionButtons(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOrderStatusCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _getStatusColor(_currentOrder.status).withValues(alpha: 0.8),
              _getStatusColor(_currentOrder.status),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(
              _getStatusIcon(_currentOrder.status),
              size: 48,
              color: Colors.white,
            ),
            const SizedBox(height: 12),
            Text(
              _currentOrder.statusDisplayName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getStatusDescription(_currentOrder.status),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            if (_currentOrder.estimatedReadyTime != null && _currentOrder.isActive) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.access_time, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Tahmini: ${_formatDateTime(_currentOrder.estimatedReadyTime!)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOrderInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sipariş Bilgileri',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Sipariş Numarası', '#${_currentOrder.id.substring(0, 8)}'),
            _buildInfoRow('Sipariş Tarihi', _formatDateTime(_currentOrder.orderDate)),
            if (_currentOrder.cafeName != null)
              _buildInfoRow('Kafe', _currentOrder.cafeName!),
            _buildInfoRow('Ödeme Durumu', _currentOrder.paymentStatusDisplayName),
            if (_currentOrder.paymentMethod != null)
              _buildInfoRow('Ödeme Yöntemi', _currentOrder.paymentMethod!),
            if (_currentOrder.completedAt != null)
              _buildInfoRow('Tamamlanma Tarihi', _formatDateTime(_currentOrder.completedAt!)),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItemsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sipariş İçeriği (${_currentOrder.items.length} ürün)',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...(_currentOrder.items.map((item) => _buildOrderItemRow(item))),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItemRow(item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              item.coffeeImage,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.brown[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.coffee, color: Colors.brown),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.coffeeName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${item.sizeDisplayName} • ${item.quantity}x',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                if (item.customizations.milkType != 'Tam Yağlı Süt' ||
                    item.customizations.extraShots > 0) ...[
                  const SizedBox(height: 2),
                  Text(
                    _buildCustomizationsText(item.customizations),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.brown[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            '${item.totalPrice.toStringAsFixed(0)} ₺',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.brown[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ödeme Detayı',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildPriceRow('Ara Toplam', _currentOrder.subtotal),
            _buildPriceRow('KDV (%18)', _currentOrder.tax),
            if (_currentOrder.deliveryFee > 0)
              _buildPriceRow('Teslimat Ücreti', _currentOrder.deliveryFee),
            if (_currentOrder.discount > 0)
              _buildPriceRow('İndirim', -_currentOrder.discount, isDiscount: true),
            const Divider(height: 20),
            _buildPriceRow('Toplam', _currentOrder.total, isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryAddressCard() {
    final address = _currentOrder.deliveryAddress!;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.location_on, color: Colors.brown),
                SizedBox(width: 8),
                Text(
                  'Teslimat Adresi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              address['fullAddress'] ?? 'Adres bilgisi bulunamadı',
              style: const TextStyle(fontSize: 14),
            ),
            if (address['phone'] != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    address['phone'],
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialInstructionsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.note, color: Colors.brown),
                SizedBox(width: 8),
                Text(
                  'Özel Talimatlar',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _currentOrder.specialInstructions!,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPointsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.stars, color: Colors.amber),
                SizedBox(width: 8),
                Text(
                  'Coffi Puan Bilgileri',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        _currentOrder.pointsEarned.toString(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const Text(
                        'Kazanılan Coffi Puan',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_currentOrder.pointsUsed > 0) ...[
                  Container(height: 40, width: 1, color: Colors.grey[300]),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          _currentOrder.pointsUsed.toString(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        const Text(
                          'Kullanılan Coffi Puan',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: _isLoading ? null : () => _cancelOrder(),
            icon: _isLoading 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.cancel_outlined),
            label: Text(_isLoading ? 'İptal Ediliyor...' : 'Siparişi İptal Et'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isTotal = false, bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.black : Colors.grey[700],
            ),
          ),
          Text(
            '${isDiscount ? '-' : ''}${amount.abs().toStringAsFixed(2)} ₺',
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: FontWeight.bold,
              color: isTotal 
                  ? Colors.brown[700] 
                  : isDiscount 
                      ? Colors.green
                      : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  String _buildCustomizationsText(customizations) {
    final List<String> customizationsList = [];
    
    if (customizations.milkType != 'Tam Yağlı Süt') {
      customizationsList.add(customizations.milkType);
    }
    
    if (customizations.extraShots > 0) {
      customizationsList.add('+${customizations.extraShots} Shot');
    }
    
    if (customizations.temperature != 'Sıcak') {
      customizationsList.add(customizations.temperature);
    }
    
    return customizationsList.join(', ');
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.preparing:
        return Colors.purple;
      case OrderStatus.ready:
        return Colors.green;
      case OrderStatus.completed:
        return Colors.teal;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.schedule;
      case OrderStatus.confirmed:
        return Icons.check_circle_outline;
      case OrderStatus.preparing:
        return Icons.local_cafe;
      case OrderStatus.ready:
        return Icons.done_all;
      case OrderStatus.completed:
        return Icons.check_circle;
      case OrderStatus.cancelled:
        return Icons.cancel;
    }
  }

  String _getStatusDescription(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Siparişiniz onay bekliyor';
      case OrderStatus.confirmed:
        return 'Siparişiniz onaylandı ve hazırlanmaya başlayacak';
      case OrderStatus.preparing:
        return 'Siparişiniz şu anda hazırlanıyor';
      case OrderStatus.ready:
        return 'Siparişiniz hazır! Teslim alabilirsiniz';
      case OrderStatus.completed:
        return 'Siparişiniz başarıyla tamamlandı';
      case OrderStatus.cancelled:
        return 'Sipariş iptal edildi';
    }
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _cancelOrder() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Siparişi İptal Et'),
          content: const Text('Bu siparişi iptal etmek istediğinizden emin misiniz? İptal edilen siparişler geri alınamaz.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Hayır'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Evet, İptal Et'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        final orderService = context.read<OrderService>();
        await orderService.cancelOrder(_currentOrder.id, reason: 'Kullanıcı tarafından iptal edildi');
        
        // Update the current order status
        setState(() {
          _currentOrder = Order(
            id: _currentOrder.id,
            userId: _currentOrder.userId,
            cafeId: _currentOrder.cafeId,
            cafeName: _currentOrder.cafeName,
            items: _currentOrder.items,
            subtotal: _currentOrder.subtotal,
            tax: _currentOrder.tax,
            deliveryFee: _currentOrder.deliveryFee,
            discount: _currentOrder.discount,
            total: _currentOrder.total,
            status: OrderStatus.cancelled,
            paymentStatus: _currentOrder.paymentStatus,
            paymentMethod: _currentOrder.paymentMethod,
            paymentTransactionId: _currentOrder.paymentTransactionId,
            deliveryAddress: _currentOrder.deliveryAddress,
            specialInstructions: _currentOrder.specialInstructions,
            orderDate: _currentOrder.orderDate,
            estimatedReadyTime: _currentOrder.estimatedReadyTime,
            completedAt: _currentOrder.completedAt,
            pointsEarned: _currentOrder.pointsEarned,
            pointsUsed: _currentOrder.pointsUsed,
          );
          _isLoading = false;
        });
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sipariş başarıyla iptal edildi'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        
        dev.log('Order cancelled: ${_currentOrder.id}', name: 'OrderDetailScreen', level: 800);
      } catch (e) {
        dev.log('Error cancelling order', name: 'OrderDetailScreen', error: e, level: 1000);
        
        setState(() {
          _isLoading = false;
        });
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Sipariş iptal edilemedi: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}