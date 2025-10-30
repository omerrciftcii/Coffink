# Tasarım Dokümanı

## Genel Bakış

Bu tasarım dokümanı, mevcut Coffink Flutter uygulamasının Türkçe yerelleştirmesi, gerçek veri entegrasyonu ve yeni renk teması uygulaması için teknik yaklaşımı tanımlar. Uygulama şu anda Firebase altyapısı ile çalışmakta ve Provider state management kullanmaktadır.

## Mimari

### Mevcut Mimari Analizi

Uygulama şu anda şu yapıya sahip:
- **Frontend**: Flutter (Dart) - Material Design
- **Backend**: Firebase (Firestore, Auth, Storage)
- **State Management**: Provider Pattern
- **Navigation**: Standart Flutter Navigation
- **Localization**: Temel flutter_localizations desteği

### Hedef Mimari

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                        │
├─────────────────────────────────────────────────────────────┤
│  Screens & Widgets (Turkish Localized)                     │
│  ├── Home Screen (Ana Sayfa)                               │
│  ├── Coffee List (Kahve Listesi)                           │
│  ├── Cafe Map (Kafe Haritası)                              │
│  ├── Cart (Sepet)                                          │
│  └── Profile (Profil)                                      │
├─────────────────────────────────────────────────────────────┤
│                    Business Logic Layer                      │
├─────────────────────────────────────────────────────────────┤
│  Services & Providers                                       │
│  ├── LocalizationService (Çeviri Yönetimi)                 │
│  ├── ThemeService (Tema Yönetimi)                          │
│  ├── DataService (Gerçek Veri Yönetimi)                    │
│  └── CacheService (Önbellek Yönetimi)                      │
├─────────────────────────────────────────────────────────────┤
│                    Data Layer                               │
├─────────────────────────────────────────────────────────────┤
│  Firebase Integration                                       │
│  ├── Firestore (Gerçek Veri)                              │
│  ├── Storage (Resimler)                                    │
│  └── Auth (Kimlik Doğrulama)                              │
└─────────────────────────────────────────────────────────────┘
```

## Bileşenler ve Arayüzler

### 1. Yerelleştirme Sistemi

#### LocalizationService
```dart
class LocalizationService {
  static const supportedLocales = [
    Locale('tr', 'TR'),
    Locale('en', 'US'),
  ];
  
  // Çeviri anahtarları yönetimi
  String translate(String key, {Map<String, dynamic>? params});
  
  // Dinamik çeviri yükleme
  Future<void> loadTranslations(String locale);
  
  // Tarih/saat formatları
  String formatDate(DateTime date);
  String formatTime(DateTime time);
  String formatCurrency(double amount);
}
```

#### Çeviri Dosya Yapısı
```
lib/
├── l10n/
│   ├── app_tr.arb (Türkçe çeviriler)
│   ├── app_en.arb (İngilizce çeviriler)
│   └── l10n.dart (Generated)
```

### 2. Tema Sistemi

#### Yeni Renk Paleti (Ekran Görüntüsü Temalı)
```dart
class CoffeeTheme {
  // Ana Renkler (Açık ve Modern)
  static const Color primaryBeige = Color(0xFFF5F1EB);      // Açık bej (arka plan)
  static const Color softBrown = Color(0xFFE8DDD4);         // Yumuşak kahverengi
  static const Color lightCream = Color(0xFFFFFBF7);        // Açık krem
  
  // Accent Renkler
  static const Color warmPeach = Color(0xFFFFE5D1);         // Sıcak şeftali
  static const Color pureWhite = Color(0xFFFFFFFF);         // Saf beyaz
  static const Color softGray = Color(0xFFF8F6F4);          // Yumuşak gri
  
  // Text ve Icon Renkleri
  static const Color darkText = Color(0xFF2C2C2C);          // Koyu metin
  static const Color mediumText = Color(0xFF6B6B6B);        // Orta ton metin
  static const Color lightText = Color(0xFF9E9E9E);         // Açık metin
  
  // Button ve Vurgu Renkleri
  static const Color accentOrange = Color(0xFFFF8A65);      // Vurgu turuncu
  static const Color buttonBrown = Color(0xFFD7CCC8);       // Buton kahverengi
  
  // Sistem Renkleri
  static const Color success = Color(0xFF81C784);
  static const Color warning = Color(0xFFFFB74D);
  static const Color error = Color(0xFFE57373);
  static const Color info = Color(0xFF64B5F6);
}
```

#### ThemeService
```dart
class ThemeService extends ChangeNotifier {
  ThemeData get lightTheme;
  ThemeData get darkTheme;
  
  void toggleTheme();
  void setTheme(ThemeMode mode);
  
  // Dinamik renk güncellemeleri
  void updatePrimaryColor(Color color);
  void resetToDefault();
}
```

### 3. Gerçek Veri Yönetimi

#### DataService Yapısı
```dart
class DataService {
  // Kahve verileri
  Future<List<Coffee>> getCoffees({String? category});
  Future<Coffee> getCoffeeById(String id);
  
  // Kafe verileri
  Future<List<Cafe>> getCafes({LatLng? userLocation});
  Future<Cafe> getCafeById(String id);
  
  // Kampanya verileri
  Future<List<Campaign>> getActiveCampaigns();
  
  // Cache yönetimi
  Future<void> cacheData(String key, dynamic data);
  Future<T?> getCachedData<T>(String key);
}
```

#### Veri Modelleri
```dart
class Coffee {
  final String id;
  final String name;
  final String description;
  final String detailedDescription;
  final String photoUrl;
  final double basePrice;
  final String category;
  final bool isAvailable;
  final int preparationTime;
  final List<String> ingredients;
  final Map<String, CoffeeSize> sizes;
  final NutritionInfo nutritionInfo;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class Cafe {
  final String id;
  final String name;
  final String description;
  final Address address;
  final LatLng location;
  final String photoUrl;
  final double rating;
  final int reviewCount;
  final List<String> amenities;
  final bool isPartner;
  final OperatingHours operatingHours;
  final ContactInfo contactInfo;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### 4. Performans Optimizasyonu

#### CacheService
```dart
class CacheService {
  // Resim önbellekleme
  Future<void> preloadImages(List<String> urls);
  
  // Veri önbellekleme
  Future<void> cacheApiResponse(String endpoint, dynamic data);
  Future<T?> getCachedResponse<T>(String endpoint);
  
  // Offline destek
  Future<void> enableOfflineMode();
  Future<List<T>> getOfflineData<T>(String collection);
}
```

## Veri Modelleri

### Türkçe İçerik Modeli
```dart
class TurkishContent {
  final String key;
  final String turkish;
  final String english;
  final String? description;
  final Map<String, String>? parameters;
  
  const TurkishContent({
    required this.key,
    required this.turkish,
    required this.english,
    this.description,
    this.parameters,
  });
}
```

### Gerçek Kahve Verisi
```dart
class RealCoffeeData {
  // Türk kahve çeşitleri
  static const List<Coffee> turkishCoffees = [
    Coffee(
      name: 'Türk Kahvesi',
      description: 'Geleneksel Türk kahvesi, UNESCO kültürel mirası',
      price: 35.0,
      category: 'Geleneksel',
      ingredients: ['Türk kahvesi', 'Su', 'Şeker (isteğe bağlı)'],
      preparationTime: 8,
      calories: 5,
    ),
    Coffee(
      name: 'Espresso',
      description: 'Yoğun ve kremli İtalyan espresso',
      price: 25.0,
      category: 'Espresso',
      ingredients: ['Espresso çekirdeği'],
      preparationTime: 3,
      calories: 9,
    ),
    // ... daha fazla gerçek kahve verisi
  ];
}
```

### Gerçek Kafe Verisi
```dart
class RealCafeData {
  // İstanbul'daki gerçek kafeler
  static const List<Cafe> istanbulCafes = [
    Cafe(
      name: 'Starbucks Taksim',
      address: 'İstiklal Caddesi No:123, Beyoğlu/İstanbul',
      location: LatLng(41.0369, 28.9852),
      rating: 4.2,
      reviewCount: 1250,
      amenities: ['WiFi', 'Klima', 'Kart Ödeme', 'Takeaway'],
      operatingHours: {
        'pazartesi': '07:00-23:00',
        'salı': '07:00-23:00',
        // ... diğer günler
      },
    ),
    // ... daha fazla gerçek kafe verisi
  ];
}
```

## Hata Yönetimi

### Çeviri Hata Yönetimi
```dart
class TranslationErrorHandler {
  static String handleMissingTranslation(String key) {
    // Eksik çeviri durumunda varsayılan davranış
    Logger.warning('Missing translation for key: $key');
    return key; // Anahtar kendisini döndür
  }
  
  static void logTranslationError(String key, String error) {
    // Çeviri hatalarını logla
    FirebaseCrashlytics.instance.recordError(error, null);
  }
}
```

### Veri Yükleme Hata Yönetimi
```dart
class DataErrorHandler {
  static Future<T> handleApiCall<T>(Future<T> Function() apiCall) async {
    try {
      return await apiCall();
    } on FirebaseException catch (e) {
      Logger.error('Firebase error: ${e.message}');
      throw DataException('Veri yüklenirken hata oluştu');
    } catch (e) {
      Logger.error('Unexpected error: $e');
      throw DataException('Beklenmeyen hata oluştu');
    }
  }
}
```

## Test Stratejisi

### Unit Tests
```dart
// Çeviri testleri
group('LocalizationService Tests', () {
  test('should return Turkish translation for valid key', () {
    final result = LocalizationService.translate('home.title');
    expect(result, equals('Ana Sayfa'));
  });
  
  test('should return key when translation missing', () {
    final result = LocalizationService.translate('missing.key');
    expect(result, equals('missing.key'));
  });
});

// Tema testleri
group('ThemeService Tests', () {
  test('should apply coffee theme colors', () {
    final theme = ThemeService().lightTheme;
    expect(theme.primaryColor, equals(CoffeeTheme.primaryBrown));
  });
});
```

### Widget Tests
```dart
group('Coffee Card Widget Tests', () {
  testWidgets('should display Turkish coffee name', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CoffeeCard(
          coffee: Coffee(name: 'Türk Kahvesi', price: 35.0),
        ),
      ),
    );
    
    expect(find.text('Türk Kahvesi'), findsOneWidget);
    expect(find.text('35,00 ₺'), findsOneWidget);
  });
});
```

### Integration Tests
```dart
group('End-to-End Tests', () {
  testWidgets('complete coffee ordering flow in Turkish', (tester) async {
    // Ana sayfayı aç
    await tester.pumpWidget(MyApp());
    await tester.pumpAndSettle();
    
    // Kahve seç
    await tester.tap(find.text('Türk Kahvesi'));
    await tester.pumpAndSettle();
    
    // Sepete ekle
    await tester.tap(find.text('Sepete Ekle'));
    await tester.pumpAndSettle();
    
    // Sipariş ver
    await tester.tap(find.text('Sipariş Ver'));
    await tester.pumpAndSettle();
    
    // Başarı mesajını kontrol et
    expect(find.text('Siparişiniz alındı'), findsOneWidget);
  });
});
```

## Implementasyon Aşamaları

### Aşama 1: Yerelleştirme Altyapısı
1. Flutter intl paketini yapılandır
2. ARB dosyalarını oluştur
3. LocalizationService'i implement et
4. Mevcut hardcoded metinleri çevir

### Aşama 2: Tema Sistemi
1. Yeni renk paletini tanımla
2. ThemeService'i oluştur
3. Tüm widget'larda tema renklerini uygula
4. Karanlık/aydınlık mod desteği ekle

### Aşama 3: Gerçek Veri Entegrasyonu
1. Firebase koleksiyonlarını güncelle
2. Gerçek kahve ve kafe verilerini ekle
3. Cache mekanizmasını implement et
4. Offline destek ekle

### Aşama 4: Performans Optimizasyonu
1. Resim lazy loading
2. API response caching
3. Progressive loading
4. Error boundary'ler

## Güvenlik Konuları

### Veri Güvenliği
- Firebase Security Rules güncelleme
- API anahtarlarının güvenli saklanması
- Kullanıcı verilerinin şifrelenmesi

### Çeviri Güvenliği
- XSS saldırılarına karşı koruma
- Input validation
- Sanitization

## Performans Metrikleri

### Hedef Performans
- Uygulama açılış süresi: < 3 saniye
- Sayfa geçiş süresi: < 1 saniye
- API yanıt süresi: < 500ms
- Çeviri yükleme süresi: < 200ms

### Monitoring
- Firebase Performance Monitoring
- Crashlytics entegrasyonu
- Custom analytics events