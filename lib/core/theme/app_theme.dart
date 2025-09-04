import 'package:flutter/material.dart';

class AppTheme {
  // Brand Colors
  static const Color primaryColor = Color(0xFF25AC5F);        // #25AC5F - Primary Green
  static const Color primaryVariant = Color(0xFF1E8A4D);     // Darker variant of primary
  static const Color secondaryColor = Color(0xFF03DAC6);     // Keep existing secondary
  static const Color secondaryVariant = Color(0xFF018786);   // Keep existing secondary variant

  // Accent Colors
  static const Color accentColor = Color(0xFFFF6B35);        // Keep existing accent
  static const Color successColor = Color(0xFF4CAF50);       // Keep existing success
  static const Color errorColor = Color(0xFFE53E3E);         // Keep existing error
  static const Color warningColor = Color(0xFFFF9800);       // Keep existing warning

  // Neutral Colors
  static const Color backgroundColor = Color(0xFFFAFAFA);     // Keep existing background
  static const Color surfaceColor = Color(0xFFFFFFFF);       // Keep existing surface
  static const Color cardColor = Color(0xFFFFFFFF);          // Keep existing card
  static const Color dividerColor = Color(0xFFE0E0E0);       // Keep existing divider

  // Text Colors - Your Brand Colors
  static const Color primaryTextColor = Color(0xFF101828);   // #101828 - Bold/Heading Text
  static const Color secondaryTextColor = Color(0xFF667085); // #667085 - Normal Text
  static const Color disabledTextColor = Color(0xFF9E9E9E); // Keep existing disabled

  // E-commerce Specific Colors
  static const Color priceColor = Color(0xFF25AC5F);        // Use primary green for prices
  static const Color discountColor = Color(0xFFE53E3E);     // Keep existing discount color
  static const Color ratingColor = Color(0xFFFFC107);       // Keep existing rating color

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: primaryTextColor,
        onError: Colors.white,
      ),

      // Typography - SF Pro Font Family (with system font fallbacks)
      textTheme: const TextTheme(
        // Display styles - using SF Pro Display for large text (fallback to system font)
        displayLarge: TextStyle(
          fontFamily: 'SF Pro Display',
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: primaryTextColor,
        ),
        displayMedium: TextStyle(
          fontFamily: 'SF Pro Display',
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: primaryTextColor,
        ),
        displaySmall: TextStyle(
          fontFamily: 'SF Pro Display',
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: primaryTextColor,
        ),
        headlineLarge: TextStyle(
          fontFamily: 'SF Pro Display',
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: primaryTextColor,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'SF Pro Display',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: primaryTextColor,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'SF Pro Display',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: primaryTextColor,
        ),
        // Title styles - using SF Pro Text for medium text (fallback to system font)
        titleLarge: TextStyle(
          fontFamily: 'SF Pro Text',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: primaryTextColor,
        ),
        titleMedium: TextStyle(
          fontFamily: 'SF Pro Text',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: primaryTextColor,
        ),
        titleSmall: TextStyle(
          fontFamily: 'SF Pro Text',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: secondaryTextColor,
        ),
        // Body styles - using SF Pro Text for body text (fallback to system font)
        bodyLarge: TextStyle(
          fontFamily: 'SF Pro Text',
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: primaryTextColor,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'SF Pro Text',
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: primaryTextColor,
        ),
        bodySmall: TextStyle(
          fontFamily: 'SF Pro Text',
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: secondaryTextColor,
        ),
        // Label styles - using SF Pro Text for labels (fallback to system font)
        labelLarge: TextStyle(
          fontFamily: 'SF Pro Text',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: primaryTextColor,
        ),
        labelMedium: TextStyle(
          fontFamily: 'SF Pro Text',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: secondaryTextColor,
        ),
        labelSmall: TextStyle(
          fontFamily: 'SF Pro Text',
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: secondaryTextColor,
        ),
      ),

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: primaryTextColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'SF Pro Text',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: primaryTextColor,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(8),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(
            fontFamily: 'SF Pro Text',
            fontSize: 16, 
            fontWeight: FontWeight.w600
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(
            fontFamily: 'SF Pro Text',
            fontSize: 16, 
            fontWeight: FontWeight.w600
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        hintStyle: TextStyle(color: Colors.grey[500]),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: secondaryTextColor,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: Color(0xFF1C1B1F),
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: Colors.white,
        onError: Colors.white,
      ),

      // Typography - SF Pro Font Family (Dark Theme with system font fallbacks)
      textTheme: const TextTheme(
        // Display styles - using SF Pro Display for large text (fallback to system font)
        displayLarge: TextStyle(
          fontFamily: 'SF Pro Display',
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        displayMedium: TextStyle(
          fontFamily: 'SF Pro Display',
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        displaySmall: TextStyle(
          fontFamily: 'SF Pro Display',
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        headlineLarge: TextStyle(
          fontFamily: 'SF Pro Display',
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'SF Pro Display',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'SF Pro Display',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        // Title styles - using SF Pro Text for medium text (fallback to system font)
        titleLarge: TextStyle(
          fontFamily: 'SF Pro Text',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleMedium: TextStyle(
          fontFamily: 'SF Pro Text',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        titleSmall: TextStyle(
          fontFamily: 'SF Pro Text',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.grey,
        ),
        // Body styles - using SF Pro Text for body text (fallback to system font)
        bodyLarge: TextStyle(
          fontFamily: 'SF Pro Text',
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: Colors.white,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'SF Pro Text',
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: Colors.white,
        ),
        bodySmall: TextStyle(
          fontFamily: 'SF Pro Text',
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: Colors.grey,
        ),
        // Label styles - using SF Pro Text for labels (fallback to system font)
        labelLarge: TextStyle(
          fontFamily: 'SF Pro Text',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        labelMedium: TextStyle(
          fontFamily: 'SF Pro Text',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.grey,
        ),
        labelSmall: TextStyle(
          fontFamily: 'SF Pro Text',
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: Colors.grey,
        ),
      ),

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1C1B1F),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'SF Pro Text',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: const Color(0xFF1C1B1F),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(8),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(
            fontFamily: 'SF Pro Text',
            fontSize: 16, 
            fontWeight: FontWeight.w600
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(
            fontFamily: 'SF Pro Text',
            fontSize: 16, 
            fontWeight: FontWeight.w600
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2D2D2D),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[600]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        hintStyle: TextStyle(color: Colors.grey[400]),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1C1B1F),
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
