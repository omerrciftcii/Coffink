
import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/cart_service.dart';
import '../models/cart_item.dart';
import 'checkout_screen.dart';
import '../../home/services/coffee_service.dart';
import '../../coffee/screens/coffee_detail_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
    dev.log('CartScreen initialized', name: 'CartScreen', level: 800);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.shopping_cart_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Sepetim',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.background,
        foregroundColor: Theme.of(context).colorScheme.onBackground,
        elevation: 0,
        actions: [
          Consumer<CartService>(
            builder: (context, cartService, _) {
              if (cartService.cart.isEmpty) return const SizedBox.shrink();
              
              return IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _showClearCartDialog(context, cartService),
                tooltip: 'Sepeti Temizle',
              );
            },
          ),
        ],
      ),
      body: Consumer<CartService>(
        builder: (context, cartService, _) {
          if (cartService.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (cartService.cart.isEmpty) {
            return _buildEmptyCart();
          }

          return Column(
            children: [
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cartService.cart.sortedItems.length,
                    itemBuilder: (context, index) {
                      final item = cartService.cart.sortedItems[index];
                      return _buildCartItem(item, cartService);
                    },
                  ),
                ),
              ),
              _buildOrderSummary(cartService.cart.total),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyCart() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 120,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            ),
            const SizedBox(height: 24),
            Text(
              'Sepetiniz Boş',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Lezzetli kahvelerimizi keşfetmek için\nana sayfaya göz atın',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  dev.log('Navigate to home from empty cart', name: 'CartScreen', level: 800);
                },
                icon: const Icon(Icons.coffee_rounded),
                label: const Text(
                  'Kahveleri Keşfet',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItem(CartItem item, CartService cartService) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Dismissible(
        key: Key(item.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.error,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.delete,
            color: Theme.of(context).colorScheme.onError,
            size: 32,
          ),
        ),
        confirmDismiss: (direction) async {
          return await _showRemoveItemDialog(context, item);
        },
        onDismissed: (direction) {
          _removeItem(cartService, item);
        },
        child: GestureDetector(
          onTap: () async {
            try {
              dev.log('Fetching coffee details for ID: ${item.coffeeId}', name: 'CartScreen', level: 800);
              final coffeeService = CoffeeService.fromContext(context);
              final coffee = await coffeeService.getCoffeeById(item.coffeeId);
              if (coffee != null && mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CoffeeDetailScreen(coffee: coffee),
                  ),
                );
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ürün detayları bulunamadı')),
                );
              }
            } catch (e) {
              dev.log('Error fetching coffee details', name: 'CartScreen', error: e, level: 1000);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ürün detayları yüklenemedi')),
                );
              }
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Coffee Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    item.coffeeImage,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.coffee, color: Theme.of(context).colorScheme.onSecondaryContainer),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                
                // Item Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.coffeeName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.sizeDisplayName,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      if (item.customizations.milkType != 'Tam Yağlı Süt') ...[
                        const SizedBox(height: 2),
                        Text(
                          item.customizations.milkType,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                      if (item.customizations.extraShots > 0) ...[
                        const SizedBox(height: 2),
                        Text(
                          '+${item.customizations.extraShots} Shot',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        '${item.totalPrice.toStringAsFixed(0)} ₺',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Quantity Controls
                Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildQuantityButton(
                          icon: Icons.remove,
                          onPressed: () => _decreaseQuantity(cartService, item),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item.quantity.toString(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        _buildQuantityButton(
                          icon: Icons.add,
                          onPressed: () => _increaseQuantity(cartService, item),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.onSecondaryContainer,
        ),
      ),
    );
  }

  Widget _buildOrderSummary(double total) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -2),
            blurRadius: 8,
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Consumer<CartService>(
              builder: (context, cartService, _) {
                return Column(
                  children: [
                    _buildSummaryRow('Ara Toplam', cartService.cart.subtotal),
                    const SizedBox(height: 8),
                    _buildSummaryRow('KDV (%18)', cartService.cart.tax),
                    const Divider(height: 20),
                    _buildSummaryRow('Toplam', cartService.cart.total, isTotal: true),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () => _proceedToCheckout(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.payment_rounded,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Siparişi Tamamla',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        Text(
          '${amount.toStringAsFixed(2)} ₺',
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: FontWeight.bold,
            color: isTotal ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Future<void> _increaseQuantity(CartService cartService, CartItem item) async {
    try {
      dev.log('Increasing quantity for item: ${item.coffeeName}', 
               name: 'CartScreen', level: 800);
      await cartService.increaseQuantity(item.id);
    } catch (e) {
      dev.log('Error increasing quantity', name: 'CartScreen', error: e, level: 1000);
      _showErrorSnackBar('Miktar artırılamadı');
    }
  }

  Future<void> _decreaseQuantity(CartService cartService, CartItem item) async {
    try {
      dev.log('Decreasing quantity for item: ${item.coffeeName}', 
               name: 'CartScreen', level: 800);
      await cartService.decreaseQuantity(item.id);
    } catch (e) {
      dev.log('Error decreasing quantity', name: 'CartScreen', error: e, level: 1000);
      _showErrorSnackBar('Miktar azaltılamadı');
    }
  }

  Future<void> _removeItem(CartService cartService, CartItem item) async {
    try {
      dev.log('Removing item from cart: ${item.coffeeName}', 
               name: 'CartScreen', level: 800);
      await cartService.removeFromCart(item.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.coffeeName} sepetten çıkarıldı'),
            backgroundColor: Theme.of(context).colorScheme.secondary,
            action: SnackBarAction(
              label: 'Geri Al',
              onPressed: () async {
                // TODO: Implement undo functionality
                dev.log('Undo remove item pressed', name: 'CartScreen', level: 800);
              },
            ),
          ),
        );
      }
    } catch (e) {
      dev.log('Error removing item', name: 'CartScreen', error: e, level: 1000);
      _showErrorSnackBar('Ürün çıkarılamadı');
    }
  }

  Future<bool> _showRemoveItemDialog(BuildContext context, CartItem item) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ürünü Çıkar'),
          content: Text('${item.coffeeName} sepetten çıkarılsın mı?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
                dev.log('User confirmed item removal: ${item.coffeeName}', 
                         name: 'CartScreen', level: 800);
              },
              style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
              child: const Text('Çıkar'),
            ),
          ],
        );
      },
    );
    
    return result ?? false;
  }

  Future<void> _showClearCartDialog(BuildContext context, CartService cartService) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sepeti Temizle'),
          content: const Text('Sepetteki tüm ürünler çıkarılacak. Emin misiniz?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
              child: const Text('Temizle'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        dev.log('Clearing entire cart', name: 'CartScreen', level: 800);
        await cartService.clearCart();
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Sepet temizlendi'),
              backgroundColor: Theme.of(context).colorScheme.secondary,
            ),
          );
        }
      } catch (e) {
        dev.log('Error clearing cart', name: 'CartScreen', error: e, level: 1000);
        _showErrorSnackBar('Sepet temizlenemedi');
      }
    }
  }

  void _proceedToCheckout() {
    dev.log('Proceed to checkout pressed', name: 'CartScreen', level: 800);
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CheckoutScreen(),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}
