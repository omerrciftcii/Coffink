import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../home/models/coffee_model.dart';
import '../../cart/models/cart_item.dart';
import '../../cart/services/cart_service.dart';
import '../../home/services/favorites_service.dart';
import '../../review/models/review_model.dart';
import '../../review/services/review_service.dart';
import '../../review/screens/reviews_list_screen.dart';
import '../../review/screens/write_review_screen.dart';

class CoffeeDetailScreen extends StatefulWidget {
  final Coffee coffee;

  const CoffeeDetailScreen({
    super.key,
    required this.coffee,
  });

  @override
  State<CoffeeDetailScreen> createState() => _CoffeeDetailScreenState();
}

class _CoffeeDetailScreenState extends State<CoffeeDetailScreen> with SingleTickerProviderStateMixin {
  String _selectedSize = 'medium';
  int _quantity = 1;
  CartCustomizations _customizations = CartCustomizations();
  bool _isAddingToCart = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    dev.log('CoffeeDetailScreen initialized for: ${widget.coffee.name}', 
             name: 'CoffeeDetailScreen', level: 800);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentPrice = widget.coffee.getPriceForSize(_selectedSize);
    final totalPrice = (currentPrice + (_customizations.extraShots * 5.0)) * _quantity;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCoffeeInfo(),
                  const SizedBox(height: 24),
                  _buildSizeSelection(),
                  const SizedBox(height: 24),
                  _buildCustomizations(),
                  const SizedBox(height: 24),
                  _buildQuantitySelector(),
                  const SizedBox(height: 24),
                  if (widget.coffee.ingredients.isNotEmpty) ...[
                    _buildIngredientsSection(),
                    const SizedBox(height: 24),
                  ],
                  if (widget.coffee.nutritionalInfo != null) ...[
                    _buildNutritionalInfo(),
                    const SizedBox(height: 24),
                  ],
                  _buildReviewsSection(),
                  SizedBox(height: 100), // Space for floating button
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildAddToCartButton(totalPrice),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: Color.alphaBlend(
        Theme.of(context).colorScheme.primary.withOpacity(0.7),
        Theme.of(context).colorScheme.surface,
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Hero(
          tag: 'coffee_${widget.coffee.id}',
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                widget.coffee.photoUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  dev.log('Error loading coffee image: ${widget.coffee.photoUrl}', 
                           name: 'CoffeeDetailScreen', error: error, level: 900);
                  return Container(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    child: Icon(Icons.coffee, size: 80, color: Theme.of(context).colorScheme.primary),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                            : null,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  );
                },
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withAlpha(180),
                    ],
                  ),
                ),
              ),
              if (!widget.coffee.isAvailable)
                Container(
                  color: Colors.black.withAlpha(128),
                  child: const Center(
                    child: Text(
                      'Şu anda mevcut değil',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        Consumer<FavoritesService>(
          builder: (context, favoritesService, _) {
            return StreamBuilder<bool>(
              stream: favoritesService.isFavorite(widget.coffee.id),
              builder: (context, snapshot) {
                final isFavorite = snapshot.data ?? false;
                return IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.onPrimary,
                  ),
                  onPressed: () {
                    dev.log('Favorite toggled for: ${widget.coffee.name}', 
                             name: 'CoffeeDetailScreen', level: 800);
                    if (isFavorite) {
                      favoritesService.removeFromFavorites(widget.coffee.id);
                    } else {
                      favoritesService.addToFavorites(widget.coffee.id);
                    }
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildCoffeeInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                widget.coffee.name,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                widget.coffee.category,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.access_time, size: 16, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
            const SizedBox(width: 4),
            Text(
              '${widget.coffee.preparationTime} dk',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
            ),
            const SizedBox(width: 16),
            Icon(Icons.star, size: 16, color: Colors.amber[600]),
            const SizedBox(width: 4),
            Text(
              '4.5', // TODO: Implement ratings
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          widget.coffee.detailedDescription,
          style: const TextStyle(fontSize: 16, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildSizeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Boy Seçin',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: widget.coffee.availableSizes.map((size) {
            final sizeInfo = widget.coffee.getSizeInfo(size)!;
            final isSelected = _selectedSize == size;
            
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedSize = size;
                  });
                  dev.log('Size selected: $size (${sizeInfo.name})', 
                           name: 'CoffeeDetailScreen', level: 800);
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        sizeInfo.name,
                        style: TextStyle(
                          color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${sizeInfo.ml}ml',
                        style: TextStyle(
                          color: isSelected ? Theme.of(context).colorScheme.onPrimary.withOpacity(0.8) : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${sizeInfo.price.toStringAsFixed(0)} ₺',
                        style: TextStyle(
                          color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCustomizations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Özelleştirme',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        
        // Milk Type
        _buildCustomizationSection(
          'Süt Türü',
          [
            'Tam Yağlı Süt',
            'Yulaf Sütü',
            'Badem Sütü',
            'Soya Sütü',
            'Sütsiz',
          ],
          _customizations.milkType,
          (value) {
            setState(() {
              _customizations = _customizations.copyWith(milkType: value);
            });
            dev.log('Milk type changed to: $value', 
                     name: 'CoffeeDetailScreen', level: 800);
          },
        ),
        
        const SizedBox(height: 16),
        
        // Temperature
        _buildCustomizationSection(
          'Sıcaklık',
          ['Sıcak', 'Iced'],
          _customizations.temperature,
          (value) {
            setState(() {
              _customizations = _customizations.copyWith(temperature: value);
            });
            dev.log('Temperature changed to: $value', 
                     name: 'CoffeeDetailScreen', level: 800);
          },
        ),
        
        const SizedBox(height: 16),
        
        // Sweetness
        _buildSweetnessSelector(),
        
        const SizedBox(height: 16),
        
        // Extra Shots
        _buildExtraShotsSelector(),
      ],
    );
  }

  Widget _buildCustomizationSection(String title, List<String> options, String selectedValue, Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selectedValue == option;
            return GestureDetector(
              onTap: () => onChanged(option),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                  ),
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSweetnessSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tatlılık Seviyesi',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Text('Şekersiz'),
            Expanded(
              child: Slider(
                value: _customizations.sweetness.toDouble(),
                min: 1,
                max: 5,
                divisions: 4,
                activeColor: Theme.of(context).colorScheme.primary,
                onChanged: (value) {
                  setState(() {
                    _customizations = _customizations.copyWith(sweetness: value.round());
                  });
                  dev.log('Sweetness changed to: ${value.round()}', 
                           name: 'CoffeeDetailScreen', level: 800);
                },
              ),
            ),
            const Text('Çok Tatlı'),
          ],
        ),
        Center(
          child: Text(
            _customizations.getSweetnessLabel(),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExtraShotsSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Extra Shot (+5₺)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        Row(
          children: [
            IconButton(
              onPressed: _customizations.extraShots > 0
                  ? () {
                      setState(() {
                        _customizations = _customizations.copyWith(
                          extraShots: _customizations.extraShots - 1,
                        );
                      });
                      dev.log('Extra shots decreased to: ${_customizations.extraShots}', 
                               name: 'CoffeeDetailScreen', level: 800);
                    }
                  : null,
              icon: const Icon(Icons.remove),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2)!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _customizations.extraShots.toString(),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            IconButton(
              onPressed: _customizations.extraShots < 3
                  ? () {
                      setState(() {
                        _customizations = _customizations.copyWith(
                          extraShots: _customizations.extraShots + 1,
                        );
                      });
                      dev.log('Extra shots increased to: ${_customizations.extraShots}', 
                               name: 'CoffeeDetailScreen', level: 800);
                    }
                  : null,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuantitySelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Adet',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            IconButton(
              onPressed: _quantity > 1
                  ? () {
                      setState(() {
                        _quantity--;
                      });
                      dev.log('Quantity decreased to: $_quantity', 
                               name: 'CoffeeDetailScreen', level: 800);
                    }
                  : null,
              icon: const Icon(Icons.remove_circle_outline),
              iconSize: 32,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _quantity.toString(),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              onPressed: _quantity < 10
                  ? () {
                      setState(() {
                        _quantity++;
                      });
                      dev.log('Quantity increased to: $_quantity', 
                               name: 'CoffeeDetailScreen', level: 800);
                    }
                  : null,
              icon: const Icon(Icons.add_circle_outline),
              iconSize: 32,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIngredientsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'İçindekiler',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.coffee.ingredients.map((ingredient) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.2)!),
            ),
            child: Text(
              ingredient,
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildNutritionalInfo() {
    final nutritionalInfo = widget.coffee.nutritionalInfo!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Besin Değerleri',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2)!),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNutritionalItem('Kalori', nutritionalInfo.calories.toString(), 'kcal'),
              _buildNutritionalItem('Kafein', nutritionalInfo.caffeine.toString(), 'mg'),
              _buildNutritionalItem('Protein', nutritionalInfo.protein.toStringAsFixed(1), 'g'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNutritionalItem(String label, String value, String unit) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          unit,
          style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildAddToCartButton(double totalPrice) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: MediaQuery.of(context).size.width - 32,
            height: 60,
            child: ElevatedButton(
              onPressed: widget.coffee.isAvailable && !_isAddingToCart ? _addToCart : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 8,
              ),
              child: _isAddingToCart
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Sepete Ekle',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${totalPrice.toStringAsFixed(0)} ₺',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _addToCart() async {
    if (!widget.coffee.isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bu kahve şu anda mevcut değil')),
      );
      return;
    }

    setState(() {
      _isAddingToCart = true;
    });

    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    try {
      final cartService = Provider.of<CartService>(context, listen: false);
      
      dev.log('Adding to cart: ${widget.coffee.name}, Size: $_selectedSize, Quantity: $_quantity', 
               name: 'CoffeeDetailScreen', level: 800);
      
      await cartService.addToCart(
        widget.coffee,
        _selectedSize,
        _customizations,
        quantity: _quantity,
      );

      if (mounted) {
        dev.log('Successfully added to cart', name: 'CoffeeDetailScreen', level: 800);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.coffee.name} sepete eklendi!'),
            backgroundColor: Theme.of(context).colorScheme.secondary,
            action: SnackBarAction(
              label: 'Sepete Git',
              textColor: Colors.white,
              onPressed: () {
                // TODO: Navigate to cart screen
                dev.log('Navigate to cart pressed', name: 'CoffeeDetailScreen', level: 800);
              },
            ),
          ),
        );
      }
    } catch (e) {
      dev.log('Error adding to cart', name: 'CoffeeDetailScreen', error: e, level: 1000);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sepete eklerken hata oluştu: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAddingToCart = false;
        });
      }
    }
  }

  Widget _buildReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Değerlendirmeler',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReviewsListScreen(
                      targetId: widget.coffee.id,
                      targetType: 'coffee',
                      targetName: widget.coffee.name,
                    ),
                  ),
                );
              },
              child: const Text('Tümünü Gör'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        StreamBuilder<ReviewSummary>(
          stream: context.read<ReviewService>().getReviewSummary(widget.coffee.id, 'coffee'),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Container(
                padding: const EdgeInsets.all(16),
                child: Text('Error loading reviews: ${snapshot.error}'),
              );
            }

            final summary = snapshot.data ?? ReviewSummary(
              averageRating: 0.0,
              totalReviews: 0,
              ratingDistribution: {5: 0, 4: 0, 3: 0, 2: 0, 1: 0},
            );

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Column(
                          children: [
                            Text(
                              summary.averageRating.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            RatingBarIndicator(
                              rating: summary.averageRating,
                              itemBuilder: (context, index) => Icon(
                                Icons.star,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              itemCount: 5,
                              itemSize: 20.0,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${summary.totalReviews} değerlendirme',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            children: List.generate(5, (index) {
                              final stars = 5 - index;
                              final percentage = summary.getRatingPercentage(stars);
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2),
                                child: Row(
                                  children: [
                                    Text('$stars'),
                                    const SizedBox(width: 4),
                                    Icon(Icons.star, size: 12, color: Theme.of(context).colorScheme.secondary),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: LinearProgressIndicator(
                                        value: percentage,
                                        backgroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          Theme.of(context).colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${(percentage * 100).round()}%',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                    if (summary.totalReviews > 0) ...[
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      _buildRecentReviews(),
                    ] else ...[
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      _buildNoReviews(),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecentReviews() {
    return StreamBuilder<List<Review>>(
      stream: context.read<ReviewService>().getReviewsForTarget(widget.coffee.id, 'coffee'),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error loading reviews: ${snapshot.error}');
        }

        final reviews = snapshot.data ?? [];
        final recentReviews = reviews.take(2).toList();

        if (recentReviews.isEmpty) {
          return _buildNoReviews();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Son Yorumlar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () => _writeReview(),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Yorum Yaz'),
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            ...recentReviews.map((review) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        backgroundImage: review.userAvatar.isNotEmpty 
                            ? NetworkImage(review.userAvatar) 
                            : null,
                        child: review.userAvatar.isEmpty 
                            ? Text(
                                review.userName.isNotEmpty ? review.userName[0].toUpperCase() : 'A',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              review.userName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _formatDate(review.createdAt),
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      RatingBarIndicator(
                        rating: review.rating,
                        itemBuilder: (context, index) => Icon(
                          Icons.star,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        itemCount: 5,
                        itemSize: 16.0,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    review.comment,
                    style: const TextStyle(fontSize: 14),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            )),
          ],
        );
      },
    );
  }

  Widget _buildNoReviews() {
    return Column(
      children: [
        const Text(
          'Henüz değerlendirme yok',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'İlk değerlendirmeyi siz yapın!',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () => _writeReview(),
          icon: const Icon(Icons.edit, size: 18),
          label: const Text('Yorum Yaz'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} gün önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce';
    } else {
      return 'Az önce';
    }
  }

  Future<void> _writeReview() async {
    try {
      // Check if user already has a review for this coffee
      final reviewService = context.read<ReviewService>();
      final existingReview = await reviewService.getUserReviewForTarget(
        widget.coffee.id, 
        'coffee'
      );
      
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WriteReviewScreen(
              targetId: widget.coffee.id,
              targetType: 'coffee',
              targetName: widget.coffee.name,
              existingReview: existingReview,
            ),
          ),
        );
      }
    } catch (e) {
      dev.log('Error checking existing review', name: 'CoffeeDetailScreen', error: e, level: 1000);
      // Continue to write review screen anyway
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WriteReviewScreen(
              targetId: widget.coffee.id,
              targetType: 'coffee',
              targetName: widget.coffee.name,
            ),
          ),
        );
      }
    }
  }
}