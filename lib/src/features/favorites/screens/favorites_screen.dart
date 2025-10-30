import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../home/models/coffee_model.dart';
import '../../cafe/models/cafe_model.dart';
import '../../home/services/favorites_service.dart';
import '../../coffee/screens/coffee_detail_screen.dart';
import '../../cafe/screens/cafe_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedSort = 'newest'; // newest, oldest, name
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    dev.log('FavoritesScreen initialized', name: 'FavoritesScreen', level: 800);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorilerim'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).colorScheme.onPrimary,
          labelColor: Theme.of(context).colorScheme.onPrimary,
          unselectedLabelColor: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
          tabs: const [
            Tab(
              icon: Icon(Icons.coffee),
              text: 'Kahveler',
            ),
            Tab(
              icon: Icon(Icons.store),
              text: 'Kafeler',
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() {
                _selectedSort = value;
              });
              dev.log('Sort changed to: $value', name: 'FavoritesScreen', level: 800);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'newest',
                child: Row(
                  children: [
                    Icon(Icons.access_time, size: 18),
                    SizedBox(width: 8),
                    Text('En Yeni'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'oldest',
                child: Row(
                  children: [
                    Icon(Icons.history, size: 18),
                    SizedBox(width: 8),
                    Text('En Eski'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'name',
                child: Row(
                  children: [
                    Icon(Icons.sort_by_alpha, size: 18),
                    SizedBox(width: 8),
                    Text('İsim'),
                  ],
                ),
              ),
            ],
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'clear_all') {
                _showClearAllDialog();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'clear_all',
                child: Row(
                  children: [
                    Icon(Icons.clear_all, size: 18, color: Theme.of(context).colorScheme.error),
                    const SizedBox(width: 8),
                    Text('Tümünü Temizle', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCoffeesTab(),
          _buildCafesTab(),
        ],
      ),
    );
  }

  Widget _buildCoffeesTab() {
    return StreamBuilder<List<Coffee>>(
      stream: context.read<FavoritesService>().getFavoriteCoffees(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorWidget('Kahveler yüklenirken hata oluştu');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final coffees = snapshot.data ?? [];
        
        if (coffees.isEmpty) {
          return _buildEmptyFavorites(
            icon: Icons.coffee_outlined,
            title: 'Favori kahveniz yok',
            message: 'Beğendiğiniz kahveleri favorilere ekleyerek\nkolayca bulabilirsiniz',
          );
        }

        final sortedCoffees = _sortCoffees(coffees);

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: sortedCoffees.length,
          itemBuilder: (context, index) {
            return _buildCoffeeCard(sortedCoffees[index]);
          },
        );
      },
    );
  }

  Widget _buildCafesTab() {
    return StreamBuilder<List<Cafe>>(
      stream: context.read<FavoritesService>().getFavoriteCafes(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorWidget('Kafeler yüklenirken hata oluştu');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final cafes = snapshot.data ?? [];
        
        if (cafes.isEmpty) {
          return _buildEmptyFavorites(
            icon: Icons.store_outlined,
            title: 'Favori kafeniz yok',
            message: 'Beğendiğiniz kafeleri favorilere ekleyerek\nkolayca bulabilirsiniz',
          );
        }

        final sortedCafes = _sortCafes(cafes);

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sortedCafes.length,
          itemBuilder: (context, index) {
            return _buildCafeCard(sortedCafes[index]);
          },
        );
      },
    );
  }

  Widget _buildCoffeeCard(Coffee coffee) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CoffeeDetailScreen(coffee: coffee),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Coffee Image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: coffee.photoUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Theme.of(context).colorScheme.surfaceVariant,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Theme.of(context).colorScheme.secondaryContainer,
                          child: Icon(
                            Icons.coffee,
                            size: 40,
                            color: Theme.of(context).colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Consumer<FavoritesService>(
                          builder: (context, favoritesService, _) {
                            return StreamBuilder<bool>(
                              stream: favoritesService.isFavorite(coffee.id),
                              builder: (context, snapshot) {
                                final isFavorite = snapshot.data ?? false;
                                return GestureDetector(
                                  onTap: () async {
                                    try {
                                      if (isFavorite) {
                                        await favoritesService.removeFromFavorites(coffee.id);
                                      } else {
                                        await favoritesService.addToFavorites(coffee.id, type: 'coffee');
                                      }
                                    } catch (e) {
                                      dev.log('Error toggling favorite', 
                                               name: 'FavoritesScreen', error: e, level: 1000);
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isFavorite ? Icons.favorite : Icons.favorite_border,
                                      color: Theme.of(context).colorScheme.error,
                                      size: 20,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Coffee Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      coffee.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      coffee.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${coffee.basePrice.toStringAsFixed(0)} ₺',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            coffee.category,
                            style: TextStyle(
                              fontSize: 10,
                              color: Theme.of(context).colorScheme.onSecondaryContainer,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildCafeCard(Cafe cafe) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CafeDetailScreen(cafe: cafe),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Cafe Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: cafe.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 80,
                    height: 80,
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 80,
                    height: 80,
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    child: Icon(
                      Icons.store,
                      size: 40,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Cafe Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cafe.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      cafe.address,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.star, size: 16, color: Theme.of(context).colorScheme.secondary), // Changed from Colors.amber[600]
                        const SizedBox(width: 4),
                        Text(
                          cafe.rating.toStringAsFixed(1),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.access_time, size: 16, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                        const SizedBox(width: 4),
                        Text(
                          '${cafe.distanceFromUser?.toStringAsFixed(1) ?? '0.0'} km',
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Favorite Button
              Consumer<FavoritesService>(
                builder: (context, favoritesService, _) {
                  return StreamBuilder<bool>(
                    stream: favoritesService.isFavorite(cafe.id),
                    builder: (context, snapshot) {
                      final isFavorite = snapshot.data ?? false;
                      return IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        onPressed: () async {
                          try {
                            if (isFavorite) {
                              await favoritesService.removeFromFavorites(cafe.id);
                            } else {
                              await favoritesService.addToFavorites(cafe.id, type: 'cafe');
                            }
                          } catch (e) {
                            dev.log('Error toggling favorite', 
                                     name: 'FavoritesScreen', error: e, level: 1000);
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyFavorites({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to the store interface (index 1 in bottom navigation)
              Navigator.of(context).pop();
              // Use a named route instead of trying to access HomeScreenState
              Navigator.pushNamed(context, '/home');
            },
            icon: const Icon(Icons.explore),
            label: const Text('Keşfet'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error.withOpacity(0.7),
          ),
          const SizedBox(height: 16),
          Text(
            'Hata',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {}); // Trigger rebuild
            },
            child: const Text('Tekrar Dene'),
          ),
        ],
      ),
    );
  }

  List<Coffee> _sortCoffees(List<Coffee> coffees) {
    final sorted = List<Coffee>.from(coffees);
    
    switch (_selectedSort) {
      case 'newest':
        // Sort by name for now since we don't have creation date
        // TODO: Add creation date or favorite date to sort properly
        break;
      case 'oldest':
        // Sort by name reversed for now
        sorted.sort((a, b) => b.name.compareTo(a.name));
        break;
      case 'name':
        sorted.sort((a, b) => a.name.compareTo(b.name));
        break;
    }
    
    return sorted;
  }

  List<Cafe> _sortCafes(List<Cafe> cafes) {
    final sorted = List<Cafe>.from(cafes);
    
    switch (_selectedSort) {
      case 'newest':
        // Sort by name for now since we don't have creation date
        break;
      case 'oldest':
        // Sort by name reversed for now
        sorted.sort((a, b) => b.name.compareTo(a.name));
        break;
      case 'name':
        sorted.sort((a, b) => a.name.compareTo(b.name));
        break;
    }
    
    return sorted;
  }

  Future<void> _showClearAllDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Tüm Favorileri Temizle'),
          content: const Text('Tüm favori kahve ve kafeleriniz silinecek. Emin misiniz?'),
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
        await context.read<FavoritesService>().clearAllFavorites();
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Tüm favoriler temizlendi'),
              backgroundColor: Theme.of(context).colorScheme.secondary,
            ),
          );
        }
      } catch (e) {
        dev.log('Error clearing favorites', name: 'FavoritesScreen', error: e, level: 1000);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Hata: ${e.toString()}'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }
}