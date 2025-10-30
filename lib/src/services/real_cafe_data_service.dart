import 'package:cloud_firestore/cloud_firestore.dart';
import '../features/cafe/models/cafe_model.dart';
import '../utils/logger.dart';

class RealCafeDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RealCafeDataService() {
    Logger.info('RealCafeDataService initialized', name: 'RealCafeDataService');
  }

  /// İstanbul'daki gerçek kafe verilerini Firebase'e ekler
  Future<void> populateRealCafeData() async {
    Logger.info('Starting to populate real Istanbul cafe data', name: 'RealCafeDataService');
    
    try {
      final cafes = _getIstanbulCafeData();
      
      for (final cafe in cafes) {
        await _firestore.collection('cafes').doc(cafe.id).set(cafe.toFirestore());
        Logger.info('Added cafe: ${cafe.name}', name: 'RealCafeDataService');
      }
      
      Logger.info('Successfully populated ${cafes.length} Istanbul cafes', name: 'RealCafeDataService');
    } catch (e) {
      Logger.error('Error populating cafe data: $e', name: 'RealCafeDataService');
      rethrow;
    }
  }

  /// İstanbul'daki gerçek kafe verilerini döndürür
  List<Cafe> _getIstanbulCafeData() {
    final now = DateTime.now();
    
    return [
      // Beyoğlu Bölgesi
      Cafe(
        id: 'starbucks-taksim',
        name: 'Starbucks Taksim',
        description: 'İstiklal Caddesi\'nde bulunan popüler Starbucks şubesi',
        address: 'İstiklal Caddesi No:123, Beyoğlu/İstanbul',
        latitude: 41.0369,
        longitude: 28.9852,
        photoUrl: 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=800&h=600&fit=crop',
        rating: 4.2,
        reviewCount: 1250,
        amenities: ['WiFi', 'Klima', 'Kart Ödeme', 'Takeaway', 'Dış Mekan'],
        operatingHours: {
          'monday': {'open': '07:00', 'close': '23:00', 'closed': false},
          'tuesday': {'open': '07:00', 'close': '23:00', 'closed': false},
          'wednesday': {'open': '07:00', 'close': '23:00', 'closed': false},
          'thursday': {'open': '07:00', 'close': '23:00', 'closed': false},
          'friday': {'open': '07:00', 'close': '24:00', 'closed': false},
          'saturday': {'open': '08:00', 'close': '24:00', 'closed': false},
          'sunday': {'open': '08:00', 'close': '22:00', 'closed': false},
        },
        phoneNumber: '+90 212 555 0123',
        website: 'https://www.starbucks.com.tr',
        isPartner: true,
        createdAt: now,
        updatedAt: now,
      ),

      Cafe(
        id: 'kahve-dunyasi-galata',
        name: 'Kahve Dünyası Galata',
        description: 'Galata Kulesi yakınında Türk kahvesi uzmanı',
        address: 'Galata Kulesi Sokak No:15, Beyoğlu/İstanbul',
        latitude: 41.0256,
        longitude: 28.9744,
        photoUrl: 'https://images.unsplash.com/photo-1554118811-1e0d58224f24?w=800&h=600&fit=crop',
        rating: 4.5,
        reviewCount: 890,
        amenities: ['WiFi', 'Türk Kahvesi', 'Tatlı', 'Kart Ödeme', 'Tarihi Mekan'],
        operatingHours: {
          'monday': {'open': '08:00', 'close': '22:00', 'closed': false},
          'tuesday': {'open': '08:00', 'close': '22:00', 'closed': false},
          'wednesday': {'open': '08:00', 'close': '22:00', 'closed': false},
          'thursday': {'open': '08:00', 'close': '22:00', 'closed': false},
          'friday': {'open': '08:00', 'close': '23:00', 'closed': false},
          'saturday': {'open': '09:00', 'close': '23:00', 'closed': false},
          'sunday': {'open': '09:00', 'close': '21:00', 'closed': false},
        },
        phoneNumber: '+90 212 555 0456',
        website: 'https://www.kahvedunyasi.com',
        isPartner: true,
        createdAt: now,
        updatedAt: now,
      ),

      // Kadıköy Bölgesi
      Cafe(
        id: 'petra-roasting-kadikoy',
        name: 'Petra Roasting Co. Kadıköy',
        description: 'Özel kavrum kahveleri ve latte art uzmanı',
        address: 'Moda Caddesi No:87, Kadıköy/İstanbul',
        latitude: 40.9876,
        longitude: 29.0258,
        photoUrl: 'https://images.unsplash.com/photo-1442512595331-e89e73853f31?w=800&h=600&fit=crop',
        rating: 4.7,
        reviewCount: 650,
        amenities: ['WiFi', 'Özel Kavrum', 'Latte Art', 'Vegan Seçenekler', 'Çalışma Alanı'],
        operatingHours: {
          'monday': {'open': '07:30', 'close': '21:00', 'closed': false},
          'tuesday': {'open': '07:30', 'close': '21:00', 'closed': false},
          'wednesday': {'open': '07:30', 'close': '21:00', 'closed': false},
          'thursday': {'open': '07:30', 'close': '21:00', 'closed': false},
          'friday': {'open': '07:30', 'close': '22:00', 'closed': false},
          'saturday': {'open': '08:30', 'close': '22:00', 'closed': false},
          'sunday': {'open': '09:00', 'close': '20:00', 'closed': false},
        },
        phoneNumber: '+90 216 555 0789',
        website: 'https://www.petraroasting.com',
        isPartner: true,
        createdAt: now,
        updatedAt: now,
      ),

      Cafe(
        id: 'fazil-bey-kadikoy',
        name: 'Fazıl Bey Türk Kahvesi',
        description: 'Geleneksel Türk kahvesi ve lokum ikramı',
        address: 'Serasker Caddesi No:1, Kadıköy/İstanbul',
        latitude: 40.9900,
        longitude: 29.0250,
        photoUrl: 'https://images.unsplash.com/photo-1559056199-641a0ac8b55e?w=800&h=600&fit=crop',
        rating: 4.6,
        reviewCount: 1100,
        amenities: ['Türk Kahvesi', 'Lokum İkramı', 'Geleneksel', 'Nakit Ödeme', 'Tarihi'],
        operatingHours: {
          'monday': {'open': '08:00', 'close': '20:00', 'closed': false},
          'tuesday': {'open': '08:00', 'close': '20:00', 'closed': false},
          'wednesday': {'open': '08:00', 'close': '20:00', 'closed': false},
          'thursday': {'open': '08:00', 'close': '20:00', 'closed': false},
          'friday': {'open': '08:00', 'close': '20:00', 'closed': false},
          'saturday': {'open': '08:00', 'close': '20:00', 'closed': false},
          'sunday': {'open': '09:00', 'close': '19:00', 'closed': false},
        },
        phoneNumber: '+90 216 555 0321',
        website: '',
        isPartner: false,
        createdAt: now,
        updatedAt: now,
      ),

      // Beşiktaş Bölgesi
      Cafe(
        id: 'coffee-department-besiktas',
        name: 'Coffee Department Beşiktaş',
        description: 'Modern kahve kültürü ve özel blend\'ler',
        address: 'Barbaros Bulvarı No:145, Beşiktaş/İstanbul',
        latitude: 41.0422,
        longitude: 29.0094,
        photoUrl: 'https://images.unsplash.com/photo-1521017432531-fbd92d768814?w=800&h=600&fit=crop',
        rating: 4.4,
        reviewCount: 780,
        amenities: ['WiFi', 'Özel Blend', 'Brunch', 'Kart Ödeme', 'Çalışma Alanı'],
        operatingHours: {
          'monday': {'open': '07:00', 'close': '22:00', 'closed': false},
          'tuesday': {'open': '07:00', 'close': '22:00', 'closed': false},
          'wednesday': {'open': '07:00', 'close': '22:00', 'closed': false},
          'thursday': {'open': '07:00', 'close': '22:00', 'closed': false},
          'friday': {'open': '07:00', 'close': '23:00', 'closed': false},
          'saturday': {'open': '08:00', 'close': '23:00', 'closed': false},
          'sunday': {'open': '08:00', 'close': '21:00', 'closed': false},
        },
        phoneNumber: '+90 212 555 0654',
        website: 'https://www.coffeedepartment.com',
        isPartner: true,
        createdAt: now,
        updatedAt: now,
      ),

      // Şişli Bölgesi
      Cafe(
        id: 'kronotrop-sisli',
        name: 'Kronotrop Şişli',
        description: 'Third wave coffee ve özel kavrum',
        address: 'Nişantaşı Caddesi No:67, Şişli/İstanbul',
        latitude: 41.0460,
        longitude: 28.9880,
        photoUrl: 'https://images.unsplash.com/photo-1447933601403-0c6688de566e?w=800&h=600&fit=crop',
        rating: 4.8,
        reviewCount: 920,
        amenities: ['WiFi', 'Third Wave Coffee', 'Özel Kavrum', 'V60', 'Chemex', 'Çalışma Alanı'],
        operatingHours: {
          'monday': {'open': '07:30', 'close': '21:30', 'closed': false},
          'tuesday': {'open': '07:30', 'close': '21:30', 'closed': false},
          'wednesday': {'open': '07:30', 'close': '21:30', 'closed': false},
          'thursday': {'open': '07:30', 'close': '21:30', 'closed': false},
          'friday': {'open': '07:30', 'close': '22:30', 'closed': false},
          'saturday': {'open': '08:30', 'close': '22:30', 'closed': false},
          'sunday': {'open': '09:00', 'close': '20:30', 'closed': false},
        },
        phoneNumber: '+90 212 555 0987',
        website: 'https://www.kronotrop.com',
        isPartner: true,
        createdAt: now,
        updatedAt: now,
      ),

      // Eminönü Bölgesi
      Cafe(
        id: 'pandeli-eminonu',
        name: 'Pandeli Kahvesi',
        description: 'Tarihi Mısır Çarşısı\'nda geleneksel kahve',
        address: 'Mısır Çarşısı No:1, Eminönü/İstanbul',
        latitude: 41.0166,
        longitude: 28.9706,
        photoUrl: 'https://firebasestorage.googleapis.com/v0/b/coffink-app.appspot.com/o/cafes%2Fpandeli-eminonu.jpg?alt=media',
        rating: 4.3,
        reviewCount: 1500,
        amenities: ['Türk Kahvesi', 'Tarihi Mekan', 'Baklava', 'Lokum', 'Geleneksel'],
        operatingHours: {
          'monday': {'open': '08:00', 'close': '19:00', 'closed': false},
          'tuesday': {'open': '08:00', 'close': '19:00', 'closed': false},
          'wednesday': {'open': '08:00', 'close': '19:00', 'closed': false},
          'thursday': {'open': '08:00', 'close': '19:00', 'closed': false},
          'friday': {'open': '08:00', 'close': '19:00', 'closed': false},
          'saturday': {'open': '08:00', 'close': '19:00', 'closed': false},
          'sunday': {'open': '09:00', 'close': '18:00', 'closed': false},
        },
        phoneNumber: '+90 212 555 0147',
        website: '',
        isPartner: false,
        createdAt: now,
        updatedAt: now,
      ),

      // Ortaköy Bölgesi
      Cafe(
        id: 'house-cafe-ortakoy',
        name: 'House Cafe Ortaköy',
        description: 'Boğaz manzaralı modern kafe',
        address: 'Ortaköy Meydanı No:8, Beşiktaş/İstanbul',
        latitude: 41.0553,
        longitude: 29.0267,
        photoUrl: 'https://firebasestorage.googleapis.com/v0/b/coffink-app.appspot.com/o/cafes%2Fhouse-cafe-ortakoy.jpg?alt=media',
        rating: 4.1,
        reviewCount: 2100,
        amenities: ['WiFi', 'Boğaz Manzarası', 'Brunch', 'Kart Ödeme', 'Dış Mekan', 'Valet'],
        operatingHours: {
          'monday': {'open': '08:00', 'close': '24:00', 'closed': false},
          'tuesday': {'open': '08:00', 'close': '24:00', 'closed': false},
          'wednesday': {'open': '08:00', 'close': '24:00', 'closed': false},
          'thursday': {'open': '08:00', 'close': '24:00', 'closed': false},
          'friday': {'open': '08:00', 'close': '02:00', 'closed': false},
          'saturday': {'open': '08:00', 'close': '02:00', 'closed': false},
          'sunday': {'open': '08:00', 'close': '24:00', 'closed': false},
        },
        phoneNumber: '+90 212 555 0258',
        website: 'https://www.housecafe.com.tr',
        isPartner: true,
        createdAt: now,
        updatedAt: now,
      ),

      // Cihangir Bölgesi
      Cafe(
        id: 'smyrna-coffee-cihangir',
        name: 'Smyrna Coffee Cihangir',
        description: 'Sakin atmosferde özel kahveler',
        address: 'Cihangir Caddesi No:23, Beyoğlu/İstanbul',
        latitude: 41.0320,
        longitude: 28.9790,
        photoUrl: 'https://firebasestorage.googleapis.com/v0/b/coffink-app.appspot.com/o/cafes%2Fsmyrna-coffee-cihangir.jpg?alt=media',
        rating: 4.6,
        reviewCount: 450,
        amenities: ['WiFi', 'Sakin Atmosfer', 'Kitap', 'Özel Kahve', 'Çalışma Alanı'],
        operatingHours: {
          'monday': {'open': '08:00', 'close': '20:00', 'closed': false},
          'tuesday': {'open': '08:00', 'close': '20:00', 'closed': false},
          'wednesday': {'open': '08:00', 'close': '20:00', 'closed': false},
          'thursday': {'open': '08:00', 'close': '20:00', 'closed': false},
          'friday': {'open': '08:00', 'close': '21:00', 'closed': false},
          'saturday': {'open': '09:00', 'close': '21:00', 'closed': false},
          'sunday': {'open': '09:00', 'close': '19:00', 'closed': false},
        },
        phoneNumber: '+90 212 555 0369',
        website: '',
        isPartner: false,
        createdAt: now,
        updatedAt: now,
      ),

      // Bakırköy Bölgesi
      Cafe(
        id: 'gloria-jeans-bakirkoy',
        name: 'Gloria Jean\'s Bakırköy',
        description: 'Aile dostu kafe zinciri',
        address: 'Capacity AVM, Bakırköy/İstanbul',
        latitude: 40.9833,
        longitude: 28.8667,
        photoUrl: 'https://firebasestorage.googleapis.com/v0/b/coffink-app.appspot.com/o/cafes%2Fgloria-jeans-bakirkoy.jpg?alt=media',
        rating: 4.0,
        reviewCount: 850,
        amenities: ['WiFi', 'Aile Dostu', 'AVM İçi', 'Kart Ödeme', 'Çocuk Menüsü'],
        operatingHours: {
          'monday': {'open': '10:00', 'close': '22:00', 'closed': false},
          'tuesday': {'open': '10:00', 'close': '22:00', 'closed': false},
          'wednesday': {'open': '10:00', 'close': '22:00', 'closed': false},
          'thursday': {'open': '10:00', 'close': '22:00', 'closed': false},
          'friday': {'open': '10:00', 'close': '23:00', 'closed': false},
          'saturday': {'open': '10:00', 'close': '23:00', 'closed': false},
          'sunday': {'open': '10:00', 'close': '22:00', 'closed': false},
        },
        phoneNumber: '+90 212 555 0741',
        website: 'https://www.gloriajeans.com.tr',
        isPartner: true,
        createdAt: now,
        updatedAt: now,
      ),

      // Üsküdar Bölgesi
      Cafe(
        id: 'dem-tea-uskudar',
        name: 'Dem Tea & Coffee Üsküdar',
        description: 'Çay ve kahve uzmanı, Boğaz manzaralı',
        address: 'Salacak Sahil Yolu No:12, Üsküdar/İstanbul',
        latitude: 41.0214,
        longitude: 29.0061,
        photoUrl: 'https://firebasestorage.googleapis.com/v0/b/coffink-app.appspot.com/o/cafes%2Fdem-tea-uskudar.jpg?alt=media',
        rating: 4.4,
        reviewCount: 680,
        amenities: ['WiFi', 'Çay Çeşitleri', 'Boğaz Manzarası', 'Nargile', 'Dış Mekan'],
        operatingHours: {
          'monday': {'open': '08:00', 'close': '23:00', 'closed': false},
          'tuesday': {'open': '08:00', 'close': '23:00', 'closed': false},
          'wednesday': {'open': '08:00', 'close': '23:00', 'closed': false},
          'thursday': {'open': '08:00', 'close': '23:00', 'closed': false},
          'friday': {'open': '08:00', 'close': '24:00', 'closed': false},
          'saturday': {'open': '08:00', 'close': '24:00', 'closed': false},
          'sunday': {'open': '08:00', 'close': '23:00', 'closed': false},
        },
        phoneNumber: '+90 216 555 0852',
        website: 'https://www.demtea.com',
        isPartner: false,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  /// Mevcut kafe verilerini temizler (dikkatli kullanın!)
  Future<void> clearExistingCafeData() async {
    Logger.warning('Clearing existing cafe data', name: 'RealCafeDataService');
    
    try {
      final snapshot = await _firestore.collection('cafes').get();
      
      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }
      
      Logger.info('Cleared ${snapshot.docs.length} existing cafe documents', name: 'RealCafeDataService');
    } catch (e) {
      Logger.error('Error clearing cafe data: $e', name: 'RealCafeDataService');
      rethrow;
    }
  }

  /// Kafe verilerini günceller (mevcut veriler varsa günceller, yoksa ekler)
  Future<void> updateCafeData() async {
    Logger.info('Updating cafe data', name: 'RealCafeDataService');
    
    try {
      final cafes = _getIstanbulCafeData();
      
      for (final cafe in cafes) {
        await _firestore.collection('cafes').doc(cafe.id).set(
          cafe.toFirestore(),
          SetOptions(merge: true), // Mevcut veriyi koruyarak güncelle
        );
        Logger.info('Updated cafe: ${cafe.name}', name: 'RealCafeDataService');
      }
      
      Logger.info('Successfully updated ${cafes.length} Istanbul cafes', name: 'RealCafeDataService');
    } catch (e) {
      Logger.error('Error updating cafe data: $e', name: 'RealCafeDataService');
      rethrow;
    }
  }
}