import 'package:flutter/material.dart';

/// Design Theme for BMF Borrower Mobile App.
/// Optimized for high readability, large touch targets, and distinct contrast for rural borrowers.
class CustomerTheme {
  CustomerTheme._();

  // Brand Palette: Deep Ocean Teal & Turquoise Cyan with Warm Gold
  static const Color primaryNavy = Color(0xFF164E63); // Deep Oceanic Navy
  static const Color primaryCyan = Color(0xFF1A9BBB); // Vibrant Brand Cyan
  static const Color accentTeal = Color(0xFF0E8388); // Mint Teal
  static const Color secondaryAmber = Color(0xFFF59E0B); // Warm Golden Amber
  static const Color accentGold = Color(0xFFD97706); // Rich Gold
  static const Color accentCrimson = Color(0xFFDC2626); // Alert Crimson Red

  // Neutral Palette
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color borderSubtle = Color(0xFFE2E8F0);

  // Status & Debt Group Colors (Myanmar FRD Standard)
  static const Color statusCurrent = Color(0xFF10B981); // Normal / Paid
  static const Color statusSpecialMention = Color(0xFFD97706); // 1-30 days overdue
  static const Color statusSubstandard = Color(0xFFEA580C); // 31-60 days
  static const Color statusDoubtful = Color(0xFFDC2626); // 61-90 days
  static const Color statusLoss = Color(0xFF991B1B); // >90 days

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0E8388), Color(0xFF164E63)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF164E63), Color(0xFF1A9BBB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFBBF24), Color(0xFFD97706)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryCyan,
        primary: primaryCyan,
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
      cardTheme: CardThemeData(
        color: surfaceWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderSubtle, width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryCyan,
          foregroundColor: Colors.white,
          elevation: 1,
          shadowColor: primaryCyan.withAlpha(80),
          minimumSize: const Size(64, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryCyan,
          side: const BorderSide(color: primaryCyan, width: 1.5),
          minimumSize: const Size(64, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryCyan, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: accentCrimson),
        ),
        labelStyle: const TextStyle(color: textSecondary, fontSize: 14),
      ),
    );
  }
}
