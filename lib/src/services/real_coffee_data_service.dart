import 'package:cloud_firestore/cloud_firestore.dart';
import '../features/home/models/coffee_model.dart';
import '../utils/logger.dart';

class RealCoffeeDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RealCoffeeDataService() {
    Logger.info('RealCoffeeDataService initialized', name: 'RealCoffeeDataService');
  }

  /// Türk kahve çeşitleri ve gerçek kahve verilerini Firebase'e ekler
  Future<void> populateRealCoffeeData() async {
    Logger.info('Starting to populate real Turkish coffee data', name: 'RealCoffeeDataService');
    
    try {
      final coffees = _getTurkishCoffeeData();
      
      for (final coffee in coffees) {
        await _firestore.collection('coffees').doc(coffee.id).set(coffee.toMap());
        Logger.info('Added coffee: ${coffee.name}', name: 'RealCoffeeDataService');
      }
      
      Logger.info('Successfully populated ${coffees.length} Turkish coffees', name: 'RealCoffeeDataService');
    } catch (e) {
      Logger.error('Error populating coffee data: $e', name: 'RealCoffeeDataService');
      rethrow;
    }
  }

  /// Gerçek Türk kahve çeşitleri verilerini döndürür
  List<Coffee> _getTurkishCoffeeData() {
    return [
      // Geleneksel Türk Kahveleri
      Coffee(
        id: 'turk-kahvesi-sade',
        name: 'Türk Kahvesi (Sade)',
        description: 'UNESCO kültürel mirası geleneksel Türk kahvesi',
        detailedDescription: 'Geleneksel yöntemlerle hazırlanan, ince öğütülmüş kahve çekirdeklerinden yapılan dünyaca ünlü Türk kahvesi. Şekersiz olarak servis edilir.',
        photoUrl: 'https://firebasestorage.googleapis.com/v0/b/coffink-app.appspot.com/o/coffees%2Fturk-kahvesi-sade.jpg?alt=media',
        basePrice: 35.0,
        sizes: {
          'small': CoffeeSize(name: 'Küçük Fincan', price: 35.0, ml: 60),
          'medium': CoffeeSize(name: 'Orta Fincan', price: 40.0, ml: 80),
        },
        ingredients: ['Türk kahvesi', 'Su'],
        nutritionalInfo: NutritionalInfo(
          calories: 5,
          caffeine: 65,
          protein: 0.3,
        ),
        category: 'Geleneksel',
        isAvailable: true,
        preparationTime: 8,
      ),
      
      Coffee(
        id: 'turk-kahvesi-sekerli',
        name: 'Türk Kahvesi (Şekerli)',
        description: 'Orta şekerli geleneksel Türk kahvesi',
        detailedDescription: 'Geleneksel yöntemlerle hazırlanan, orta şekerli Türk kahvesi. Şeker kahve ile birlikte pişirilir.',
        photoUrl: 'https://firebasestorage.googleapis.com/v0/b/coffink-app.appspot.com/o/coffees%2Fturk-kahvesi-sekerli.jpg?alt=media',
        basePrice: 35.0,
        sizes: {
          'small': CoffeeSize(name: 'Küçük Fincan', price: 35.0, ml: 60),
          'medium': CoffeeSize(name: 'Orta Fincan', price: 40.0, ml: 80),
        },
        ingredients: ['Türk kahvesi', 'Su', 'Şeker'],
        nutritionalInfo: NutritionalInfo(
          calories: 25,
          caffeine: 65,
          protein: 0.3,
        ),
        category: 'Geleneksel',
        isAvailable: true,
        preparationTime: 8,
      ),

      // Espresso Bazlı Kahveler
      Coffee(
        id: 'espresso',
        name: 'Espresso',
        description: 'Yoğun ve kremli İtalyan espresso',
        detailedDescription: 'Yüksek basınçla hazırlanan, yoğun aromalı ve kremli espresso. Kahve severlerin favorisi.',
        photoUrl: 'https://firebasestorage.googleapis.com/v0/b/coffink-app.appspot.com/o/coffees%2Fespresso.jpg?alt=media',
        basePrice: 25.0,
        sizes: {
          'single': CoffeeSize(name: 'Tek Shot', price: 25.0, ml: 30),
          'double': CoffeeSize(name: 'Çift Shot', price: 35.0, ml: 60),
        },
        ingredients: ['Espresso çekirdeği'],
        nutritionalInfo: NutritionalInfo(
          calories: 9,
          caffeine: 63,
          protein: 0.1,
        ),
        category: 'Espresso',
        isAvailable: true,
        preparationTime: 3,
      ),

      Coffee(
        id: 'americano',
        name: 'Americano',
        description: 'Espresso ve sıcak su karışımı',
        detailedDescription: 'Espresso üzerine sıcak su eklenerek hazırlanan, hafif ve içimi kolay kahve.',
        photoUrl: 'https://firebasestorage.googleapis.com/v0/b/coffink-app.appspot.com/o/coffees%2Famericano.jpg?alt=media',
        basePrice: 30.0,
        sizes: {
          'small': CoffeeSize(name: 'Küçük', price: 30.0, ml: 240),
          'medium': CoffeeSize(name: 'Orta', price: 35.0, ml: 350),
          'large': CoffeeSize(name: 'Büyük', price: 40.0, ml: 470),
        },
        ingredients: ['Espresso', 'Sıcak su'],
        nutritionalInfo: NutritionalInfo(
          calories: 15,
          caffeine: 154,
          protein: 0.3,
        ),
        category: 'Espresso',
        isAvailable: true,
        preparationTime: 4,
      ),

      // Sütlü Kahveler
      Coffee(
        id: 'cappuccino',
        name: 'Cappuccino',
        description: 'Espresso, süt ve süt köpüğü karışımı',
        detailedDescription: 'Espresso, buharla ısıtılmış süt ve yoğun süt köpüğünden oluşan klasik İtalyan kahvesi.',
        photoUrl: 'https://firebasestorage.googleapis.com/v0/b/coffink-app.appspot.com/o/coffees%2Fcappuccino.jpg?alt=media',
        basePrice: 40.0,
        sizes: {
          'small': CoffeeSize(name: 'Küçük', price: 40.0, ml: 150),
          'medium': CoffeeSize(name: 'Orta', price: 45.0, ml: 200),
          'large': CoffeeSize(name: 'Büyük', price: 50.0, ml: 250),
        },
        ingredients: ['Espresso', 'Süt', 'Süt köpüğü'],
        nutritionalInfo: NutritionalInfo(
          calories: 80,
          caffeine: 63,
          protein: 4.0,
        ),
        category: 'Sütlü',
        isAvailable: true,
        preparationTime: 5,
      ),

      Coffee(
        id: 'latte',
        name: 'Latte',
        description: 'Espresso ve bol miktarda buharlanmış süt',
        detailedDescription: 'Espresso üzerine bol miktarda buharlanmış süt ve ince bir tabaka süt köpüğü ile hazırlanan yumuşak kahve.',
        photoUrl: 'https://firebasestorage.googleapis.com/v0/b/coffink-app.appspot.com/o/coffees%2Flatte.jpg?alt=media',
        basePrice: 42.0,
        sizes: {
          'small': CoffeeSize(name: 'Küçük', price: 42.0, ml: 240),
          'medium': CoffeeSize(name: 'Orta', price: 47.0, ml: 350),
          'large': CoffeeSize(name: 'Büyük', price: 52.0, ml: 470),
        },
        ingredients: ['Espresso', 'Buharlanmış süt', 'Süt köpüğü'],
        nutritionalInfo: NutritionalInfo(
          calories: 120,
          caffeine: 63,
          protein: 6.0,
        ),
        category: 'Sütlü',
        isAvailable: true,
        preparationTime: 5,
      ),

      Coffee(
        id: 'flat-white',
        name: 'Flat White',
        description: 'Çift espresso ve mikroköpük süt',
        detailedDescription: 'Çift espresso üzerine mikroköpük süt ile hazırlanan, güçlü kahve tadı olan Avustralya kökenli kahve.',
        photoUrl: 'https://firebasestorage.googleapis.com/v0/b/coffink-app.appspot.com/o/coffees%2Fflat-white.jpg?alt=media',
        basePrice: 45.0,
        sizes: {
          'small': CoffeeSize(name: 'Küçük', price: 45.0, ml: 160),
          'medium': CoffeeSize(name: 'Orta', price: 50.0, ml: 220),
        },
        ingredients: ['Çift espresso', 'Mikroköpük süt'],
        nutritionalInfo: NutritionalInfo(
          calories: 95,
          caffeine: 130,
          protein: 5.5,
        ),
        category: 'Sütlü',
        isAvailable: true,
        preparationTime: 6,
      ),

      // Soğuk Kahveler
      Coffee(
        id: 'iced-americano',
        name: 'Buzlu Americano',
        description: 'Soğuk espresso ve su karışımı',
        detailedDescription: 'Espresso, soğuk su ve buz ile hazırlanan serinletici kahve.',
        photoUrl: 'https://firebasestorage.googleapis.com/v0/b/coffink-app.appspot.com/o/coffees%2Ficed-americano.jpg?alt=media',
        basePrice: 32.0,
        sizes: {
          'medium': CoffeeSize(name: 'Orta', price: 32.0, ml: 350),
          'large': CoffeeSize(name: 'Büyük', price: 37.0, ml: 470),
        },
        ingredients: ['Espresso', 'Soğuk su', 'Buz'],
        nutritionalInfo: NutritionalInfo(
          calories: 15,
          caffeine: 154,
          protein: 0.3,
        ),
        category: 'Soğuk',
        isAvailable: true,
        preparationTime: 4,
      ),

      Coffee(
        id: 'iced-latte',
        name: 'Buzlu Latte',
        description: 'Soğuk espresso, süt ve buz',
        detailedDescription: 'Espresso, soğuk süt ve buz ile hazırlanan serinletici sütlü kahve.',
        photoUrl: 'https://firebasestorage.googleapis.com/v0/b/coffink-app.appspot.com/o/coffees%2Ficed-latte.jpg?alt=media',
        basePrice: 44.0,
        sizes: {
          'medium': CoffeeSize(name: 'Orta', price: 44.0, ml: 350),
          'large': CoffeeSize(name: 'Büyük', price: 49.0, ml: 470),
        },
        ingredients: ['Espresso', 'Soğuk süt', 'Buz'],
        nutritionalInfo: NutritionalInfo(
          calories: 110,
          caffeine: 63,
          protein: 6.0,
        ),
        category: 'Soğuk',
        isAvailable: true,
        preparationTime: 4,
      ),

      // Özel Kahveler
      Coffee(
        id: 'mocha',
        name: 'Mocha',
        description: 'Espresso, çikolata ve süt karışımı',
        detailedDescription: 'Espresso, çikolata sosu ve buharlanmış süt ile hazırlanan tatlı kahve.',
        photoUrl: 'https://firebasestorage.googleapis.com/v0/b/coffink-app.appspot.com/o/coffees%2Fmocha.jpg?alt=media',
        basePrice: 48.0,
        sizes: {
          'small': CoffeeSize(name: 'Küçük', price: 48.0, ml: 240),
          'medium': CoffeeSize(name: 'Orta', price: 53.0, ml: 350),
          'large': CoffeeSize(name: 'Büyük', price: 58.0, ml: 470),
        },
        ingredients: ['Espresso', 'Çikolata sosu', 'Buharlanmış süt', 'Krema'],
        nutritionalInfo: NutritionalInfo(
          calories: 180,
          caffeine: 95,
          protein: 7.0,
        ),
        category: 'Özel',
        isAvailable: true,
        preparationTime: 6,
      ),

      Coffee(
        id: 'caramel-macchiato',
        name: 'Karamel Macchiato',
        description: 'Vanilya şuruplu süt, espresso ve karamel sos',
        detailedDescription: 'Vanilya şuruplu buharlanmış süt, espresso ve üzerine karamel sos ile hazırlanan özel kahve.',
        photoUrl: 'https://firebasestorage.googleapis.com/v0/b/coffink-app.appspot.com/o/coffees%2Fcaramel-macchiato.jpg?alt=media',
        basePrice: 50.0,
        sizes: {
          'small': CoffeeSize(name: 'Küçük', price: 50.0, ml: 240),
          'medium': CoffeeSize(name: 'Orta', price: 55.0, ml: 350),
          'large': CoffeeSize(name: 'Büyük', price: 60.0, ml: 470),
        },
        ingredients: ['Espresso', 'Buharlanmış süt', 'Vanilya şurubu', 'Karamel sos'],
        nutritionalInfo: NutritionalInfo(
          calories: 210,
          caffeine: 75,
          protein: 8.0,
        ),
        category: 'Özel',
        isAvailable: true,
        preparationTime: 7,
      ),

      // Filtre Kahveler
      Coffee(
        id: 'v60-pour-over',
        name: 'V60 Pour Over',
        description: 'El yapımı filtre kahve',
        detailedDescription: 'V60 dripper ile özenle hazırlanan, tek köken kahve çekirdeklerinden yapılan filtre kahve.',
        photoUrl: 'https://firebasestorage.googleapis.com/v0/b/coffink-app.appspot.com/o/coffees%2Fv60-pour-over.jpg?alt=media',
        basePrice: 38.0,
        sizes: {
          'medium': CoffeeSize(name: 'Orta', price: 38.0, ml: 250),
          'large': CoffeeSize(name: 'Büyük', price: 43.0, ml: 350),
        },
        ingredients: ['Özel filtre kahve çekirdeği', 'Sıcak su'],
        nutritionalInfo: NutritionalInfo(
          calories: 5,
          caffeine: 120,
          protein: 0.3,
        ),
        category: 'Filtre',
        isAvailable: true,
        preparationTime: 8,
      ),

      Coffee(
        id: 'chemex',
        name: 'Chemex',
        description: 'Chemex ile hazırlanan filtre kahve',
        detailedDescription: 'Chemex cam kahve demleme cihazı ile hazırlanan, temiz ve berrak filtre kahve.',
        photoUrl: 'https://firebasestorage.googleapis.com/v0/b/coffink-app.appspot.com/o/coffees%2Fchemex.jpg?alt=media',
        basePrice: 42.0,
        sizes: {
          'medium': CoffeeSize(name: 'Orta', price: 42.0, ml: 300),
          'large': CoffeeSize(name: 'Büyük', price: 47.0, ml: 450),
        },
        ingredients: ['Premium filtre kahve çekirdeği', 'Sıcak su'],
        nutritionalInfo: NutritionalInfo(
          calories: 5,
          caffeine: 145,
          protein: 0.3,
        ),
        category: 'Filtre',
        isAvailable: true,
        preparationTime: 10,
      ),
    ];
  }

  /// Mevcut kahve verilerini temizler (dikkatli kullanın!)
  Future<void> clearExistingCoffeeData() async {
    Logger.warning('Clearing existing coffee data', name: 'RealCoffeeDataService');
    
    try {
      final snapshot = await _firestore.collection('coffees').get();
      
      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }
      
      Logger.info('Cleared ${snapshot.docs.length} existing coffee documents', name: 'RealCoffeeDataService');
    } catch (e) {
      Logger.error('Error clearing coffee data: $e', name: 'RealCoffeeDataService');
      rethrow;
    }
  }

  /// Kahve verilerini günceller (mevcut veriler varsa günceller, yoksa ekler)
  Future<void> updateCoffeeData() async {
    Logger.info('Updating coffee data', name: 'RealCoffeeDataService');
    
    try {
      final coffees = _getTurkishCoffeeData();
      
      for (final coffee in coffees) {
        await _firestore.collection('coffees').doc(coffee.id).set(
          coffee.toMap(),
          SetOptions(merge: true), // Mevcut veriyi koruyarak güncelle
        );
        Logger.info('Updated coffee: ${coffee.name}', name: 'RealCoffeeDataService');
      }
      
      Logger.info('Successfully updated ${coffees.length} Turkish coffees', name: 'RealCoffeeDataService');
    } catch (e) {
      Logger.error('Error updating coffee data: $e', name: 'RealCoffeeDataService');
      rethrow;
    }
  }
}