import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../../services/location_service.dart';

class AddAddressMapScreen extends StatefulWidget {
  final String? docId;
  final String? initialLabel;
  final String? initialType;
  final String? initialFullAddress;
  final GeoPoint? initialGeoPoint;

  const AddAddressMapScreen({super.key, this.docId, this.initialLabel, this.initialType, this.initialFullAddress, this.initialGeoPoint});

  @override
  State<AddAddressMapScreen> createState() => _AddAddressMapScreenState();
}

class _AddAddressMapScreenState extends State<AddAddressMapScreen> {
  final _mapControllerCompleter = Completer<GoogleMapController>();
  GoogleMapController? _mapController;
  LatLng _center = const LatLng(41.0082, 28.9784); // Istanbul default
  LatLng _selected = const LatLng(41.0082, 28.9784);
  bool _cameraMoving = false;
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();
  String _selectedAddressLine = '';
  bool _isReverseGeocoding = false;

  @override
  void initState() {
    super.initState();
    // If editing with initial location, center to it first
    if (widget.initialGeoPoint != null) {
      final latLng = LatLng(widget.initialGeoPoint!.latitude, widget.initialGeoPoint!.longitude);
      _center = latLng;
      _selected = latLng;
      _selectedAddressLine = widget.initialFullAddress ?? '';
    }
    // After first frame, try LocationService for precise current position
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final loc = Provider.of<LocationService>(context, listen: false);
      await loc.initialize();
      final pos = loc.currentPosition;
      if (pos != null && widget.initialGeoPoint == null) {
        setState(() {
          _center = LatLng(pos.latitude, pos.longitude);
          _selected = _center;
        });
        _mapController?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: _center, zoom: 16)));
        _reverseGeocode(_selected);
      } else if (widget.initialGeoPoint == null) {
        // fallback 
        _initLocation();
      }
    });
  }

  Future<void> _initLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        return;
      }
      final pos = await Geolocator.getCurrentPosition();
      setState(() {
        _center = LatLng(pos.latitude, pos.longitude);
        _selected = _center;
      });
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: _center, zoom: 16),
          ),
        );
      }
      _reverseGeocode(_selected);
    } catch (_) {
      // keep defaults quietly
    }
  }

  Future<void> _reverseGeocode(LatLng at) async {
    if (_isReverseGeocoding) return;
    setState(() => _isReverseGeocoding = true);
    try {
      final placemarks = await geo.placemarkFromCoordinates(at.latitude, at.longitude);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final line = [
          if ((p.street ?? '').isNotEmpty) p.street,
          if ((p.subLocality ?? '').isNotEmpty) p.subLocality,
          if ((p.locality ?? '').isNotEmpty) p.locality,
          if ((p.administrativeArea ?? '').isNotEmpty) p.administrativeArea,
        ].whereType<String>().join(', ');
        setState(() {
          _selectedAddressLine = line;
        });
      }
    } catch (_) {
      // ignore; leave address empty
    } finally {
      if (mounted) setState(() => _isReverseGeocoding = false);
    }
  }

  Future<void> _search() async {
    final q = _searchCtrl.text.trim();
    if (q.isEmpty) return;
    try {
      final results = await geo.locationFromAddress(q);
      if (results.isNotEmpty) {
        final loc = results.first;
        final target = LatLng(loc.latitude, loc.longitude);
        setState(() {
          _selected = target;
        });
        _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: target, zoom: 16),
          ),
        );
        _reverseGeocode(target);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Adres bulunamadı')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Adres'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _center, zoom: 14),
            onMapCreated: (c) {
              if (!_mapControllerCompleter.isCompleted) {
                _mapControllerCompleter.complete(c);
              }
              _mapController = c;
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            onCameraMove: (pos) {
              _cameraMoving = true;
              _selected = pos.target;
            },
            onCameraIdle: () {
              if (_cameraMoving) {
                _cameraMoving = false;
                _reverseGeocode(_selected);
              }
            },
          ),
          // Center pin
          const IgnorePointer(
            child: Center(
              child: Icon(Icons.location_pin, size: 48, color: Colors.red),
            ),
          ),
          // Search bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Material(
                color: Theme.of(context).colorScheme.surface,
                elevation: 2,
                borderRadius: BorderRadius.circular(12),
                child: Row(
                  children: [
                    const SizedBox(width: 8),
                    const Icon(Icons.search),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Adres ara... (örn. Aydınevler Amiral Orbay)'
                        ),
                        textInputAction: TextInputAction.search,
                        onSubmitted: (_) => _search(),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: _search,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Continue button
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: ElevatedButton(
              onPressed: () => _openAddressDetailsSheet(context),
              child: const Text('Devam'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openAddressDetailsSheet(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Giriş yapmalısınız')),
      );
      return;
    }

    final formKey = GlobalKey<FormState>();
    final addressCtrl = TextEditingController(text: _selectedAddressLine.isNotEmpty ? _selectedAddressLine : (widget.initialFullAddress ?? ''));
    final binaCtrl = TextEditingController();
    final katCtrl = TextEditingController();
    final daireCtrl = TextEditingController();
    final tarifCtrl = TextEditingController();
    final baslikCtrl = TextEditingController(text: widget.initialLabel ?? 'Ev');
    String type = widget.initialType ?? 'Ev';

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Adres Detayları', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: addressCtrl,
                      decoration: const InputDecoration(labelText: 'Adres (düzenlenebilir)'),
                      maxLines: 2,
                      validator: (v) => (v == null || v.isEmpty) ? 'Adres gerekli' : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: binaCtrl,
                            decoration: const InputDecoration(labelText: 'Bina No'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: katCtrl,
                            decoration: const InputDecoration(labelText: 'Kat'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: daireCtrl,
                            decoration: const InputDecoration(labelText: 'Daire'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: tarifCtrl,
                      decoration: const InputDecoration(labelText: 'Adres Tarifi'),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    Text('Etiket', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8))),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('Ev'),
                          selected: type == 'Ev',
                          onSelected: (_) => setState(() { type = 'Ev'; }),
                        ),
                        ChoiceChip(
                          label: const Text('İş'),
                          selected: type == 'İş',
                          onSelected: (_) => setState(() { type = 'İş'; }),
                        ),
                        ChoiceChip(
                          label: const Text('Diğer'),
                          selected: type == 'Diğer',
                          onSelected: (_) => setState(() { type = 'Diğer'; }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: baslikCtrl,
                      decoration: const InputDecoration(labelText: 'Başlık (ör. Ev, Ofis, A Blok vb.)'),
                      validator: (v) => (v == null || v.isEmpty) ? 'Başlık gerekli' : null,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (formKey.currentState?.validate() != true) return;
                          final data = {
                            'label': baslikCtrl.text.trim(),
                            'type': type,
                            'fullAddress': addressCtrl.text.trim(),
                            'buildingNo': binaCtrl.text.trim(),
                            'floor': katCtrl.text.trim(),
                            'apartmentNo': daireCtrl.text.trim(),
                            'notes': tarifCtrl.text.trim(),
                            'location': GeoPoint(_selected.latitude, _selected.longitude),
                            'createdAt': FieldValue.serverTimestamp(),
                          };
                          final ref = FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid)
                              .collection('addresses');
                          if (widget.docId == null) {
                            await ref.add(data);
                          } else {
                            await ref.doc(widget.docId).update(data);
                          }
                          if (mounted) {
                            Navigator.pop(ctx); // close sheet
                            Navigator.pop(context); // back to addresses list
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Adres eklendi')),
                            );
                          }
                        },
                        child: const Text('Kaydet'),
                      ),
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
}
