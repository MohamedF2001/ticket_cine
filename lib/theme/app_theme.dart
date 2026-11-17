import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Couleurs principales
  static const Color backgroundColor = Color(0xFF09090B);
  static const Color surfaceColor = Color(0xFF171719);
  static const Color primaryColor = Color(0xFFB72126);
  static const Color accentColor = Color(0xFFD3373E);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFC4C4C7);
  static const Color cardColor = Color(0xFF202023);
  static const Color outlineColor = Color(0xFF4C4D4F);
  static const Color errorColor = Color(0xFFF07178);
  static const Color seatAvailable = Color(0xFF343438);
  static const Color seatSelected = Color(0xFFB72126);
  static const Color seatReserved = Color(0xFF737379);
  static const Color glassColor = Color(0x1AFFFFFF);
  static const Color glassBorderColor = Color(0x33FFFFFF);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFB72126), Color(0xFF921B20)],
  );

  static const LinearGradient secondGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Colors.transparent, Color(0xFF921B20)],
  );

  static const LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x33FFFFFF),
      Color(0x1AFFFFFF),
    ],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF09090B),
      Color(0xFF111113),
      Color(0xFF09090B),
    ],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF252528), Color(0xFF202023)],
  );

  // ThemeData
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: backgroundColor,
    primaryColor: primaryColor,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: accentColor,
      surface: surfaceColor,
      background: backgroundColor,
      error: errorColor,
    ),

    // Typographie
    textTheme: TextTheme(
      displayLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      displaySmall: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      titleLarge: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      titleMedium: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: textPrimary,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 16,
        color: textPrimary,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        color: textSecondary,
      ),
      labelLarge: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
    ),

    // AppBar
    appBarTheme: AppBarTheme(
      backgroundColor: surfaceColor,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: textPrimary),
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        letterSpacing: 0.5,
      ),
    ),

    // Card
    cardTheme: CardThemeData(
      color: cardColor,
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),

    // Buttons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: textPrimary,
        elevation: 4,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white
        ),
      ),
    ),

    // Input
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: outlineColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      labelStyle: GoogleFonts.poppins(color: textSecondary),
      hintStyle: GoogleFonts.poppins(color: textSecondary),
    ),

    // Bottom Navigation
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surfaceColor,
      selectedItemColor: accentColor,
      unselectedItemColor: textSecondary,
      selectedLabelStyle: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
      type: BottomNavigationBarType.fixed,
      elevation: 16,
    ),
  );

  // Animations
  static const Duration defaultDuration = Duration(milliseconds: 300);
  static const Curve defaultCurve = Curves.easeInOut;

  // Spacing
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 10.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  // Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;

  // Glassmorphism Decoration
  static BoxDecoration glassDecoration({
    double radius = radiusMedium,
    Color? color,
    Border? border,
  }) {
    return BoxDecoration(
      color: color ?? glassColor,
      borderRadius: BorderRadius.circular(radius),
      border: border ?? Border.all(color: glassBorderColor, width: 1.5),
    );
  }
}
