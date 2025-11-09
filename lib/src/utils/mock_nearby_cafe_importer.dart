import 'package:cloud_firestore/cloud_firestore.dart';
import '../features/cafe/models/cafe_model.dart';
import '../utils/logger.dart';

class MockNearbyCafeImporter {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Center coordinates provided by user
  static const double centerLat = 40.94424496609406;
  static const double centerLng = 29.12847411297966;

  Future<void> populateNearbyCafes() async {
    Logger.info('Populating 12 nearby cafes around ($centerLat, $centerLng)', name: 'MockNearbyCafeImporter');
    try {
      final cafes = _buildNearbyCafes();
      for (final cafe in cafes) {
        await _firestore.collection('cafes').doc(cafe.id).set(cafe.toFirestore());
        Logger.info('Upserted cafe: ${cafe.name} (${cafe.id})', name: 'MockNearbyCafeImporter');
      }
      Logger.info('Successfully populated ${cafes.length} nearby cafes', name: 'MockNearbyCafeImporter');
    } catch (e) {
      Logger.error('Failed to populate nearby cafes: $e', name: 'MockNearbyCafeImporter');
      rethrow;
    }
  }

  List<Cafe> _buildNearbyCafes() {
    final now = DateTime.now();

    // Small offsets ~0.002-0.02 degrees (~0.2–2 km depending on latitude)
    final offsets = <({double dLat, double dLng, String name, String photo})>[
      (dLat: 0.003, dLng: 0.002, name: 'Kıyı Kahvesi', photo: 'https://images.unsplash.com/photo-1504754524776-8f4f37790ca0?w=800&h=600&fit=crop'),
      (dLat: -0.004, dLng: 0.001, name: 'Yeşil Vadi Cafe', photo: 'https://images.unsplash.com/photo-1470337458703-46ad1756a187?w=800&h=600&fit=crop'),
      (dLat: 0.006, dLng: -0.003, name: 'Köşe Kahve', photo: 'https://images.unsplash.com/photo-1498804103079-a6351b050096?w=800&h=600&fit=crop'),
      (dLat: -0.007, dLng: -0.006, name: 'Sahil Roastery', photo: 'https://images.unsplash.com/photo-1495474472287-4d713b20e473?w=800&h=600&fit=crop'),
      (dLat: 0.010, dLng: 0.008, name: 'Göl Manzarası Cafe', photo: 'https://images.unsplash.com/photo-1447933601403-0c6688de566e?w=800&h=600&fit=crop'),
      (dLat: -0.012, dLng: 0.005, name: 'Kalfa Kahvecisi', photo: 'https://images.unsplash.com/photo-1529655683826-aba9b3e77383?w=800&h=600&fit=crop'),
      (dLat: 0.014, dLng: -0.002, name: 'Meydan Cafe', photo: 'https://images.unsplash.com/photo-1559925393-8be0ec4767c8?w=800&h=600&fit=crop'),
      (dLat: -0.015, dLng: -0.009, name: 'Şato Kahve Evi', photo: 'https://images.unsplash.com/photo-1497935586351-b67a49e012bf?w=800&h=600&fit=crop'),
      (dLat: 0.018, dLng: 0.012, name: 'Park Yanı Cafe', photo: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800&h=600&fit=crop'),
      (dLat: -0.019, dLng: 0.010, name: 'Eski Hükümet Konağı Kahvesi', photo: 'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=800&h=600&fit=crop'),
      (dLat: 0.020, dLng: -0.011, name: 'Anıt Kafe', photo: 'https://images.unsplash.com/photo-1525610449972-2a56a9036934?w=800&h=600&fit=crop'),
      (dLat: -0.021, dLng: -0.013, name: 'Pazar Yeri Kahvecisi', photo: 'https://images.unsplash.com/photo-1556742044-1a73c747d7a8?w=800&h=600&fit=crop'),
    ];

    final List<Cafe> cafes = [];
    for (int i = 0; i < offsets.length; i++) {
      final o = offsets[i];
      cafes.add(Cafe(
        id: 'nearby-cafe-${i + 1}',
        name: o.name,
        description: 'Yakınınızdaki konforlu bir kafe. Özenle kavrulmuş kahveler ve atıştırmalıklar.',
        address: 'Gebze/Tuzla Çevresi',
        latitude: centerLat + o.dLat,
        longitude: centerLng + o.dLng,
        photoUrl: o.photo,
        rating: 4.2 + (i % 4) * 0.1,
        reviewCount: 50 + i * 13,
        amenities: ['WiFi', 'Dış Mekan', if (i % 3 == 0) 'Otopark'],
        operatingHours: {
          'monday': {'open': '08:00', 'close': '22:00'},
          'tuesday': {'open': '08:00', 'close': '22:00'},
          'wednesday': {'open': '08:00', 'close': '22:00'},
          'thursday': {'open': '08:00', 'close': '23:00'},
          'friday': {'open': '08:00', 'close': '23:00'},
          'saturday': {'open': '09:00', 'close': '23:00'},
          'sunday': {'open': '09:00', 'close': '21:00'},
        },
        phoneNumber: '+90 216 000 00 ${i.toString().padLeft(2, '0')}',
        website: 'https://example.com/nearby-${i + 1}',
        isPartner: i % 2 == 0,
        createdAt: now,
        updatedAt: now,
      ));
    }
    return cafes;
  }
}

