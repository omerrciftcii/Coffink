import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../utils/logger.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  AuthService() {
    Logger.info('AuthService initialized', name: 'AuthService');
    
    _auth.authStateChanges().listen((user) {
      final previousUser = _user;
      _user = user;
      
      if (previousUser == null && user != null) {
        Logger.authAction('User signed in: ${user.email}', name: 'AuthService');
      } else if (previousUser != null && user == null) {
        Logger.authAction('User signed out', name: 'AuthService');
      }
      
      notifyListeners();
    });
  }

  User? get currentUser => _user;

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    Logger.logMethodCall('AuthService', 'signInWithEmailAndPassword', 
                        parameters: {'email': email});
    
    try {
      Logger.authAction('Attempting email/password sign in', name: 'AuthService');
      
      await Logger.timeOperation(
        'Email/Password Sign In',
        () => _auth.signInWithEmailAndPassword(email: email, password: password),
        name: 'AuthService',
      );
      
      Logger.authAction('Sign in successful for: $email', name: 'AuthService');
    } catch (e) {
      Logger.authAction('Sign in failed for: $email', name: 'AuthService', error: e);
      rethrow;
    }
  }

  Future<UserCredential?> createUserWithEmailAndPassword(String email, String password) async {
    Logger.logMethodCall('AuthService', 'createUserWithEmailAndPassword', 
                        parameters: {'email': email});
    
    try {
      Logger.authAction('Attempting user registration', name: 'AuthService');
      
      final result = await Logger.timeOperation(
        'User Registration',
        () => _auth.createUserWithEmailAndPassword(email: email, password: password),
        name: 'AuthService',
      );
      
      Logger.authAction('Registration successful for: $email', name: 'AuthService');
      return result;
    } catch (e) {
      Logger.authAction('Registration failed for: $email', name: 'AuthService', error: e);
      rethrow;
    }
  }

  Future<void> signOut() async {
    Logger.logMethodCall('AuthService', 'signOut');
    
    try {
      Logger.authAction('Attempting sign out', name: 'AuthService');
      
      await Logger.timeOperation(
        'Sign Out',
        () => _auth.signOut(),
        name: 'AuthService',
      );
      
      Logger.authAction('Sign out completed', name: 'AuthService');
    } catch (e) {
      Logger.authAction('Sign out failed', name: 'AuthService', error: e);
      rethrow;
    }
  }
}