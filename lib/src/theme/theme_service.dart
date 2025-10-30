
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'coffee_theme.dart';

/// Service for managing application themes
/// Supports light/dark mode switching and persistence
class ThemeService extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  
  ThemeMode _themeMode = ThemeMode.light;
  
  ThemeMode get themeMode => _themeMode;
  
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isLightMode => _themeMode == ThemeMode.light;
  bool get isSystemMode => _themeMode == ThemeMode.system;

  /// Initialize theme service and load saved preferences
  Future<void> initialize() async {
    await _loadThemeMode();
  }

  /// Get light theme with coffee colors and Material Design 3
  ThemeData get lightTheme {
    final textTheme = GoogleFonts.nunitoSansTextTheme().copyWith(
        displayLarge: GoogleFonts.nunitoSans(
          fontWeight: FontWeight.bold,
          color: CoffeeTheme.lightColorScheme.onSurface,
          locale: const Locale('tr', 'TR'),
        ),
        displayMedium: GoogleFonts.nunitoSans(
          fontWeight: FontWeight.w600,
          color: CoffeeTheme.lightColorScheme.onSurface,
          locale: const Locale('tr', 'TR'),
        ),
        displaySmall: GoogleFonts.nunitoSans(
          fontWeight: FontWeight.w600,
          color: CoffeeTheme.lightColorScheme.onSurface,
          locale: const Locale('tr', 'TR'),
        ),
        headlineLarge: GoogleFonts.nunitoSans(
          fontWeight: FontWeight.bold,
          color: CoffeeTheme.lightColorScheme.onSurface,
          locale: const Locale('tr', 'TR'),
        ),
        headlineMedium: GoogleFonts.nunitoSans(
          fontWeight: FontWeight.w600,
          color: CoffeeTheme.lightColorScheme.onSurface,
          locale: const Locale('tr', 'TR'),
        ),
        headlineSmall: GoogleFonts.nunitoSans(
          fontWeight: FontWeight.w600,
          color: CoffeeTheme.lightColorScheme.onSurface,
          locale: const Locale('tr', 'TR'),
        ),
        titleLarge: GoogleFonts.nunitoSans(
          fontWeight: FontWeight.w600,
          color: CoffeeTheme.lightColorScheme.onSurface,
          locale: const Locale('tr', 'TR'),
        ),
        titleMedium: GoogleFonts.nunitoSans(
          fontWeight: FontWeight.w500,
          color: CoffeeTheme.lightColorScheme.onSurface,
          locale: const Locale('tr', 'TR'),
        ),
        titleSmall: GoogleFonts.nunitoSans(
          fontWeight: FontWeight.w500,
          color: CoffeeTheme.lightColorScheme.onSurfaceVariant,
          locale: const Locale('tr', 'TR'),
        ),
        bodyLarge: GoogleFonts.nunitoSans(
          color: CoffeeTheme.lightColorScheme.onSurface,
          locale: const Locale('tr', 'TR'),
        ),
        bodyMedium: GoogleFonts.nunitoSans(
          color: CoffeeTheme.lightColorScheme.onSurface,
          locale: const Locale('tr', 'TR'),
        ),
        bodySmall: GoogleFonts.nunitoSans(
          color: CoffeeTheme.lightColorScheme.onSurfaceVariant,
          locale: const Locale('tr', 'TR'),
        ),
        labelLarge: GoogleFonts.nunitoSans(
          fontWeight: FontWeight.w500,
          color: CoffeeTheme.lightColorScheme.onSurface,
          locale: const Locale('tr', 'TR'),
        ),
        labelMedium: GoogleFonts.nunitoSans(
          fontWeight: FontWeight.w500,
          color: CoffeeTheme.lightColorScheme.onSurfaceVariant,
          locale: const Locale('tr', 'TR'),
        ),
        labelSmall: GoogleFonts.nunitoSans(
          fontWeight: FontWeight.w500,
          color: CoffeeTheme.lightColorScheme.outline,
          locale: const Locale('tr', 'TR'),
        ),
      );

    return ThemeData(
      useMaterial3: true,
      colorScheme: CoffeeTheme.lightColorScheme,
      
      // Typography with Turkish locale support
      textTheme: textTheme,
      
      // AppBar theme
      appBarTheme: AppBarTheme(
        backgroundColor: CoffeeTheme.lightColorScheme.surface,
        foregroundColor: CoffeeTheme.lightColorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.nunitoSans(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: CoffeeTheme.lightColorScheme.onSurface,
          locale: const Locale('tr', 'TR'),
        ),
        iconTheme: IconThemeData(
          color: CoffeeTheme.lightColorScheme.onSurface,
        ),
      ),
      
      // Card theme
      cardTheme: CardThemeData(
        color: CoffeeTheme.lightColorScheme.surface,
        elevation: 2,
        shadowColor: CoffeeTheme.lightColorScheme.shadow.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: CoffeeTheme.lightColorScheme.primary,
          foregroundColor: CoffeeTheme.lightColorScheme.onPrimary,
          elevation: 2,
          shadowColor: CoffeeTheme.lightColorScheme.shadow.withOpacity(0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.nunitoSans(
            fontWeight: FontWeight.w600,
            locale: const Locale('tr', 'TR'),
          ),
        ),
      ),
      
      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: CoffeeTheme.lightColorScheme.secondary,
          textStyle: GoogleFonts.nunitoSans(
            fontWeight: FontWeight.w500,
            locale: const Locale('tr', 'TR'),
          ),
        ),
      ),
      
      // Outlined button theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: CoffeeTheme.lightColorScheme.onSurface,
          side: BorderSide(color: CoffeeTheme.lightColorScheme.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.nunitoSans(
            fontWeight: FontWeight.w500,
            locale: const Locale('tr', 'TR'),
          ),
        ),
      ),
      
      // Bottom navigation bar theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: CoffeeTheme.lightColorScheme.surface,
        selectedItemColor: CoffeeTheme.lightColorScheme.primary,
        unselectedItemColor: CoffeeTheme.lightColorScheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: CoffeeTheme.lightColorScheme.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: CoffeeTheme.lightColorScheme.primary, width: 2),
        ),
        labelStyle: GoogleFonts.nunitoSans(
          color: CoffeeTheme.lightColorScheme.onSurfaceVariant,
          locale: const Locale('tr', 'TR'),
        ),
        hintStyle: GoogleFonts.nunitoSans(
          color: CoffeeTheme.lightColorScheme.outline,
          locale: const Locale('tr', 'TR'),
        ),
      ),
      
      // Floating action button theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: CoffeeTheme.lightColorScheme.secondary,
        foregroundColor: CoffeeTheme.lightColorScheme.onSecondary,
        elevation: 4,
      ),
      
      // Divider theme
      dividerTheme: DividerThemeData(
        color: CoffeeTheme.lightColorScheme.outline.withOpacity(0.5),
        thickness: 1,
      ),
    );
  }

  /// Get dark theme with coffee colors and Material Design 3
  ThemeData get darkTheme {
    final textTheme = GoogleFonts.nunitoSansTextTheme().copyWith(
        displayLarge: GoogleFonts.nunitoSans(
          fontWeight: FontWeight.bold,
          color: CoffeeTheme.darkColorScheme.onSurface,
          locale: const Locale('tr', 'TR'),
        ),
        displayMedium: GoogleFonts.nunitoSans(
          fontWeight: FontWeight.w600,
          color: CoffeeTheme.darkColorScheme.onSurface,
          locale: const Locale('tr', 'TR'),
        ),
        displaySmall: GoogleFonts.nunitoSans(
          fontWeight: FontWeight.w600,
          color: CoffeeTheme.darkColorScheme.onSurface,
          locale: const Locale('tr', 'TR'),
        ),
        headlineLarge: GoogleFonts.nunitoSans(
          fontWeight: FontWeight.bold,
          color: CoffeeTheme.darkColorScheme.onSurface,
          locale: const Locale('tr', 'TR'),
        ),
        headlineMedium: GoogleFonts.nunitoSans(
          fontWeight: FontWeight.w600,
          color: CoffeeTheme.darkColorScheme.onSurface,
          locale: const Locale('tr', 'TR'),
        ),
        headlineSmall: GoogleFonts.nunitoSans(
          fontWeight: FontWeight.w600,
          color: CoffeeTheme.darkColorScheme.onSurface,
          locale: const Locale('tr', 'TR'),
        ),
        titleLarge: GoogleFonts.nunitoSans(
          fontWeight: FontWeight.w600,
          color: CoffeeTheme.darkColorScheme.onSurface,
          locale: const Locale('tr', 'TR'),
        ),
        titleMedium: GoogleFonts.nunitoSans(
          fontWeight: FontWeight.w500,
          color: CoffeeTheme.darkColorScheme.onSurface,
          locale: const Locale('tr', 'TR'),
        ),
        titleSmall: GoogleFonts.nunitoSans(
          fontWeight: FontWeight.w500,
          color: CoffeeTheme.darkColorScheme.onSurfaceVariant,
          locale: const Locale('tr', 'TR'),
        ),
        bodyLarge: GoogleFonts.nunitoSans(
          color: CoffeeTheme.darkColorScheme.onSurface,
          locale: const Locale('tr', 'TR'),
        ),
        bodyMedium: GoogleFonts.nunitoSans(
          color: CoffeeTheme.darkColorScheme.onSurface,
          locale: const Locale('tr', 'TR'),
        ),
        bodySmall: GoogleFonts.nunitoSans(
          color: CoffeeTheme.darkColorScheme.onSurfaceVariant,
          locale: const Locale('tr', 'TR'),
        ),
        labelLarge: GoogleFonts.nunitoSans(
          fontWeight: FontWeight.w500,
          color: CoffeeTheme.darkColorScheme.onSurface,
          locale: const Locale('tr', 'TR'),
        ),
        labelMedium: GoogleFonts.nunitoSans(
          fontWeight: FontWeight.w500,
          color: CoffeeTheme.darkColorScheme.onSurfaceVariant,
          locale: const Locale('tr', 'TR'),
        ),
        labelSmall: GoogleFonts.nunitoSans(
          fontWeight: FontWeight.w500,
          color: CoffeeTheme.darkColorScheme.outline,
          locale: const Locale('tr', 'TR'),
        ),
      );

    return ThemeData(
      useMaterial3: true,
      colorScheme: CoffeeTheme.darkColorScheme,
      
      // Typography with Turkish locale support
      textTheme: textTheme,
      
      // AppBar theme
      appBarTheme: AppBarTheme(
        backgroundColor: CoffeeTheme.darkColorScheme.surface,
        foregroundColor: CoffeeTheme.darkColorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.nunitoSans(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: CoffeeTheme.darkColorScheme.onSurface,
          locale: const Locale('tr', 'TR'),
        ),
        iconTheme: IconThemeData(
          color: CoffeeTheme.darkColorScheme.onSurface,
        ),
      ),
      
      // Card theme
      cardTheme: CardThemeData(
        color: CoffeeTheme.darkColorScheme.surface,
        elevation: 2,
        shadowColor: CoffeeTheme.darkColorScheme.shadow.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: CoffeeTheme.darkColorScheme.primary,
          foregroundColor: CoffeeTheme.darkColorScheme.onPrimary,
          elevation: 2,
          shadowColor: CoffeeTheme.darkColorScheme.shadow.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.nunitoSans(
            fontWeight: FontWeight.w600,
            locale: const Locale('tr', 'TR'),
          ),
        ),
      ),
      
      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: CoffeeTheme.darkColorScheme.secondary,
          textStyle: GoogleFonts.nunitoSans(
            fontWeight: FontWeight.w500,
            locale: const Locale('tr', 'TR'),
          ),
        ),
      ),
      
      // Outlined button theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: CoffeeTheme.darkColorScheme.onSurface,
          side: BorderSide(color: CoffeeTheme.darkColorScheme.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.nunitoSans(
            fontWeight: FontWeight.w500,
            locale: const Locale('tr', 'TR'),
          ),
        ),
      ),
      
      // Bottom navigation bar theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: CoffeeTheme.darkColorScheme.surface,
        selectedItemColor: CoffeeTheme.darkColorScheme.primary,
        unselectedItemColor: CoffeeTheme.darkColorScheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: CoffeeTheme.darkColorScheme.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: CoffeeTheme.darkColorScheme.primary, width: 2),
        ),
        labelStyle: GoogleFonts.nunitoSans(
          color: CoffeeTheme.darkColorScheme.onSurfaceVariant,
          locale: const Locale('tr', 'TR'),
        ),
        hintStyle: GoogleFonts.nunitoSans(
          color: CoffeeTheme.darkColorScheme.outline,
          locale: const Locale('tr', 'TR'),
        ),
      ),
      
      // Floating action button theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: CoffeeTheme.darkColorScheme.secondary,
        foregroundColor: CoffeeTheme.darkColorScheme.onSecondary,
        elevation: 4,
      ),
      
      // Divider theme
      dividerTheme: DividerThemeData(
        color: CoffeeTheme.darkColorScheme.outline.withOpacity(0.5),
        thickness: 1,
      ),
    );
  }

  /// Toggle between light and dark themes
  void toggleTheme() {
    if (_themeMode == ThemeMode.light) {
      setTheme(ThemeMode.dark);
    } else {
      setTheme(ThemeMode.light);
    }
  }

  /// Set specific theme mode
  void setTheme(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      _saveThemeMode();
      notifyListeners();
    }
  }

  /// Reset to default light theme
  void resetToDefault() {
    setTheme(ThemeMode.light);
  }

  /// Load theme mode from SharedPreferences
  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeModeString = prefs.getString(_themeKey);
      
      if (themeModeString != null) {
        switch (themeModeString) {
          case 'light':
            _themeMode = ThemeMode.light;
            break;
          case 'dark':
            _themeMode = ThemeMode.dark;
            break;
          case 'system':
            _themeMode = ThemeMode.system;
            break;
          default:
            _themeMode = ThemeMode.light;
        }
      }
    } catch (e) {
      // If loading fails, use default light theme
      _themeMode = ThemeMode.light;
    }
  }

  /// Save theme mode to SharedPreferences
  Future<void> _saveThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String themeModeString;
      
      switch (_themeMode) {
        case ThemeMode.light:
          themeModeString = 'light';
          break;
        case ThemeMode.dark:
          themeModeString = 'dark';
          break;
        case ThemeMode.system:
          themeModeString = 'system';
          break;
      }
      
      await prefs.setString(_themeKey, themeModeString);
    } catch (e) {
      // If saving fails, continue without persistence
    }
  }
}
