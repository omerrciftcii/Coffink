import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// Navigation Menu - Home
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get nav_home;

  /// No description provided for @nav_store.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get nav_store;

  /// No description provided for @nav_qr.
  ///
  /// In en, this message translates to:
  /// **'QR'**
  String get nav_qr;

  /// No description provided for @nav_map.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get nav_map;

  /// No description provided for @nav_profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get nav_profile;

  /// General Buttons
  ///
  /// In en, this message translates to:
  /// **'Add to Cart'**
  String get btn_add_to_cart;

  /// No description provided for @btn_order.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get btn_order;

  /// No description provided for @btn_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get btn_cancel;

  /// No description provided for @btn_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get btn_save;

  /// No description provided for @btn_continue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get btn_continue;

  /// No description provided for @btn_back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get btn_back;

  /// No description provided for @btn_confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get btn_confirm;

  /// No description provided for @btn_retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get btn_retry;

  /// No description provided for @btn_close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get btn_close;

  /// No description provided for @btn_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get btn_edit;

  /// No description provided for @btn_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get btn_delete;

  /// No description provided for @btn_view_all.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get btn_view_all;

  /// No description provided for @btn_apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get btn_apply;

  /// No description provided for @btn_remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get btn_remove;

  /// Error Messages
  ///
  /// In en, this message translates to:
  /// **'Network connection error. Please check your internet connection.'**
  String get error_network;

  /// No description provided for @error_server.
  ///
  /// In en, this message translates to:
  /// **'Server error occurred. Please try again later.'**
  String get error_server;

  /// No description provided for @error_unknown.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred.'**
  String get error_unknown;

  /// No description provided for @error_validation.
  ///
  /// In en, this message translates to:
  /// **'Please check the entered information.'**
  String get error_validation;

  /// No description provided for @error_auth.
  ///
  /// In en, this message translates to:
  /// **'Authentication failed. Please try again.'**
  String get error_auth;

  /// No description provided for @error_permission.
  ///
  /// In en, this message translates to:
  /// **'Permission required to continue.'**
  String get error_permission;

  /// No description provided for @error_location.
  ///
  /// In en, this message translates to:
  /// **'Location access is required.'**
  String get error_location;

  /// No description provided for @error_camera.
  ///
  /// In en, this message translates to:
  /// **'Camera access is required.'**
  String get error_camera;

  /// No description provided for @error_storage.
  ///
  /// In en, this message translates to:
  /// **'Storage access is required.'**
  String get error_storage;

  /// Notification Messages
  ///
  /// In en, this message translates to:
  /// **'Your order has been placed successfully!'**
  String get notif_order_placed;

  /// No description provided for @notif_order_confirmed.
  ///
  /// In en, this message translates to:
  /// **'Your order has been confirmed.'**
  String get notif_order_confirmed;

  /// No description provided for @notif_order_preparing.
  ///
  /// In en, this message translates to:
  /// **'Your order is being prepared.'**
  String get notif_order_preparing;

  /// No description provided for @notif_order_ready.
  ///
  /// In en, this message translates to:
  /// **'Your order is ready for pickup!'**
  String get notif_order_ready;

  /// No description provided for @notif_order_delivered.
  ///
  /// In en, this message translates to:
  /// **'Your order has been delivered.'**
  String get notif_order_delivered;

  /// No description provided for @notif_order_cancelled.
  ///
  /// In en, this message translates to:
  /// **'Your order has been cancelled.'**
  String get notif_order_cancelled;

  /// No description provided for @notif_item_added.
  ///
  /// In en, this message translates to:
  /// **'Item added to cart.'**
  String get notif_item_added;

  /// No description provided for @notif_item_removed.
  ///
  /// In en, this message translates to:
  /// **'Item removed from cart.'**
  String get notif_item_removed;

  /// No description provided for @notif_profile_updated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully.'**
  String get notif_profile_updated;

  /// No description provided for @notif_payment_success.
  ///
  /// In en, this message translates to:
  /// **'Payment completed successfully.'**
  String get notif_payment_success;

  /// No description provided for @notif_payment_failed.
  ///
  /// In en, this message translates to:
  /// **'Payment failed. Please try again.'**
  String get notif_payment_failed;

  /// General Terms
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @please_wait.
  ///
  /// In en, this message translates to:
  /// **'Please wait...'**
  String get please_wait;

  /// No description provided for @no_data.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get no_data;

  /// No description provided for @try_again.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get try_again;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacy;

  /// No description provided for @terms.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get terms;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
