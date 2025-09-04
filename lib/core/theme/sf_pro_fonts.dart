import 'package:flutter/material.dart';

/// SF Pro Font Family Helper Class
/// 
/// This class provides easy access to SF Pro font families and common text styles
/// used throughout the app. It follows Apple's typography guidelines for SF Pro.
/// 
/// Note: If SF Pro fonts are not available, the system will automatically fallback
/// to the default system fonts (Roboto on Android, San Francisco on iOS).
class SFProFonts {
  // Font Family Names
  // These will fallback to system fonts if SF Pro is not available
  static const String display = 'SF Pro Display';
  static const String text = 'SF Pro Text';

  // Font Weights
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semibold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  // Display Styles (for large text, headings)
  static TextStyle displayLarge({
    Color? color,
    FontWeight? fontWeight,
    double? fontSize,
  }) {
    return TextStyle(
      fontFamily: display,
      fontSize: fontSize ?? 32,
      fontWeight: fontWeight ?? bold,
      color: color,
    );
  }

  static TextStyle displayMedium({
    Color? color,
    FontWeight? fontWeight,
    double? fontSize,
  }) {
    return TextStyle(
      fontFamily: display,
      fontSize: fontSize ?? 28,
      fontWeight: fontWeight ?? semibold,
      color: color,
    );
  }

  static TextStyle displaySmall({
    Color? color,
    FontWeight? fontWeight,
    double? fontSize,
  }) {
    return TextStyle(
      fontFamily: display,
      fontSize: fontSize ?? 24,
      fontWeight: fontWeight ?? semibold,
      color: color,
    );
  }

  // Headline Styles
  static TextStyle headlineLarge({
    Color? color,
    FontWeight? fontWeight,
    double? fontSize,
  }) {
    return TextStyle(
      fontFamily: display,
      fontSize: fontSize ?? 22,
      fontWeight: fontWeight ?? semibold,
      color: color,
    );
  }

  static TextStyle headlineMedium({
    Color? color,
    FontWeight? fontWeight,
    double? fontSize,
  }) {
    return TextStyle(
      fontFamily: display,
      fontSize: fontSize ?? 20,
      fontWeight: fontWeight ?? semibold,
      color: color,
    );
  }

  static TextStyle headlineSmall({
    Color? color,
    FontWeight? fontWeight,
    double? fontSize,
  }) {
    return TextStyle(
      fontFamily: display,
      fontSize: fontSize ?? 18,
      fontWeight: fontWeight ?? semibold,
      color: color,
    );
  }

  // Title Styles
  static TextStyle titleLarge({
    Color? color,
    FontWeight? fontWeight,
    double? fontSize,
  }) {
    return TextStyle(
      fontFamily: text,
      fontSize: fontSize ?? 16,
      fontWeight: fontWeight ?? semibold,
      color: color,
    );
  }

  static TextStyle titleMedium({
    Color? color,
    FontWeight? fontWeight,
    double? fontSize,
  }) {
    return TextStyle(
      fontFamily: text,
      fontSize: fontSize ?? 14,
      fontWeight: fontWeight ?? medium,
      color: color,
    );
  }

  static TextStyle titleSmall({
    Color? color,
    FontWeight? fontWeight,
    double? fontSize,
  }) {
    return TextStyle(
      fontFamily: text,
      fontSize: fontSize ?? 12,
      fontWeight: fontWeight ?? medium,
      color: color,
    );
  }

  // Body Styles
  static TextStyle bodyLarge({
    Color? color,
    FontWeight? fontWeight,
    double? fontSize,
  }) {
    return TextStyle(
      fontFamily: text,
      fontSize: fontSize ?? 16,
      fontWeight: fontWeight ?? regular,
      color: color,
    );
  }

  static TextStyle bodyMedium({
    Color? color,
    FontWeight? fontWeight,
    double? fontSize,
  }) {
    return TextStyle(
      fontFamily: text,
      fontSize: fontSize ?? 14,
      fontWeight: fontWeight ?? regular,
      color: color,
    );
  }

  static TextStyle bodySmall({
    Color? color,
    FontWeight? fontWeight,
    double? fontSize,
  }) {
    return TextStyle(
      fontFamily: text,
      fontSize: fontSize ?? 12,
      fontWeight: fontWeight ?? regular,
      color: color,
    );
  }

  // Label Styles
  static TextStyle labelLarge({
    Color? color,
    FontWeight? fontWeight,
    double? fontSize,
  }) {
    return TextStyle(
      fontFamily: text,
      fontSize: fontSize ?? 14,
      fontWeight: fontWeight ?? medium,
      color: color,
    );
  }

  static TextStyle labelMedium({
    Color? color,
    FontWeight? fontWeight,
    double? fontSize,
  }) {
    return TextStyle(
      fontFamily: text,
      fontSize: fontSize ?? 12,
      fontWeight: fontWeight ?? medium,
      color: color,
    );
  }

  static TextStyle labelSmall({
    Color? color,
    FontWeight? fontWeight,
    double? fontSize,
  }) {
    return TextStyle(
      fontFamily: text,
      fontSize: fontSize ?? 10,
      fontWeight: fontWeight ?? medium,
      color: color,
    );
  }

  // Custom Styles for specific use cases
  static TextStyle button({
    Color? color,
    FontWeight? fontWeight,
    double? fontSize,
  }) {
    return TextStyle(
      fontFamily: text,
      fontSize: fontSize ?? 16,
      fontWeight: fontWeight ?? semibold,
      color: color,
    );
  }

  static TextStyle caption({
    Color? color,
    FontWeight? fontWeight,
    double? fontSize,
  }) {
    return TextStyle(
      fontFamily: text,
      fontSize: fontSize ?? 11,
      fontWeight: fontWeight ?? regular,
      color: color,
    );
  }

  static TextStyle overline({
    Color? color,
    FontWeight? fontWeight,
    double? fontSize,
  }) {
    return TextStyle(
      fontFamily: text,
      fontSize: fontSize ?? 10,
      fontWeight: fontWeight ?? medium,
      color: color,
      letterSpacing: 1.5,
    );
  }
}
