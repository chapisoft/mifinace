import 'package:flutter/material.dart';

/// Design Theme for BMF Borrower Mobile App.
/// Optimized for high readability, large touch targets, and distinct contrast for rural borrowers.
class CustomerTheme {
  CustomerTheme._();

  // Primary Palette
  static const Color primaryNavy = Color(0xFF1E3A8A); // Deep Navy Blue
  static const Color secondaryAmber = Color(0xFFF59E0B); // Warm Golden Amber
  static const Color accentTeal = Color(0xFF0D9488); // Success Teal
  static const Color accentCrimson = Color(0xFFDC2626); // Alert Crimson Red

  // Neutral Palette
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color borderSubtle = Color(0xFFCBD5E1);

  // Status & Debt Group Colors (Myanmar FRD Standard)
  static const Color statusCurrent = Color(0xFF16A34A); // Normal / Paid
  static const Color statusSpecialMention = Color(0xFFD97706); // 1-30 days overdue
  static const Color statusSubstandard = Color(0xFFEA580C); // 31-60 days
  static const Color statusDoubtful = Color(0xFFDC2626); // 61-90 days
  static const Color statusLoss = Color(0xFF991B1B); // >90 days

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryNavy,
        primary: primaryNavy,
        secondary: secondaryAmber,
        surface: surfaceWhite,
        error: accentCrimson,
      ),
      scaffoldBackgroundColor: backgroundLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryNavy,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.3,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryNavy,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52), // Large touch target for rural users
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primaryNavy, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: accentCrimson),
        ),
        labelStyle: const TextStyle(color: textSecondary, fontSize: 14),
      ),
    );
  }
}
