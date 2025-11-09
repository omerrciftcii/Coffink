import 'package:flutter/material.dart';

class CoffeeTheme {
  // Brand palette (light mode focus)
  static const Color coffee = Color(0xFFA47648); // Primary brand
  static const Color beige = Color(0xFFEFE8DE); // Inputs / subtle bg
  static const Color bgCalm = Color(0xFFDCE1DA); // App background
  static const Color darkBrown = Color(0xFF4E342E); // Text / headings / icons
  static const Color white = Color(0xFFFFFFFF); // Cards / contrast areas
  static const Color lightGrey = Color(0xFFE9E9E9); // Dividers / borders

  // Material Design 3 compatible ColorScheme - Light
  static const ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: coffee,
    onPrimary: white,

    secondary: darkBrown,
    onSecondary: white,

    surface: white, // Cards and surfaces
    onSurface: darkBrown,

    background: bgCalm, // App scaffold background
    onBackground: darkBrown,

    error: Color(0xFFB00020),
    onError: white,

    primaryContainer: coffee,
    onPrimaryContainer: white,
    secondaryContainer: beige,
    onSecondaryContainer: darkBrown,

    surfaceVariant: beige, // For inputs and subtle blocks
    onSurfaceVariant: darkBrown,

    outline: lightGrey,
    shadow: Colors.black,
    inverseSurface: darkBrown,
    onInverseSurface: white,
    inversePrimary: coffee,
  );

  // Material Design 3 compatible ColorScheme - Dark
  // Use seed from brand primary to keep consistency in dark mode.
  static final ColorScheme darkColorScheme = ColorScheme.fromSeed(
    seedColor: coffee,
    brightness: Brightness.dark,
  );

  // Loyalty level colors (unchanged)
  static final List<Color> loyaltyLevelColors = [
    Colors.brown,
    Colors.brown,
    Colors.orange,
    Colors.amber,
    Colors.deepPurple,
  ];
}

