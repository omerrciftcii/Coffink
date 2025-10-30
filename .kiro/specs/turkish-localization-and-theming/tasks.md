# İmplementasyon Planı

- [x] 1. Yerelleştirme altyapısını kur ve yapılandır








  - Flutter intl paketini pubspec.yaml'a ekle ve yapılandır
  - l10n.yaml konfigürasyon dosyasını oluştur
  - ARB dosyalarını (app_tr.arb, app_en.arb) oluştur
  - _Gereksinimler: 1.1, 4.1, 4.2_

- [x] 1.1 Temel çeviri anahtarlarını tanımla



  - Ana navigasyon menüsü çevirilerini ekle (Ana Sayfa, Mağaza, QR, Harita, Profil)
  - Genel buton metinlerini çevir (Sepete Ekle, Sipariş Ver, İptal, Kaydet)
  - Hata mesajları ve bildirim metinlerini çevir
  - _Gereksinimler: 1.1, 1.2, 1.3_

- [x] 1.2 LocalizationService sınıfını implement et




  - Çeviri anahtarları yönetimi için service oluştur
  - Dinamik parametre desteği ekle
  - Eksik çeviri durumu için fallback mekanizması
  - _Gereksinimler: 4.3, 4.4_

- [x] 1.3 Tarih ve para formatlarını Türkçe'ye uyarla


  - Tarih formatını dd.MM.yyyy olarak ayarla
  - Saat formatını HH:mm olarak ayarla
  - Para birimi formatını "XX,XX ₺" olarak ayarla
  - _Gereksinimler: 1.5_

- [x] 2. Açık renk temasını implement et







  - CoffeeTheme sınıfını oluştur ve açık renk paletini tanımla
  - ThemeData'yı yeni renklerle yapılandır
  - Material Design 3 uyumluluğunu sağla
  - _Gereksinimler: 3.1, 3.4_

- [x] 2.1 ThemeService'i oluştur ve tema yönetimini ekle


  - Dinamik tema değiştirme fonksiyonalitesi
  - Karanlık/aydınlık mod desteği
  - Tema tercihlerini SharedPreferences'ta sakla
  - _Gereksinimler: 3.2, 3.3_

- [x] 2.2 Tüm widget'larda yeni tema renklerini uygula


  - AppBar, BottomNavigationBar, Card widget'larını güncelle
  - Button stillerini yeni tema ile uyumlu hale getir
  - Text stillerini açık tema için optimize et
  - _Gereksinimler: 3.1, 3.5_

- [-] 3. Gerçek kahve verilerini Firebase'e ekle






  - Türk kahve çeşitleri için veri modeli oluştur
  - Gerçek kahve isimlerini, açıklamalarını ve fiyatlarını ekle
  - Beslenme bilgilerini ve kalori değerlerini dahil et
  - _Gereksinimler: 2.1, 2.3_



- [-] 3.1 Gerçek kafe verilerini Firebase'e ekle

  - İstanbul'daki gerçek kafe lokasyonlarını ekle
  - Çalışma saatleri, iletişim bilgileri ve olanakları dahil et
  - Kafe fotoğraflarını Firebase Storage'a yükle
  - _Gereksinimler: 2.2_

- [x] 3.2 DataService'i gerçek verilerle entegre et







  - Mock veri yerine Firebase'den veri çekme
  - API çağrıları için error handling ekle
  - Retry mekanizması implement et
  - _Gereksinimler: 2.4, 5.5_

- [ ] 4. Cache ve performans optimizasyonu ekle
  - CacheService sınıfını oluştur
  - Resim lazy loading implement et
  - API response caching ekle
  - _Gereksinimler: 5.1, 5.2, 5.4_

- [ ] 4.1 Offline destek ekle
  - Cached verilerle offline çalışma
  - Internet bağlantısı kontrolü
  - Sync mekanizması implement et
  - _Gereksinimler: 5.3_

- [ ] 5. Mevcut ekranları Türkçe çevirilerle güncelle
  - Ana sayfa (HomeScreen) widget'larını çevir
  - Kahve listesi (CoffeeListScreen) metinlerini güncelle
  - Sepet (CartScreen) arayüzünü Türkçe'ye çevir
  - _Gereksinimler: 1.1, 1.2_

- [ ] 5.1 Profil ve ayarlar ekranlarını güncelle
  - Profil bilgileri etiketlerini çevir
  - Ayarlar menüsü öğelerini Türkçe'ye çevir
  - Hesap yönetimi metinlerini güncelle
  - _Gereksinimler: 1.1_

- [ ] 5.2 Sipariş ve ödeme akışını Türkçe'ye çevir
  - Sipariş özeti ekranını güncelle
  - Ödeme yöntemleri metinlerini çevir
  - Sipariş durumu bildirimlerini Türkçe'ye çevir
  - _Gereksinimler: 1.1, 1.4_

- [ ] 6. Kampanya ve sadakat sistemi verilerini güncelle
  - Aktif kampanya metinlerini Türkçe'ye çevir
  - Sadakat programı açıklamalarını güncelle
  - Puan kazanma kurallarını Türkçe olarak yaz
  - _Gereksinimler: 2.5_

- [ ]* 6.1 Çeviri sistemi için unit testler yaz
  - LocalizationService test senaryoları
  - Eksik çeviri durumu testleri
  - Parametre geçişi testleri
  - _Gereksinimler: 4.3_

- [ ]* 6.2 Tema sistemi için widget testleri yaz
  - Renk uygulaması testleri
  - Karanlık/aydınlık mod geçiş testleri
  - ThemeService fonksiyonalite testleri
  - _Gereksinimler: 3.2_

- [ ] 7. Veri entegrasyonu ve performans testleri
  - Gerçek veri yükleme hızı testleri
  - Cache mekanizması doğrulama
  - Offline mod fonksiyonalite testleri
  - _Gereksinimler: 5.1, 5.2, 5.3_

- [ ] 7.1 Son entegrasyon ve kalite kontrol
  - Tüm ekranların Türkçe çeviri kontrolü
  - Yeni tema renklerinin tutarlılık kontrolü
  - Gerçek veri akışının doğrulanması
  - _Gereksinimler: 1.1, 2.1, 3.1_