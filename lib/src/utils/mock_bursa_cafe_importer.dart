
import 'package:cloud_firestore/cloud_firestore.dart';
import '../features/cafe/models/cafe_model.dart';
import '../utils/logger.dart';

class MockBursaCafeImporter {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> populateBursaCafes() async {
    Logger.info('Starting to populate mock Bursa cafe data', name: 'MockBursaCafeImporter');
    
    try {
      final cafes = _getBursaCafeData();
      
      for (final cafe in cafes) {
        await _firestore.collection('cafes').doc(cafe.id).set(cafe.toFirestore());
        Logger.info('Added cafe: ${cafe.name}', name: 'MockBursaCafeImporter');
      }
      
      Logger.info('Successfully populated ${cafes.length} Bursa cafes', name: 'MockBursaCafeImporter');
    } catch (e) {
      Logger.error('Error populating cafe data: $e', name: 'MockBursaCafeImporter');
      rethrow;
    }
  }

  List<Cafe> _getBursaCafeData() {
    final now = DateTime.now();
    
    return [
      Cafe(
        id: 'bursa-cafe-1',
        name: 'Bursa Cafe 1',
        description: 'A cozy cafe in Osmangazi.',
        address: 'Osmangazi, Bursa',
        latitude: 40.1929,
        longitude: 29.0645,
        photoUrl: 'https://images.unsplash.com/photo-1559925393-8be0ec4767c8?w=800&h=600&fit=crop',
        rating: 4.5,
        reviewCount: 120,
        amenities: ['WiFi', 'Klima', 'Kart Ödeme'],
        operatingHours: {'monday': {'open': '08:00', 'close': '22:00'}},
        phoneNumber: '+90 224 111 1111',
        website: 'https://www.example.com',
        isPartner: true,
        createdAt: now,
        updatedAt: now,
      ),
      Cafe(
        id: 'bursa-cafe-2',
        name: 'Bursa Cafe 2',
        description: 'A modern cafe in Nilüfer.',
        address: 'Nilüfer, Bursa',
        latitude: 40.2229,
        longitude: 29.0045,
        photoUrl: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800&h=600&fit=crop',
        rating: 4.2,
        reviewCount: 95,
        amenities: ['WiFi', 'Dış Mekan'],
        operatingHours: {'tuesday': {'open': '09:00', 'close': '23:00'}},
        phoneNumber: '+90 224 222 2222',
        website: 'https://www.example.com',
        isPartner: false,
        createdAt: now,
        updatedAt: now,
      ),
      Cafe(
        id: 'bursa-cafe-3',
        name: 'Bursa Cafe 3',
        description: 'A traditional cafe in Yıldırım.',
        address: 'Yıldırım, Bursa',
        latitude: 40.2629,
        longitude: 29.1245,
        photoUrl: 'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=800&h=600&fit=crop',
        rating: 4.8,
        reviewCount: 210,
        amenities: ['Türk Kahvesi', 'Tatlı'],
        operatingHours: {'wednesday': {'open': '07:00', 'close': '21:00'}},
        phoneNumber: '+90 224 333 3333',
        website: 'https://www.example.com',
        isPartner: true,
        createdAt: now,
        updatedAt: now,
      ),
      Cafe(
        id: 'bursa-cafe-4',
        name: 'Bursa Cafe 4',
        description: 'A cafe with a view in Tophane.',
        address: 'Tophane, Bursa',
        latitude: 40.1829,
        longitude: 29.0545,
        photoUrl: 'https://images.unsplash.com/photo-1497935586351-b67a49e012bf?w=800&h=600&fit=crop',
        rating: 4.6,
        reviewCount: 150,
        amenities: ['Manzara', 'Dış Mekan'],
        operatingHours: {'thursday': {'open': '10:00', 'close': '22:00'}},
        phoneNumber: '+90 224 444 4444',
        website: 'https://www.example.com',
        isPartner: false,
        createdAt: now,
        updatedAt: now,
      ),
      Cafe(
        id: 'bursa-cafe-5',
        name: 'Bursa Cafe 5',
        description: 'A central cafe in Heykel.',
        address: 'Heykel, Bursa',
        latitude: 40.2029,
        longitude: 29.0745,
        photoUrl: 'https://images.unsplash.com/photo-1495474472287-4d713b20e473?w=800&h=600&fit=crop',
        rating: 4.3,
        reviewCount: 180,
        amenities: ['WiFi', 'Kart Ödeme'],
        operatingHours: {'friday': {'open': '08:30', 'close': '23:30'}},
        phoneNumber: '+90 224 555 5555',
        website: 'https://www.example.com',
        isPartner: true,
        createdAt: now,
        updatedAt: now,
      ),
      Cafe(
        id: 'bursa-cafe-6',
        name: 'Bursa Cafe 6',
        description: 'A quiet cafe in Çekirge.',
        address: 'Çekirge, Bursa',
        latitude: 40.2429,
        longitude: 28.9845,
        photoUrl: 'https://images.unsplash.com/photo-1511920183353-3c7c95a5742c?w=800&h=600&fit=crop',
        rating: 4.4,
        reviewCount: 80,
        amenities: ['Sakin', 'Kitap Okuma Alanı'],
        operatingHours: {'saturday': {'open': '09:00', 'close': '20:00'}},
        phoneNumber: '+90 224 666 6666',
        website: 'https://www.example.com',
        isPartner: false,
        createdAt: now,
        updatedAt: now,
      ),
      Cafe(
        id: 'bursa-cafe-7',
        name: 'Bursa Cafe 7',
        description: 'A historic cafe in Muradiye.',
        address: 'Muradiye, Bursa',
        latitude: 40.1729,
        longitude: 29.0345,
        photoUrl: 'https://images.unsplash.com/photo-1564890373595-3f7838300930?w=800&h=600&fit=crop',
        rating: 4.7,
        reviewCount: 250,
        amenities: ['Tarihi', 'Türk Kahvesi'],
        operatingHours: {'sunday': {'open': '10:00', 'close': '19:00'}},
        phoneNumber: '+90 224 777 7777',
        website: 'https://www.example.com',
        isPartner: true,
        createdAt: now,
        updatedAt: now,
      ),
      Cafe(
        id: 'bursa-cafe-8',
        name: 'Bursa Cafe 8',
        description: 'A lively cafe in Setbaşı.',
        address: 'Setbaşı, Bursa',
        latitude: 40.2129,
        longitude: 29.0945,
        photoUrl: 'https://images.unsplash.com/photo-1525610449972-2a56a9036934?w=800&h=600&fit=crop',
        rating: 4.1,
        reviewCount: 110,
        amenities: ['Canlı Müzik', 'Dış Mekan'],
        operatingHours: {'monday': {'open': '11:00', 'close': '01:00'}},
        phoneNumber: '+90 224 888 8888',
        website: 'https://www.example.com',
        isPartner: false,
        createdAt: now,
        updatedAt: now,
      ),
      Cafe(
        id: 'bursa-cafe-9',
        name: 'Bursa Cafe 9',
        description: 'A trendy cafe on FSM Bulvarı.',
        address: 'FSM Bulvarı, Bursa',
        latitude: 40.2329,
        longitude: 29.0145,
        photoUrl: 'https://images.unsplash.com/photo-1556742044-1a73c747d7a8?w=800&h=600&fit=crop',
        rating: 4.5,
        reviewCount: 320,
        amenities: ['WiFi', 'Modern', 'Takeaway'],
        operatingHours: {'tuesday': {'open': '08:00', 'close': '24:00'}},
        phoneNumber: '+90 224 999 9999',
        website: 'https://www.example.com',
        isPartner: true,
        createdAt: now,
        updatedAt: now,
      ),
      Cafe(
        id: 'bursa-cafe-10',
        name: 'Bursa Cafe 10',
        description: 'A spiritual cafe near Emirsultan.',
        address: 'Emirsultan, Bursa',
        latitude: 40.1629,
        longitude: 29.0845,
        photoUrl: 'https://images.unsplash.com/photo-1594788445538-f0728323e3a5?w=800&h=600&fit=crop',
        rating: 4.9,
        reviewCount: 450,
        amenities: ['Huzurlu', 'Çay Bahçesi'],
        operatingHours: {'wednesday': {'open': '09:00', 'close': '21:00'}},
        phoneNumber: '+90 224 000 0000',
        website: 'https://www.example.com',
        isPartner: false,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }
}
