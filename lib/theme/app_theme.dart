import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BaaiTheme {
  // ─── Brand Colors ──────────────────────────────────────────
  static const Color primary = Color(0xFF6C63FF);       // Vivid indigo
  static const Color primaryDark = Color(0xFF4A42D9);
  static const Color accent = Color(0xFF00D9A6);         // Emerald teal
  static const Color accentLight = Color(0xFF33E8BE);
  static const Color surface = Color(0xFF1A1B2E);        // Deep navy
  static const Color surfaceLight = Color(0xFF232541);
  static const Color card = Color(0xFF2A2C4A);
  static const Color cardHover = Color(0xFF33365A);
  static const Color background = Color(0xFF12131F);
  static const Color textPrimary = Color(0xFFF0F0F8);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color divider = Color(0xFF3A3C5C);
  static const Color error = Color(0xFFEF5350);
  static const Color warning = Color(0xFFFFB74D);
  static const Color success = Color(0xFF4CAF50);
  static const Color info = Color(0xFF42A5F5);

  // ─── Animation Constants ──────────────────────────────────
  static const Duration fastAnim = Duration(milliseconds: 200);
  static const Duration mediumAnim = Duration(milliseconds: 350);
  static const Duration slowAnim = Duration(milliseconds: 500);
  static const Duration celebrationAnim = Duration(milliseconds: 800);
  static const Curve defaultCurve = Curves.easeOutCubic;

  // ─── Glassmorphism ─────────────────────────────────────────
  static BoxDecoration get glassCard => BoxDecoration(
    color: card.withOpacity(0.6),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: primary.withOpacity(0.15), width: 1),
    boxShadow: [
      BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 8)),
    ],
  );

  static BoxDecoration get glassCardHover => BoxDecoration(
    color: cardHover.withOpacity(0.7),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: primary.withOpacity(0.3), width: 1.5),
    boxShadow: [
      BoxShadow(color: primary.withOpacity(0.1), blurRadius: 30, offset: const Offset(0, 10)),
    ],
  );

  // ─── Kiosk-specific ────────────────────────────────────────
  static BoxDecoration get kioskCard => BoxDecoration(
    color: card.withOpacity(0.8),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: accent.withOpacity(0.25), width: 2),
    boxShadow: [
      BoxShadow(color: accent.withOpacity(0.08), blurRadius: 24, offset: const Offset(0, 6)),
    ],
  );

  static BoxDecoration get kioskCardHover => BoxDecoration(
    color: cardHover.withOpacity(0.85),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: accent.withOpacity(0.5), width: 2),
    boxShadow: [
      BoxShadow(color: accent.withOpacity(0.15), blurRadius: 30, offset: const Offset(0, 8)),
    ],
  );

  // ─── Sandbox Toolbar ───────────────────────────────────────
  static BoxDecoration get sandboxToolbar => BoxDecoration(
    color: surface.withOpacity(0.92),
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: accent.withOpacity(0.25), width: 1.5),
    boxShadow: [
      BoxShadow(color: Colors.black.withOpacity(0.35), blurRadius: 30, offset: const Offset(0, 4)),
      BoxShadow(color: primary.withOpacity(0.08), blurRadius: 20, spreadRadius: 2),
    ],
  );

  // ─── Theme Data ────────────────────────────────────────────
  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: background,
    primaryColor: primary,
    colorScheme: const ColorScheme.dark(
      primary: primary,
      secondary: accent,
      surface: surface,
      error: error,
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
      headlineLarge: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w700, color: textPrimary),
      headlineMedium: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w600, color: textPrimary),
      headlineSmall: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary),
      titleLarge: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary),
      titleMedium: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, color: textPrimary),
      bodyLarge: GoogleFonts.inter(fontSize: 15, color: textPrimary),
      bodyMedium: GoogleFonts.inter(fontSize: 14, color: textSecondary),
      bodySmall: GoogleFonts.inter(fontSize: 12, color: textSecondary),
      labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary),
    ),
    cardTheme: CardThemeData(
      color: card,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: surface,
      elevation: 0,
      titleTextStyle: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w700, color: textPrimary),
    ),
    iconTheme: const IconThemeData(color: textSecondary, size: 22),
    dividerColor: divider,
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primary,
      foregroundColor: Colors.white,
    ),
  );

  // ─── Gradient Presets ──────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF8B5CF6)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, Color(0xFF06B6D4)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );

  static const LinearGradient warmGradient = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFFFB84D)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
}
