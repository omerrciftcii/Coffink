import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../utils/logger.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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

  Future<void> verifyPhoneNumber(String phoneNumber, BuildContext context, Function(String) codeSent) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? 'Verification failed'),
          ),
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        codeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  Future<void> signInWithOtp(String verificationId, String smsCode) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    await _auth.signInWithCredential(credential);
  }

  Future<void> saveUserDetails(String name, String surname, String email) async {
    if (_user != null) {
      await _firestore.collection('users').doc(_user!.uid).set({
        'name': name,
        'surname': surname,
        'email': email,
        'phoneNumber': _user!.phoneNumber,
      });
    }
  }
}