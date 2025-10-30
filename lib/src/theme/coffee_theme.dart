import 'package:flutter/material.dart';

class CoffeeTheme {
  // Seed color for the new theme
  static const Color seedColor = Colors.teal;

  // Material Design 3 uyumlu ColorScheme - Açık tema
  static final ColorScheme lightColorScheme = ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: Brightness.light,
  );

  // Material Design 3 uyumlu ColorScheme - Karanlık tema
  static final ColorScheme darkColorScheme = ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: Brightness.dark,
  );

  // Loyalty level colors
  static final List<Color> loyaltyLevelColors = [
    Colors.brown.shade300,
    Colors.brown.shade500,
    Colors.orange.shade700,
    Colors.amber.shade800,
    Colors.deepPurple.shade800,
  ];
}