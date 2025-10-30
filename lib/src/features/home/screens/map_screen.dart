
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'dart:async';

import '../../cafe/models/cafe_model.dart';
import '../../cafe/services/cafe_service.dart';
import '../../cafe/screens/cafe_detail_screen.dart';
import '../../../services/location_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  List<Cafe> _cafes = [];
  String _selectedFilter = 'Tümü';
  final List<String> _filterOptions = ['Tümü', 'Partner Kafeler', 'Açık Olanlar', 'Yakın Olanlar'];
  bool _markersNeedUpdate = false;
  bool _hasMapError = false;
  String? _mapErrorMessage;
  Completer<GoogleMapController> _controller = Completer();

  // Default location (Istanbul)
  static const LatLng _defaultLocation = LatLng(41.0082, 28.9784);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeLocation();
    });
  }

  void _initializeLocation() async {
    final locationService = Provider.of<LocationService>(context, listen: false);
    await locationService.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Custom header for Map
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors:
                  [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primaryContainer,
                Theme.of(context).colorScheme.secondaryContainer,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.map_rounded,
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Harita',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                        Text(
                          'Yakınınızdaki kafeleri keşfedin',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: PopupMenuButton<String>(
                      icon: Icon(Icons.filter_list_rounded, color: Theme.of(context).colorScheme.onPrimary),
                      onSelected: (String filter) {
                        setState(() {
                          _selectedFilter = filter;
                        });
                        _markersNeedUpdate = true;
                        _updateMarkers();
                      },
                      itemBuilder: (BuildContext context) {
                        return _filterOptions.map((String choice) {
                          return PopupMenuItem<String>(
                            value: choice,
                            child: Row(
                              children: [
                                Icon(
                                  _selectedFilter == choice ? Icons.check_rounded : null,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(choice),
                              ],
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              _buildMap(),
              _buildLocationPermissionOverlay(),
              _buildFilterIndicator(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMap() {
    if (_hasMapError) {
      return _buildMapErrorWidget();
    }

    return Consumer<LocationService>(
      builder: (context, locationService, child) {
        final userPosition = locationService.currentPosition;
        final initialPosition = userPosition != null
            ? LatLng(userPosition.latitude, userPosition.longitude)
            : _defaultLocation;

        return StreamProvider<List<Cafe>>.value(
          value: CafeService.fromContext(context).getCafes(),
          initialData: const [],
          child: Consumer<List<Cafe>>(
            builder: (context, cafes, child) {
              // Only update if cafes data has actually changed
              if (_cafes != cafes) {
                _cafes = cafes;
                _markersNeedUpdate = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_markersNeedUpdate) {
                    _updateMarkers();
                    _markersNeedUpdate = false;
                  }
                });
              }
              
              return _buildMapWidget(initialPosition, locationService);
            },
          ),
        );
      },
    );
  }

  Widget _buildMapWidget(LatLng initialPosition, LocationService locationService) {
    try {
      return GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: initialPosition,
          zoom: 12.0,
        ),
        markers: _markers,
        myLocationEnabled: locationService.hasLocationPermission,
        myLocationButtonEnabled: false,
        compassEnabled: true,
        mapToolbarEnabled: false,
        onTap: (_) {
          // Close any open info windows
        },
      );
    } catch (e, stackTrace) {
      // Report error to Crashlytics
      FirebaseCrashlytics.instance.recordError(
        'Map creation error: $e',
        stackTrace,
        fatal: false,
      );
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _hasMapError = true;
            _mapErrorMessage = e.toString();
          });
        }
      });
      
      return _buildMapErrorWidget();
    }
  }

  void _onMapCreated(GoogleMapController controller) async {
    try {
      if (!_controller.isCompleted) {
        _controller.complete(controller);
      }
      _mapController = controller;
    } catch (e, stackTrace) {
      // Report error to Crashlytics
      FirebaseCrashlytics.instance.recordError(
        'Map controller error: $e',
        stackTrace,
        fatal: false,
      );
      
      if (mounted) {
        setState(() {
          _hasMapError = true;
          _mapErrorMessage = 'Google Maps API key is missing or invalid';
        });
      }
    }
  }

  Widget _buildMapErrorWidget() {
    return Container(
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(32),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.map_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Harita Yüklenemedi',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _mapErrorMessage ?? 
                  'Google Maps API anahtarı eksik veya geçersiz.\n' 
                  'Harita özelliği kullanılabilmesi için\n' 
                  'Google Maps API anahtarı gereklidir.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _hasMapError = false;
                          _mapErrorMessage = null;
                          _controller = Completer<GoogleMapController>();
                        });
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tekrar Dene'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _showCafeList(),
                      icon: const Icon(Icons.list),
                      label: const Text('Kafe Listesi'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.primary,
                      ),
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

  Widget _buildLocationPermissionOverlay() {
    return Consumer<LocationService>(
      builder: (context, locationService, child) {
        if (locationService.hasLocationPermission) {
          return const SizedBox.shrink();
        }

        return Container(
          color: Theme.of(context).colorScheme.background.withOpacity(0.7),
          child: Center(
            child: Card(
              margin: const EdgeInsets.all(32),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_off,
                      size: 64,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Konum İzni Gerekli',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Yakınınızdaki kafeleri görmek ve yol tarifi almak için konum izni gereklidir.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        locationService.requestLocationPermission();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      ),
                      child: const Text('Konum İzni Ver'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterIndicator() {
    if (_selectedFilter == 'Tümü') return const SizedBox.shrink();
    
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(
                Icons.filter_list,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Filtre: $_selectedFilter',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedFilter = 'Tümü';
                  });
                  _markersNeedUpdate = true;
                  _updateMarkers();
                },
                child: Text(
                  'Temizle',
                  style: TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateMarkers() {
    final newMarkers = _calculateMarkers();
    if (mounted) {
      setState(() {
        _markers = newMarkers;
      });
    }
    _markersNeedUpdate = false;
  }

  Set<Marker> _calculateMarkers() {
    final locationService = Provider.of<LocationService>(context, listen: false);
    final userPosition = locationService.currentPosition;
    
    List<Cafe> filteredCafes = _cafes;

    // Apply filters
    switch (_selectedFilter) {
      case 'Partner Kafeler':
        filteredCafes = _cafes.where((cafe) => cafe.isPartner).toList();
        break;
      case 'Açık Olanlar':
        filteredCafes = _cafes.where((cafe) => cafe.isOpen).toList();
        break;
      case 'Yakın Olanlar':
        if (userPosition != null) {
          filteredCafes = _cafes.where((cafe) {
            final distance = locationService.calculateDistance(
              userPosition.latitude,
              userPosition.longitude,
              cafe.latitude,
              cafe.longitude,
            );
            return distance <= 5; // Within 5km
          }).toList();
        }
        break;
    }

    return filteredCafes.map((cafe) {
      return Marker(
        markerId: MarkerId(cafe.id),
        position: LatLng(cafe.latitude, cafe.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          cafe.isPartner 
              ? BitmapDescriptor.hueOrange 
              : BitmapDescriptor.hueRed,
        ),
        infoWindow: InfoWindow(
          title: cafe.name,
          snippet: cafe.isOpen ? 'Açık' : 'Kapalı',
          onTap: () {
            _showCafeBottomSheet(cafe);
          },
        ),
      );
    }).toSet();
  }

  void _showCafeList() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Kafe Listesi',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: StreamBuilder<List<Cafe>>(
                      stream: CafeService.fromContext(context).getCafes(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        
                        if (snapshot.hasError) {
                          return Center(
                            child: Text('Hata: ${snapshot.error}'),
                          );
                        }
                        
                        final cafes = snapshot.data ?? [];
                        
                        if (cafes.isEmpty) {
                          return const Center(
                            child: Text('Kafe bulunamadı'),
                          );
                        }
                        
                        return ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: cafes.length,
                          itemBuilder: (context, index) {
                            final cafe = cafes[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    cafe.photoUrl,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 50,
                                        height: 50,
                                        color: Theme.of(context).colorScheme.surfaceVariant,
                                        child: const Icon(Icons.store),
                                      );
                                    },
                                  ),
                                ),
                                title: Text(cafe.name),
                                subtitle: Text(
                                  cafe.address,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: Icon(
                                  Icons.chevron_right,
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CafeDetailScreen(cafe: cafe),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showCafeBottomSheet(Cafe cafe) {
    final locationService = Provider.of<LocationService>(context, listen: false);
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

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      cafe.photoUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 60,
                          height: 60,
                          color: Theme.of(context).colorScheme.surfaceVariant,
                          child: const Icon(Icons.store),
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
                          cafe.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: cafe.isOpen 
                                    ? Colors.green[100] 
                                    : Colors.red[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                cafe.isOpen ? 'Açık' : 'Kapalı',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: cafe.isOpen 
                                      ? Colors.green[700] 
                                      : Colors.red[700],
                                ),
                              ),
                            ),
                            if (cafe.isPartner) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Partner',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                cafe.address,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              if (distance != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Uzaklık: ${locationService.formatDistance(distance)}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
              if (cafe.rating > 0) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      size: 16,
                      color: Colors.amber[700],
                    ),
                    const SizedBox(width: 4),
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
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        // Open directions
                        // Implementation depends on your mapping solution
                      },
                      icon: const Icon(Icons.directions),
                      label: const Text('Yol Tarifi'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CafeDetailScreen(cafe: cafe),
                          ),
                        );
                      },
                      icon: Icon(Icons.info, color: Theme.of(context).colorScheme.onPrimary),
                      label: Text('Detaylar', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
