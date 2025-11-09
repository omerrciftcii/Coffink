

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import '../../auth/services/auth_service.dart';
import '../models/user_profile.dart';
import '../services/user_profile_service.dart';
import '../../survey/screens/taste_preference_survey.dart';
import '../../order/screens/order_history_screen.dart';
import '../../favorites/screens/favorites_screen.dart';
import '../../loyalty/screens/loyalty_points_screen.dart';
import '../../review/screens/user_reviews_screen.dart';
import 'edit_profile_screen.dart';
import 'addresses_screen.dart';
import 'payment_methods_screen.dart';
import 'notifications_screen.dart';
import 'help_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
     
      body: StreamBuilder<UserProfile?>(
        stream: UserProfileService().getCurrentUserProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Theme.of(context).colorScheme.error),
                  const SizedBox(height: 16),
                  Text('Hata: ${snapshot.error}'),
                ],
              ),
            );
          }

          final userProfile = snapshot.data;
          if (userProfile == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off, size: 64, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  const Text('Profil bulunamadı'),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(context, userProfile),
                const SizedBox(height: 24),
                _buildPointsCard(context, userProfile.coffeePoints),
                const SizedBox(height: 24),
                _buildQuickActionsCard(context),
                const SizedBox(height: 24),
                _buildMenuOptionsCard(context, userProfile),
                const SizedBox(height: 24),
                _buildTastePreferencesCard(context, userProfile.tastePreferences),
                const SizedBox(height: 24),
                _buildAccountInfoCard(context, userProfile),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserProfile profile) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                '${profile.firstName.isNotEmpty ? profile.firstName[0] : '?'}${profile.lastName.isNotEmpty ? profile.lastName[0] : ''}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.fullName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile.email,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  if (profile.phoneNumber.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      profile.phoneNumber,
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPointsCard(BuildContext context, int points) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LoyaltyPointsScreen(),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.star,
                  color: Theme.of(context).colorScheme.primary,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Coffi Puanları',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$points puan',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Her satın almada puan kazan!',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTastePreferencesCard(BuildContext context, Map<String, dynamic> preferences) {
    final hasPreferences = preferences.isNotEmpty;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Lezzet Tercihleri',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const TastePreferenceSurvey(),
                      ),
                    );
                  },
                  child: Text(hasPreferences ? 'Güncelle' : 'Tercihleri Ayarla'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (!hasPreferences) ...[
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.coffee_outlined,
                      size: 48,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Kişiselleştirilmiş kahve önerileri almak için\nlezzet tercihlerinizi ayarlayın',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                    ),
                  ],
                ),
              ),
            ] else ...[
              _buildPreferenceItem('Kahve Kuvveti', preferences['coffeeStrength']),
              _buildPreferenceItem('Süt Tercihi', preferences['milkPreference']),
              if (preferences['favoriteTypes'] != null && preferences['favoriteTypes'].isNotEmpty)
                _buildPreferenceList(context, 'Favori Türler', List<String>.from(preferences['favoriteTypes'])),
              if (preferences['flavorProfile'] != null && preferences['flavorProfile'].isNotEmpty)
                _buildPreferenceList(context, 'Favori Lezzetler', List<String>.from(preferences['flavorProfile'])),
              if (preferences['sweetness'] != null)
                _buildPreferenceItem('Tatlılık Seviyesi', _getSweetnessLabel(preferences['sweetness'])),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPreferenceItem(String label, dynamic value) {
    if (value == null) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value.toString()),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceList(BuildContext context, String label, List<String> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: items.map((item) => Chip(
              label: Text(
                item,
                style: const TextStyle(fontSize: 12),
              ),
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountInfoCard(BuildContext context, UserProfile profile) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hesap Bilgileri',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(context, Icons.email, 'E-posta', profile.email),
            if (profile.phoneNumber.isNotEmpty)
              _buildInfoRow(context, Icons.phone, 'Telefon', profile.phoneNumber),
            _buildInfoRow(
              context,
              Icons.calendar_today, 
              'Üyelik Tarihi',
              _formatDate(profile.createdAt),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _getSweetnessLabel(dynamic value) {
    if (value is! num) return 'Unknown';
    final level = value.round();
    switch (level) {
      case 1: return 'Şekersiz';
      case 2: return 'Az Tatlı';
      case 3: return 'Orta Tatlı';
      case 4: return 'Tatlı';
      case 5: return 'Çok Tatlı';
      default: return 'Bilinmeyen';
    }
  }

  Widget _buildQuickActionsCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hızlı Erişim',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionButton(
                    context,
                    Icons.history,
                    'Sipariş\nGeçmişi',
                    Theme.of(context).colorScheme.primary,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const OrderHistoryScreen(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionButton(
                    context,
                    Icons.favorite,
                    'Favoriler',
                    Theme.of(context).colorScheme.error,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FavoritesScreen(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionButton(
                    context,
                    Icons.stars,
                    'Puanlarım',
                    Theme.of(context).colorScheme.secondary,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoyaltyPointsScreen(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionButton(
                    context,
                    Icons.rate_review,
                    'Yorumlarım',
                    Colors.green,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UserReviewsScreen(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuOptionsCard(BuildContext context, UserProfile userProfile) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hesap Ayarları',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildMenuOption(
              context,
              Icons.person,
              'Profil Bilgileri',
              'Kişisel bilgilerinizi düzenleyin',
              () {
                // TODO: Navigate to profile edit screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfileScreen(profile: userProfile),
                  ),
                );
              },
            ),
            _buildMenuOption(
              context,
              Icons.location_on,
              'Adreslerim',
              'Teslimat adreslerinizi yönetin',
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddressesScreen(),
                  ),
                );
              },
            ),
            _buildMenuOption(
              context,
              Icons.payment,
              'Ödeme Yöntemleri',
              'Kayıtlı kartlarınızı yönetin',
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PaymentMethodsScreen(),
                  ),
                );
              },
            ),
            _buildMenuOption(
              context,
              Icons.notifications,
              'Bildirimler',
              'Bildirim tercihlerinizi ayarlayın',
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationsScreen(),
                  ),
                );
              },
            ),
            _buildMenuOption(
              context,
              Icons.help,
              'Yardım & Destek',
              'SSS ve iletişim bilgileri',
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HelpScreen(),
                  ),
                );
              },
            ),
            // Debug option for testing Crashlytics (only visible in debug mode)
            if (const bool.fromEnvironment('dart.vm.product') == false) ...[
              _buildMenuOption(
                context,
                Icons.bug_report,
                'Test Crash (Debug)',
                'Crashlytics test için kaza simülasyonu',
                () => _testCrashlytics(context),
                isDestructive: true,
              ),
            ],
            const Divider(height: 32),
            _buildMenuOption(
              context,
              Icons.logout,
              'Çıkış Yap',
              'Hesabınızdan güvenli şekilde çıkış yapın',
              () => _showLogoutDialog(context),
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuOption(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    final color = isDestructive ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDestructive ? color : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Çıkış Yap'),
          content: const Text('Hesabınızdan çıkış yapmak istediğinizden emin misiniz?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
              child: const Text('Çıkış Yap'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        final authService = context.read<AuthService>();
        await authService.signOut();
        
        if (context.mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/welcome',
            (route) => false,
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Çıkış yapılırken hata oluştu: ${e.toString()}'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _testCrashlytics(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Test Crashlytics'),
          content: const Text(
            'Bu özellik Crashlytics\'ı test etmek içindir. '
            'Uygulamada kasitli bir hata oluşturacak ve Firebase Crashlytics\'ına rapor gönderecek.\n\n'
            'Devam etmek istediginizden emin misiniz?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
              child: const Text('Test Et'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        // Test non-fatal error first
        FirebaseCrashlytics.instance.recordError(
          'Test non-fatal error from Profile Screen',
          StackTrace.current,
          fatal: false,
          information: [
            DiagnosticsProperty('user_action', 'test_crashlytics'),
            DiagnosticsProperty('screen', 'profile_screen'),
            DiagnosticsProperty('timestamp', DateTime.now().toIso8601String()),
          ],
        );

        // Show success message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Test hatası Crashlytics\'ına gönderildi!'),
              backgroundColor: Theme.of(context).colorScheme.secondary,
            ),
          );
        }

        // Wait a bit then test a fatal crash
        await Future.delayed(const Duration(seconds: 2));
        
        // This will cause a fatal crash
        throw Exception('Test crash from Profile Screen - This is intentional for testing Firebase Crashlytics');
      } catch (e, stackTrace) {
        // Report to Crashlytics
        FirebaseCrashlytics.instance.recordError(
          e,
          stackTrace,
          fatal: true,
          information: [
            DiagnosticsProperty('user_action', 'test_fatal_crash'),
            DiagnosticsProperty('screen', 'profile_screen'),
            DiagnosticsProperty('timestamp', DateTime.now().toIso8601String()),
          ],
        );
        
        // In a real app, you might want to handle this more gracefully
        rethrow;
      }
    }
  }
}
