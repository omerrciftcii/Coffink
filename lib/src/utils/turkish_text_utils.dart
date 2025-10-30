
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TurkishTextUtils {
  /// Create a TextStyle optimized for Turkish characters
  static TextStyle createTurkishTextStyle({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
    TextDecoration? decoration,
  }) {
    return GoogleFonts.nunitoSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
      decoration: decoration,
      locale: const Locale('tr', 'TR'),
      // Explicitly support Turkish character variants
      fontFeatures: const [
        FontFeature.enable('locl'), // Localized forms
        FontFeature.enable('ccmp'), // Glyph composition/decomposition
      ],
    );
  }

  /// Create a safe TextWidget that properly renders Turkish characters
  static Widget createTurkishText(
    String text, {
    TextStyle? style,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    bool? softWrap,
  }) {
    return Text(
      text,
      style: style?.copyWith(
        fontFamily: GoogleFonts.nunitoSans().fontFamily,
        locale: const Locale('tr', 'TR'),
        fontFeatures: const [
          FontFeature.enable('locl'),
          FontFeature.enable('ccmp'),
        ],
      ) ?? createTurkishTextStyle(),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
      locale: const Locale('tr', 'TR'),
    );
  }

  /// Common text styles for Turkish coffee app
  static TextStyle get turkishHeading1 => createTurkishTextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get turkishHeading2 => createTurkishTextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get turkishHeading3 => createTurkishTextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  static TextStyle get turkishBody => createTurkishTextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );

  static TextStyle get turkishBodySmall => createTurkishTextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  static TextStyle get turkishCaption => createTurkishTextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
  );

  static TextStyle get turkishButton => createTurkishTextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  /// Check if a string contains Turkish characters
  static bool containsTurkishCharacters(String text) {
    return text.contains(RegExp(r'[şğüöçİıĞÜÖÇŞ]'));
  }

  /// Normalize Turkish text for better display
  static String normalizeTurkishText(String text) {
    // Ensure proper Unicode normalization for Turkish characters
    return text
        .replaceAll('ı', 'ı') // U+0131
        .replaceAll('İ', 'İ') // U+0130
        .replaceAll('ş', 'ş') // U+015F
        .replaceAll('Ş', 'Ş') // U+015E
        .replaceAll('ğ', 'ğ') // U+011F
        .replaceAll('Ğ', 'Ğ') // U+011E
        .replaceAll('ü', 'ü') // U+00FC
        .replaceAll('Ü', 'Ü') // U+00DC
        .replaceAll('ö', 'ö') // U+00F6
        .replaceAll('Ö', 'Ö') // U+00D6
        .replaceAll('ç', 'ç') // U+00E7
        .replaceAll('Ç', 'Ç'); // U+00C7
  }
}
