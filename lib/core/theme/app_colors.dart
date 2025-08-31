import 'package:flutter/material.dart';

/// App Brand Colors
class AppColors {
  // Primary Brand Color
  static const Color primary = Color(0xFF25AC5F);      // #25AC5F - Main Green
  
  // Text Colors
  static const Color heading = Color(0xFF101828);      // #101828 - Bold/Heading Text
  static const Color body = Color(0xFF667085);         // #667085 - Normal Text
  
  // Semantic Colors
  static const Color success = Color(0xFF25AC5F);      // Use primary for success
  static const Color error = Color(0xFFE53E3E);        // Error red
  static const Color warning = Color(0xFFFF9800);      // Warning orange
  static const Color info = Color(0xFF03DAC6);         // Info teal
  
  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFE0E0E0);
  
  // Text Variants
  static const Color textPrimary = heading;            // Primary text (headings)
  static const Color textSecondary = body;             // Secondary text (body)
  static const Color textDisabled = Color(0xFF9E9E9E); // Disabled text
  
  // Interactive Colors
  static const Color buttonPrimary = primary;          // Primary button background
  static const Color buttonSecondary = Color(0xFFF5F5F5); // Secondary button background
  static const Color link = primary;                   // Link color
  
  // Status Colors
  static const Color online = primary;                 // Online status
  static const Color offline = Color(0xFF9E9E9E);     // Offline status
  static const Color pending = Color(0xFFFF9800);      // Pending status
}
