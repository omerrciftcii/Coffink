
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'dart:ui';
import 'dart:developer' as developer;

import 'firebase_options.dart';
import 'src/app.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    
    developer.log('Initializing Firebase...', name: 'main');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    developer.log('Firebase initialized successfully', name: 'main');
    
    // Initialize Crashlytics
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };
    
    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
    
    developer.log('Crashlytics initialized successfully', name: 'main');
    
    runApp(const MyApp());
  } catch (e, stackTrace) {
    developer.log('Error in main: $e', name: 'main', error: e, stackTrace: stackTrace);
    
    // Report to Crashlytics if it's available
    try {
      FirebaseCrashlytics.instance.recordError(e, stackTrace, fatal: true);
    } catch (_) {
      // Crashlytics not available, continue
    }
    
    // Still try to run the app without Firebase if needed
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Error initializing app'),
              const SizedBox(height: 8),
              Text('Error: $e'),
            ],
          ),
        ),
      ),
    ));
  }
}
