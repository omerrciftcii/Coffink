import '../services/data_initialization_service.dart';
import '../services/enhanced_data_service.dart';
import 'logger.dart';

/// Firebase veri yönetimi için admin utility sınıfı
class DataAdminUtility {
  final DataInitializationService _initService = DataInitializationService();
  final EnhancedDataService _dataService = EnhancedDataService();

  DataAdminUtility() {
    Logger.info('DataAdminUtility initialized', name: 'DataAdminUtility');
  }

  /// Gerçek Türk kahve verilerini Firebase'e yükler
  /// 
  /// Bu method şunları yapar:
  /// 1. Mevcut kahve verilerini temizler (opsiyonel)
  /// 2. Gerçek Türk kahve çeşitlerini ekler
  /// 3. İstanbul'daki gerçek kafe verilerini ekler
  /// 4. Veri yükleme durumunu raporlar
  Future<void> setupRealTurkishCoffeeData({bool clearExisting = false}) async {
    Logger.info('Setting up real Turkish coffee data', name: 'DataAdminUtility');
    
    try {
      // Bağlantıyı kontrol et
      final isConnected = await _dataService.checkConnectivity();
      if (!isConnected) {
        throw Exception('Firebase bağlantısı kurulamadı');
      }

      Logger.info('Firebase bağlantısı başarılı', name: 'DataAdminUtility');

      // Tüm verileri başlat
      await _initService.initializeAllData(clearExisting: clearExisting);

      // Veri durumunu kontrol et
      final status = await _initService.checkDataStatus();
      Logger.info('Veri durumu: ${status['status']}', name: 'DataAdminUtility');

      // Yüklenen veri sayılarını raporla
      await _reportDataCounts();

      Logger.info('Gerçek Türk kahve verileri başarıyla yüklendi!', name: 'DataAdminUtility');
      
    } catch (e) {
      Logger.error('Veri yükleme hatası: $e', name: 'DataAdminUtility');
      rethrow;
    }
  }

  /// Sadece kahve verilerini günceller
  Future<void> updateCoffeeDataOnly({bool clearExisting = false}) async {
    Logger.info('Updating coffee data only', name: 'DataAdminUtility');
    
    try {
      await _initService.initializeCoffeeData(clearExisting: clearExisting);
      
      final coffees = await _dataService.getCoffees();
      Logger.info('Güncellenen kahve sayısı: ${coffees.length}', name: 'DataAdminUtility');
      
      // Kategorilere göre dağılımı göster
      final categories = <String, int>{};
      for (final coffee in coffees) {
        categories[coffee.category] = (categories[coffee.category] ?? 0) + 1;
      }
      
      Logger.info('Kategori dağılımı: $categories', name: 'DataAdminUtility');
      
    } catch (e) {
      Logger.error('Kahve verisi güncelleme hatası: $e', name: 'DataAdminUtility');
      rethrow;
    }
  }

  /// Sadece kafe verilerini günceller
  Future<void> updateCafeDataOnly({bool clearExisting = false}) async {
    Logger.info('Updating cafe data only', name: 'DataAdminUtility');
    
    try {
      await _initService.initializeCafeData(clearExisting: clearExisting);
      
      final cafes = await _dataService.getCafes();
      Logger.info('Güncellenen kafe sayısı: ${cafes.length}', name: 'DataAdminUtility');
      
      // Partner kafe sayısını göster
      final partnerCafes = cafes.where((cafe) => cafe.isPartner).length;
      Logger.info('Partner kafe sayısı: $partnerCafes', name: 'DataAdminUtility');
      
    } catch (e) {
      Logger.error('Kafe verisi güncelleme hatası: $e', name: 'DataAdminUtility');
      rethrow;
    }
  }

  /// Mevcut veri durumunu raporlar
  Future<void> reportCurrentDataStatus() async {
    Logger.info('Mevcut veri durumu raporu', name: 'DataAdminUtility');
    
    try {
      await _reportDataCounts();
      
      // Bağlantı durumu
      final isConnected = await _dataService.checkConnectivity();
      Logger.info('Firebase bağlantı durumu: ${isConnected ? "Bağlı" : "Bağlantı yok"}', 
                 name: 'DataAdminUtility');
      
      // Veri kalitesi kontrolü
      await _performDataQualityCheck();
      
    } catch (e) {
      Logger.error('Veri durumu raporu hatası: $e', name: 'DataAdminUtility');
      rethrow;
    }
  }

  /// Veri sayılarını raporlar
  Future<void> _reportDataCounts() async {
    try {
      // Kahve sayıları
      final coffees = await _dataService.getCoffees();
      Logger.info('Toplam kahve sayısı: ${coffees.length}', name: 'DataAdminUtility');
      
      final availableCoffees = coffees.where((c) => c.isAvailable).length;
      Logger.info('Mevcut kahve sayısı: $availableCoffees', name: 'DataAdminUtility');
      
      // Kafe sayıları
      final cafes = await _dataService.getCafes();
      Logger.info('Toplam kafe sayısı: ${cafes.length}', name: 'DataAdminUtility');
      
      final partnerCafes = cafes.where((c) => c.isPartner).length;
      Logger.info('Partner kafe sayısı: $partnerCafes', name: 'DataAdminUtility');
      
    } catch (e) {
      Logger.warning('Veri sayıları alınamadı: $e', name: 'DataAdminUtility');
    }
  }

  /// Veri kalitesi kontrolü yapar
  Future<void> _performDataQualityCheck() async {
    Logger.info('Veri kalitesi kontrolü başlatılıyor', name: 'DataAdminUtility');
    
    try {
      final coffees = await _dataService.getCoffees();
      final cafes = await _dataService.getCafes();
      
      // Kahve veri kalitesi kontrolü
      int coffeeIssues = 0;
      for (final coffee in coffees) {
        if (coffee.name.isEmpty) coffeeIssues++;
        if (coffee.description.isEmpty) coffeeIssues++;
        if (coffee.basePrice <= 0) coffeeIssues++;
        if (coffee.sizes.isEmpty) coffeeIssues++;
      }
      
      // Kafe veri kalitesi kontrolü
      int cafeIssues = 0;
      for (final cafe in cafes) {
        if (cafe.name.isEmpty) cafeIssues++;
        if (cafe.address.isEmpty) cafeIssues++;
        if (cafe.latitude == 0 || cafe.longitude == 0) cafeIssues++;
      }
      
      Logger.info('Kahve veri kalitesi sorunları: $coffeeIssues', name: 'DataAdminUtility');
      Logger.info('Kafe veri kalitesi sorunları: $cafeIssues', name: 'DataAdminUtility');
      
      if (coffeeIssues == 0 && cafeIssues == 0) {
        Logger.info('✅ Veri kalitesi kontrolü başarılı - sorun bulunamadı', name: 'DataAdminUtility');
      } else {
        Logger.warning('⚠️ Veri kalitesi sorunları tespit edildi', name: 'DataAdminUtility');
      }
      
    } catch (e) {
      Logger.error('Veri kalitesi kontrolü hatası: $e', name: 'DataAdminUtility');
    }
  }

  /// Test verilerini temizler ve gerçek verileri yükler
  Future<void> replaceTestDataWithRealData() async {
    Logger.warning('Test verileri gerçek verilerle değiştiriliyor', name: 'DataAdminUtility');
    
    try {
      // Önce mevcut verileri temizle
      Logger.info('Mevcut test verileri temizleniyor...', name: 'DataAdminUtility');
      await _initService.clearAllData();
      
      // Gerçek verileri yükle
      Logger.info('Gerçek veriler yükleniyor...', name: 'DataAdminUtility');
      await _initService.initializeAllData();
      
      // Sonuçları raporla
      await _reportDataCounts();
      
      Logger.info('✅ Test verileri başarıyla gerçek verilerle değiştirildi', name: 'DataAdminUtility');
      
    } catch (e) {
      Logger.error('Veri değiştirme hatası: $e', name: 'DataAdminUtility');
      rethrow;
    }
  }

  /// Belirli kategorideki kahveleri listeler
  Future<void> listCoffeesByCategory(String category) async {
    Logger.info('$category kategorisindeki kahveler listeleniyor', name: 'DataAdminUtility');
    
    try {
      final coffees = await _dataService.getCoffeesByCategory(category);
      
      Logger.info('$category kategorisinde ${coffees.length} kahve bulundu:', name: 'DataAdminUtility');
      
      for (final coffee in coffees) {
        Logger.info('- ${coffee.name}: ${coffee.basePrice} ₺', name: 'DataAdminUtility');
      }
      
    } catch (e) {
      Logger.error('Kategori listeleme hatası: $e', name: 'DataAdminUtility');
      rethrow;
    }
  }

  /// Partner kafeleri listeler
  Future<void> listPartnerCafes() async {
    Logger.info('Partner kafeler listeleniyor', name: 'DataAdminUtility');
    
    try {
      final partnerCafes = await _dataService.getPartnerCafes();
      
      Logger.info('${partnerCafes.length} partner kafe bulundu:', name: 'DataAdminUtility');
      
      for (final cafe in partnerCafes) {
        Logger.info('- ${cafe.name}: ${cafe.address}', name: 'DataAdminUtility');
      }
      
    } catch (e) {
      Logger.error('Partner kafe listeleme hatası: $e', name: 'DataAdminUtility');
      rethrow;
    }
  }
}