import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_service.dart';

/// A widget that provides a button to toggle between light and dark themes
class ThemeToggleButton extends StatelessWidget {
  final bool showLabel;
  final IconData? lightIcon;
  final IconData? darkIcon;
  
  const ThemeToggleButton({
    super.key,
    this.showLabel = false,
    this.lightIcon,
    this.darkIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        final isDark = themeService.isDarkMode;
        
        if (showLabel) {
          return TextButton.icon(
            onPressed: () => themeService.toggleTheme(),
            icon: Icon(
              isDark 
                ? (lightIcon ?? Icons.light_mode) 
                : (darkIcon ?? Icons.dark_mode),
            ),
            label: Text(
              isDark ? 'Açık Tema' : 'Koyu Tema',
            ),
          );
        }
        
        return IconButton(
          onPressed: () => themeService.toggleTheme(),
          icon: Icon(
            isDark 
              ? (lightIcon ?? Icons.light_mode) 
              : (darkIcon ?? Icons.dark_mode),
          ),
          tooltip: isDark ? 'Açık temaya geç' : 'Koyu temaya geç',
        );
      },
    );
  }
}

/// A more advanced theme selector with system option
class ThemeSelector extends StatelessWidget {
  const ThemeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.light_mode),
              title: const Text('Açık Tema'),
              trailing: themeService.isLightMode 
                ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                : null,
              onTap: () => themeService.setTheme(ThemeMode.light),
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text('Koyu Tema'),
              trailing: themeService.isDarkMode 
                ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                : null,
              onTap: () => themeService.setTheme(ThemeMode.dark),
            ),
            ListTile(
              leading: const Icon(Icons.settings_system_daydream),
              title: const Text('Sistem Ayarı'),
              trailing: themeService.isSystemMode 
                ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                : null,
              onTap: () => themeService.setTheme(ThemeMode.system),
            ),
          ],
        );
      },
    );
  }
}