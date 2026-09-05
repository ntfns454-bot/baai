import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BaaiTheme {
  // ─── Brand Colors (Mobile Redesign) ──────────────────────────
  static const Color primary = Color(0xFFCDFC41);       // Vibrant Lime Green
  static const Color primaryDark = Color(0xFFA6CC2B);   // Darker Lime for hover/press states
  static const Color accent = Color(0xFF8B5CF6);         // Purple accent (keeping for contrast if needed)
  static const Color accentLight = Color(0xFFA78BFA);
  
  static const Color surface = Color(0xFFF9F9F9);        // Minimal light surface
  static const Color surfaceLight = Color(0xFFF3F4F6);
  static const Color card = Color(0xFFFFFFFF);           // Pure White
  static const Color cardHover = Color(0xFFF0F0F0);
  static const Color background = Color(0xFFF9F9F9);     // Minimal light surface
  
  static const Color textPrimary = Color(0xFF1A1A1A);    // Near-Black
  static const Color textSecondary = Color(0xFF6B7280);  // Cool Gray for secondary text
  static const Color divider = Color(0xFFE5E7EB);
  
  static const Color error = Color(0xFFEF4444);          // Red 500
  static const Color warning = Color(0xFFF59E0B);        // Amber 500
  static const Color success = Color(0xFF10B981);        // Emerald Green
  static const Color info = Color(0xFF3B82F6);           // Blue 500

  // ─── Animation Constants ──────────────────────────────────
  static const Duration fastAnim = Duration(milliseconds: 200);
  static const Duration mediumAnim = Duration(milliseconds: 350);
  static const Duration slowAnim = Duration(milliseconds: 500);
  static const Duration celebrationAnim = Duration(milliseconds: 800);
  static const Curve defaultCurve = Curves.easeOutCubic;

  // ─── Modern Card Styles ─────────────────────────────────────────
  static BoxDecoration get glassCard => BoxDecoration(
    color: card,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: divider.withValues(alpha: 0.5), width: 1),
    boxShadow: [
      BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 4)),
    ],
  );

  static BoxDecoration get glassCardHover => BoxDecoration(
    color: card,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: primary, width: 1.5),
    boxShadow: [
      BoxShadow(color: primary.withValues(alpha: 0.15), blurRadius: 20, offset: const Offset(0, 8)),
      BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, 6)),
    ],
  );

  // ─── Kiosk-specific (Retained for compatibility) ──────────────
  static BoxDecoration get kioskCard => BoxDecoration(
    color: card,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: divider, width: 2),
    boxShadow: [
      BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 24, offset: const Offset(0, 8)),
    ],
  );

  static BoxDecoration get kioskCardHover => BoxDecoration(
    color: cardHover,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: primary, width: 2),
    boxShadow: [
      BoxShadow(color: primary.withValues(alpha: 0.2), blurRadius: 30, offset: const Offset(0, 10)),
    ],
  );

  // ─── Sandbox Toolbar ───────────────────────────────────────
  static BoxDecoration get sandboxToolbar => BoxDecoration(
    color: surface.withValues(alpha: 0.95),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: divider, width: 1.5),
    boxShadow: [
      BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 30, offset: const Offset(0, 8)),
    ],
  );

  // ─── Theme Data ────────────────────────────────────────────
  // Changed to Light Theme for the new clean aesthetic
  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: background,
    primaryColor: primary,
    colorScheme: const ColorScheme.light(
      primary: primary,
      secondary: accent,
      surface: surface,
      error: error,
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).copyWith(
      headlineLarge: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w700, color: textPrimary),
      headlineMedium: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w600, color: textPrimary),
      headlineSmall: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary),
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
      iconTheme: const IconThemeData(color: textPrimary),
      titleTextStyle: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: textPrimary),
    ),
    iconTheme: const IconThemeData(color: textSecondary, size: 22),
    dividerColor: divider,
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primary,
      foregroundColor: textPrimary, // Dark text on Lime green FAB looks best
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: card,
      elevation: 16,
      selectedItemColor: primaryDark,
      unselectedItemColor: textSecondary,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
      unselectedLabelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
    ),
  );

  // ─── Gradient Presets ──────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFFA6CC2B)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, Color(0xFF6366F1)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );

  static const LinearGradient warmGradient = LinearGradient(
    colors: [Color(0xFFF43F5E), Color(0xFFF59E0B)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF34D399)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
}
