# Firebase SHA Fingerprint Kurulumu

## Adımlar:

1. Firebase Console'a gidin: https://console.firebase.google.com/project/coffee-app-mvp/settings/general/

2. "Your apps" bölümünde Android uygulamanızı bulun

3. "Add fingerprint" butonuna tıklayın

4. Bu fingerprint'leri ekleyin:
   - SHA-1: 05:5A:BC:8D:28:4F:A8:7B:9C:65:27:5C:8B:AB:88:65:F0:97:21:E0
   - SHA-256: 38:4E:5C:92:D5:CD:C9:02:B6:4E:A7:45:9F:F0:F5:79:89:5B:B5:79:2B:80:1B:5F:CB:A4:63:76:32:1D:D1:8D

5. Yeni google-services.json dosyasını indirin

6. android/app/google-services.json dosyasını yeni indirdiğinizle değiştirin

7. Uygulamayı yeniden çalıştırın: flutter clean && flutter run

## Kontrol:
- Package name: com.example.coffink ✓
- SHA-1 fingerprint: Eklenecek
- SHA-256 fingerprint: Eklenecek