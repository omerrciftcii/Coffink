import 'package:coffink/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Service for managing localization and translations
class LocalizationService {
  static LocalizationService? _instance;
  static LocalizationService get instance => _instance ??= LocalizationService._();
  
  LocalizationService._();
  
  AppLocalizations? _localizations;
  
  /// Initialize the service with the current context
  void initialize(BuildContext context) {
    _localizations = AppLocalizations.of(context);
  }
  
  /// Get the current localizations instance
  AppLocalizations get localizations {
    if (_localizations == null) {
      throw Exception('LocalizationService not initialized. Call initialize() first.');
    }
    return _localizations!;
  }
  
  /// Get translated text by key with optional parameters
  String getText(String key, {Map<String, dynamic>? params}) {
    try {
      final localizations = this.localizations;
      
      // Use reflection-like approach to get the translation
      // This is a simplified version - in a real app you might want to use
      // a more sophisticated approach or code generation
      String text = _getTranslationByKey(localizations, key);
      
      // Replace parameters if provided
      if (params != null) {
        params.forEach((paramKey, value) {
          text = text.replaceAll('{$paramKey}', value.toString());
        });
      }
      
      return text;
    } catch (e) {
      // Fallback mechanism - return the key if translation fails
      return _getFallbackText(key);
    }
  }
  
  /// Get translation by key using a mapping approach
  String _getTranslationByKey(AppLocalizations localizations, String key) {
    // This is a simplified mapping - in a real implementation,
    // you might want to use code generation or a more dynamic approach
    switch (key) {
      // Navigation
      case 'nav_home': return localizations.nav_home;
      case 'nav_store': return localizations.nav_store;
      case 'nav_qr': return localizations.nav_qr;
      case 'nav_map': return localizations.nav_map;
      case 'nav_profile': return localizations.nav_profile;
      
      // Buttons
      case 'btn_add_to_cart': return localizations.btn_add_to_cart;
      case 'btn_order': return localizations.btn_order;
      case 'btn_cancel': return localizations.btn_cancel;
      case 'btn_save': return localizations.btn_save;
      case 'btn_continue': return localizations.btn_continue;
      case 'btn_back': return localizations.btn_back;
      case 'btn_confirm': return localizations.btn_confirm;
      case 'btn_retry': return localizations.btn_retry;
      case 'btn_close': return localizations.btn_close;
      case 'btn_edit': return localizations.btn_edit;
      case 'btn_delete': return localizations.btn_delete;
      case 'btn_view_all': return localizations.btn_view_all;
      case 'btn_apply': return localizations.btn_apply;
      case 'btn_remove': return localizations.btn_remove;
      
      // Errors
      case 'error_network': return localizations.error_network;
      case 'error_server': return localizations.error_server;
      case 'error_unknown': return localizations.error_unknown;
      case 'error_validation': return localizations.error_validation;
      case 'error_auth': return localizations.error_auth;
      case 'error_permission': return localizations.error_permission;
      case 'error_location': return localizations.error_location;
      case 'error_camera': return localizations.error_camera;
      case 'error_storage': return localizations.error_storage;
      
      // Notifications
      case 'notif_order_placed': return localizations.notif_order_placed;
      case 'notif_order_confirmed': return localizations.notif_order_confirmed;
      case 'notif_order_preparing': return localizations.notif_order_preparing;
      case 'notif_order_ready': return localizations.notif_order_ready;
      case 'notif_order_delivered': return localizations.notif_order_delivered;
      case 'notif_order_cancelled': return localizations.notif_order_cancelled;
      case 'notif_item_added': return localizations.notif_item_added;
      case 'notif_item_removed': return localizations.notif_item_removed;
      case 'notif_profile_updated': return localizations.notif_profile_updated;
      case 'notif_payment_success': return localizations.notif_payment_success;
      case 'notif_payment_failed': return localizations.notif_payment_failed;
      
      // General
      case 'loading': return localizations.loading;
      case 'please_wait': return localizations.please_wait;
      case 'no_data': return localizations.no_data;
      case 'try_again': return localizations.try_again;
      case 'search': return localizations.search;
      case 'filter': return localizations.filter;
      case 'sort': return localizations.sort;
      case 'refresh': return localizations.refresh;
      case 'settings': return localizations.settings;
      case 'help': return localizations.help;
      case 'about': return localizations.about;
      case 'contact': return localizations.contact;
      case 'privacy': return localizations.privacy;
      case 'terms': return localizations.terms;
      
      default:
        throw Exception('Translation key not found: $key');
    }
  }
  
  /// Fallback mechanism for missing translations
  String _getFallbackText(String key) {
    // Return a user-friendly fallback or the key itself
    return key.replaceAll('_', ' ').split(' ').map((word) => 
      word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : word
    ).join(' ');
  }
  
  /// Check if the current locale is Turkish
  bool get isTurkish => _localizations?.localeName == 'tr';
  
  /// Check if the current locale is English
  bool get isEnglish => _localizations?.localeName == 'en';
  
  /// Get the current locale
  String get currentLocale => _localizations?.localeName ?? 'en';
}