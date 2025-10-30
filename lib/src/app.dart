
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'dart:developer' as developer;

import 'features/auth/services/auth_service.dart';
import 'features/profile/services/user_profile_service.dart';
import 'features/splash/screens/splash_screen.dart';
import 'features/home/services/favorites_service.dart';
import 'features/cart/services/cart_service.dart';
import 'features/cafe/services/cafe_service.dart';
import 'features/order/services/order_service.dart';
import 'services/location_service.dart';
import 'services/payment_service.dart';
import 'services/data_service.dart';
import 'features/review/services/review_service.dart';
import 'features/loyalty/services/loyalty_service.dart';
import 'theme/theme_service.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    try {
      developer.log('Building MyApp widget...', name: 'MyApp');
      
      return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeService()..initialize()),
          ChangeNotifierProvider(create: (_) => AuthService()),
          ChangeNotifierProvider(create: (_) => CartService()),
          ChangeNotifierProvider(create: (_) => LocationService()),
          Provider(create: (_) => DataService()),
          Provider(create: (_) => FavoritesService()),
          Provider(create: (_) => UserProfileService()),
          ProxyProvider<DataService, CafeService>(
            update: (context, dataService, _) => CafeService(dataService),
          ),
          Provider(create: (_) => OrderService()),
          Provider(create: (_) => PaymentService()),
          Provider(create: (_) => ReviewService()),
          Provider(create: (_) => LoyaltyService()),
        ],
        child: Consumer<ThemeService>(
          builder: (context, themeService, child) {
            return MaterialApp(
              title: 'Coffink',
              locale: const Locale('tr', 'TR'),
              supportedLocales: const [
                Locale('tr', 'TR'),
                Locale('en', 'US'),
              ],
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              theme: themeService.lightTheme,
              darkTheme: themeService.darkTheme,
              themeMode: themeService.themeMode,
              home: const SplashScreen(),
            );
          },
        ),
      );
    } catch (e, stackTrace) {
      developer.log('Error building MyApp: $e', name: 'MyApp', error: e, stackTrace: stackTrace);
      
      // Return a simple error screen
      return MaterialApp(
        title: 'Coffee App',
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text('App Error', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Error: $e', textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Try to restart the app
                    developer.log('Attempting to restart app...', name: 'MyApp');
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}
