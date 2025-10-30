import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import 'login_screen.dart';
import '../../home/screens/home_screen.dart';
import '../../../utils/logger.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    Logger.info('AuthWrapper build called', name: 'AuthWrapper');
    
    return Consumer<AuthService>(
      builder: (context, authService, _) {
        final user = authService.currentUser;
        
        Logger.info('AuthWrapper: User state - ${user != null ? "authenticated (${user.email})" : "not authenticated"}', 
                   name: 'AuthWrapper');
        
        if (user != null) {
          Logger.navigation('Navigating to HomeScreen for authenticated user', name: 'AuthWrapper');
          return const HomeScreen();
        } else {
          Logger.navigation('Navigating to LoginScreen for unauthenticated user', name: 'AuthWrapper');
          return const LoginScreen();
        }
      },
    );
  }
}