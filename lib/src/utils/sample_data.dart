import 'package:cloud_firestore/cloud_firestore.dart';

class SampleDataService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> addSampleCoffees() async {
    final coffees = [
      {
        'name': 'Espresso',
        'description': 'Güçlü ve yoğun İtalyan kahvesi',
        'detailedDescription': 'Geleneksel İtalyan espresso, zengin krema ve güçlü aromasıyla.',
        'photoUrl': 'https://images.unsplash.com/photo-1510707577121-e1e1c5c73fd6',
        'basePrice': 25.0,
        'category': 'Espresso',
        'isAvailable': true,
        'preparationTime': 3,
        'ingredients': ['Espresso'],
        'sizes': {
          'small': {'name': 'Küçük', 'price': 25.0, 'ml': 30},
          'medium': {'name': 'Orta', 'price': 30.0, 'ml': 60},
        }
      },
      {
        'name': 'Americano',
        'description': 'Espresso ve sıcak su karışımı',
        'detailedDescription': 'Espresso ve sıcak su ile hazırlanan ferahlatıcı kahve.',
        'photoUrl': 'https://images.unsplash.com/photo-1520637836862-4d197d17c93a',
        'basePrice': 30.0,
        'category': 'Filtre Kahve',
        'isAvailable': true,
        'preparationTime': 4,
        'ingredients': ['Espresso', 'Su'],
      },
      {
        'name': 'Latte',
        'description': 'Espresso ve buharda pişmiş süt',
        'detailedDescription': 'Yumuşak köpük süt ile servilen kremsi espresso.',
        'photoUrl': 'https://images.unsplash.com/photo-1541167760496-1628856ab772',
        'basePrice': 35.0,
        'category': 'Latte',
        'isAvailable': true,
        'preparationTime': 5,
        'ingredients': ['Espresso', 'Süt'],
      }
    ];

    for (final coffee in coffees) {
      await _firestore.collection('coffees').add(coffee);
    }
  }

  static Future<void> addSampleCafes() async {
    final cafes = [
      {
        'name': 'Merkez Kafe',
        'description': 'Şehrin kalbinde huzurlu bir atmosfer',
        'address': 'Taksim Meydanı, İstanbul',
        'latitude': 41.0369,
        'longitude': 28.9852,
        'photoUrl': 'https://images.unsplash.com/photo-1554118811-1e0d58224f24',
        'rating': 4.5,
        'reviewCount': 120,
        'amenities': ['WiFi', 'Parking', 'Terrace'],
        'isPartner': true,
        'operatingHours': {
          'monday': {'open': '07:00', 'close': '22:00'},
          'tuesday': {'open': '07:00', 'close': '22:00'},
          'wednesday': {'open': '07:00', 'close': '22:00'},
          'thursday': {'open': '07:00', 'close': '22:00'},
          'friday': {'open': '07:00', 'close': '23:00'},
          'saturday': {'open': '08:00', 'close': '23:00'},
          'sunday': {'open': '08:00', 'close': '21:00'},
        },
        'phoneNumber': '+90 212 123 4567',
        'website': 'merkezkafe.com',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }
    ];

    for (final cafe in cafes) {
      await _firestore.collection('cafes').add(cafe);
    }
  }
}