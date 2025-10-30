
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/cafe_model.dart';
import '../../../services/location_service.dart';
import '../../home/services/favorites_service.dart';

class CafeDetailScreen extends StatelessWidget {
  final Cafe cafe;

  const CafeDetailScreen({
    super.key,
    required this.cafe,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverList(
            delegate: SliverChildListDelegate([
              _buildHeader(context),
              _buildDescription(context),
              _buildAmenities(context),
              _buildOperatingHours(context),
              _buildContactInfo(context),
              _buildLocationInfo(context),
              const SizedBox(height: 100), // Space for floating action button
            ]),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openDirections(),
        backgroundColor: Theme.of(context).colorScheme.primary,
        icon: Icon(Icons.directions, color: Theme.of(context).colorScheme.onPrimary),
        label: Text(
          'Yol Tarifi',
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      backgroundColor: Theme.of(context).colorScheme.primary,
      iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
      actions: [
        Consumer<FavoritesService>(
          builder: (context, favoritesService, _) {
            return StreamBuilder<bool>(
              stream: favoritesService.isFavorite(cafe.id),
              builder: (context, snapshot) {
                final isFavorite = snapshot.data ?? false;
                return IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.onPrimary,
                  ),
                  onPressed: () async {
                    try {
                      if (isFavorite) {
                        await favoritesService.removeFromFavorites(cafe.id);
                      } else {
                        await favoritesService.addToFavorites(cafe.id, type: 'cafe');
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Hata: ${e.toString()}'),
                          backgroundColor: Theme.of(context).colorScheme.error,
                        ),
                      );
                    }
                  },
                );
              },
            );
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          cafe.name,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              cafe.photoUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  child: Icon(
                    Icons.store,
                    size: 80,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                    Theme.of(context).colorScheme.background.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  cafe.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: cafe.isOpen ? Colors.green[100] : Colors.red[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  cafe.isOpen ? 'Açık' : 'Kapalı',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: cafe.isOpen ? Colors.green[700] : Colors.red[700],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), size: 16),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  cafe.address,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          if (cafe.rating > 0) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                ...List.generate(5, (index) {
                  return Icon(
                    index < cafe.rating.floor()
                        ? Icons.star
                        : index < cafe.rating
                            ? Icons.star_half
                            : Icons.star_border,
                    color: Colors.amber[700],
                    size: 20,
                  );
                }),
                const SizedBox(width: 8),
                Text(
                  '${cafe.rating.toStringAsFixed(1)} (${cafe.reviewCount} değerlendirme)',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
          if (cafe.isPartner) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 1,
                ),
              ),
              child: Text(
                '🤝 Partner Kafe',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDescription(BuildContext context) {
    if (cafe.description.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hakkında',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            cafe.description,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildAmenities(BuildContext context) {
    if (cafe.amenities.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Özellikler',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: cafe.amenities.map((amenity) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getAmenityIcon(amenity),
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      amenity,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildOperatingHours(BuildContext context) {
    if (cafe.operatingHours.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Çalışma Saatleri',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  'Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'
                ].asMap().entries.map((entry) {
                  final dayIndex = entry.key;
                  final dayName = entry.value;
                  final dayKey = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'][dayIndex];
                  final dayHours = cafe.operatingHours[dayKey];
                  
                  final isToday = DateTime.now().weekday - 1 == dayIndex;
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          dayName,
                          style: TextStyle(
                            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                            color: isToday ? Theme.of(context).colorScheme.primary : null,
                          ),
                        ),
                        Text(
                          dayHours != null && dayHours['closed'] != true
                              ? '${dayHours['open']} - ${dayHours['close']}'
                              : 'Kapalı',
                          style: TextStyle(
                            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                            color: isToday ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildContactInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'İletişim',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                if (cafe.phoneNumber.isNotEmpty)
                  ListTile(
                    leading: Icon(Icons.phone, color: Theme.of(context).colorScheme.primary),
                    title: Text(cafe.phoneNumber),
                    onTap: () => _launchPhone(cafe.phoneNumber),
                  ),
                if (cafe.website.isNotEmpty)
                  ListTile(
                    leading: Icon(Icons.web, color: Theme.of(context).colorScheme.primary),
                    title: Text(cafe.website),
                    onTap: () => _launchWebsite(cafe.website),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildLocationInfo(BuildContext context) {
    return Consumer<LocationService>(
      builder: (context, locationService, child) {
        final userPosition = locationService.currentPosition;
        double? distance;
        
        if (userPosition != null) {
          distance = locationService.calculateDistance(
            userPosition.latitude,
            userPosition.longitude,
            cafe.latitude,
            cafe.longitude,
          );
        }
        
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Konum',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  leading: Icon(Icons.location_on, color: Theme.of(context).colorScheme.primary),
                  title: Text(cafe.address),
                  subtitle: distance != null
                      ? Text('Uzaklık: ${locationService.formatDistance(distance)}')
                      : null,
                  onTap: () => _openDirections(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getAmenityIcon(String amenity) {
    switch (amenity.toLowerCase()) {
      case 'wifi':
        return Icons.wifi;
      case 'parking':
        return Icons.local_parking;
      case 'terrace':
      case 'outdoor':
        return Icons.deck;
      case 'takeaway':
        return Icons.takeout_dining;
      case 'card payment':
        return Icons.credit_card;
      default:
        return Icons.check_circle;
    }
  }

  void _launchPhone(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _launchWebsite(String website) async {
    Uri uri;
    if (!website.startsWith('http://') && !website.startsWith('https://')) {
      uri = Uri.parse('https://$website');
    } else {
      uri = Uri.parse(website);
    }
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _openDirections() async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${cafe.latitude},${cafe.longitude}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
