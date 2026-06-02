import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color accentColor = Color(0xFFE8963E);
  static const Color successColor = Color(0xFF2ECC71);
  static const Color errorColor = Color(0xFFE74C3C);
  static const Color goldColor = Color(0xFFD4A853);

  static Color primaryColor = const Color(0xFF1A3A5C);
  static Color secondaryColor = const Color(0xFF2E86AB);
  static Color textPrimary = const Color(0xFF2C3E50);
  static Color textSecondary = const Color(0xFF7F8C8D);
  static Color bgColor = const Color(0xFFF8F9FA);
  static Color cardColor = Colors.white;
  static Color dividerColor = const Color(0xFFECF0F1);

  static void updateColors(Color primary, Color secondary) {
    primaryColor = primary;
    secondaryColor = secondary;
  }

  static TextTheme _cairoTextTheme([Color? bodyColor]) {
    return GoogleFonts.cairoTextTheme(
      TextTheme(
        displayLarge: TextStyle(fontWeight: FontWeight.w800, color: bodyColor),
        displayMedium: TextStyle(fontWeight: FontWeight.w700, color: bodyColor),
        displaySmall: TextStyle(fontWeight: FontWeight.w700, color: bodyColor),
        headlineLarge: TextStyle(fontWeight: FontWeight.w700, color: bodyColor),
        headlineMedium: TextStyle(fontWeight: FontWeight.w600, color: bodyColor),
        headlineSmall: TextStyle(fontWeight: FontWeight.w600, color: bodyColor),
        titleLarge: TextStyle(fontWeight: FontWeight.w700, color: bodyColor),
        titleMedium: TextStyle(fontWeight: FontWeight.w600, color: bodyColor),
        titleSmall: TextStyle(fontWeight: FontWeight.w500, color: bodyColor),
        bodyLarge: TextStyle(fontWeight: FontWeight.w400, color: bodyColor),
        bodyMedium: TextStyle(fontWeight: FontWeight.w400, color: bodyColor),
        bodySmall: TextStyle(fontWeight: FontWeight.w400, color: bodyColor),
        labelLarge: TextStyle(fontWeight: FontWeight.w600, color: bodyColor),
        labelMedium: TextStyle(fontWeight: FontWeight.w500, color: bodyColor),
        labelSmall: TextStyle(fontWeight: FontWeight.w500, color: bodyColor),
      ),
    );
  }

  static ThemeData lightTheme(Color primary, Color secondary) {
    primaryColor = primary;
    secondaryColor = secondary;
    textPrimary = const Color(0xFF2C3E50);
    textSecondary = const Color(0xFF7F8C8D);
    bgColor = const Color(0xFFF8F9FA);
    cardColor = Colors.white;
    dividerColor = const Color(0xFFECF0F1);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: secondary,
        tertiary: accentColor,
        surface: cardColor,
        error: errorColor,
      ),
      scaffoldBackgroundColor: bgColor,
      textTheme: _cairoTextTheme(textPrimary),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: primary,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 1,
        titleTextStyle: GoogleFonts.cairo(
          color: primary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: BorderSide(color: primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: secondary,
          textStyle: GoogleFonts.cairo(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFECF0F1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFECF0F1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: secondary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: errorColor),
        ),
        labelStyle: GoogleFonts.cairo(color: textSecondary),
        hintStyle: GoogleFonts.cairo(color: textSecondary.withValues(alpha: 0.6)),
        prefixIconColor: textSecondary,
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: EdgeInsets.zero,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primary,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w400),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: bgColor,
        selectedColor: primary.withValues(alpha: 0.15),
        labelStyle: GoogleFonts.cairo(fontSize: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: dividerColor),
      ),
      dividerTheme: DividerThemeData(color: dividerColor, thickness: 1),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      dialogTheme: DialogThemeData(
        titleTextStyle: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.w700, color: textPrimary),
        contentTextStyle: GoogleFonts.cairo(fontSize: 15, color: textSecondary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentTextStyle: GoogleFonts.cairo(color: Colors.white, fontSize: 14),
      ),
    );
  }

  static ThemeData darkTheme(Color primary, Color secondary) {
    primaryColor = primary;
    secondaryColor = secondary;
    textPrimary = const Color(0xFFECF0F1);
    textSecondary = const Color(0xFFBDC3C7);
    bgColor = const Color(0xFF121212);
    cardColor = const Color(0xFF1E1E1E);
    dividerColor = const Color(0xFF2C2C2C);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.dark,
        primary: primary,
        secondary: secondary,
        tertiary: accentColor,
        surface: cardColor,
        error: errorColor,
      ),
      scaffoldBackgroundColor: bgColor,
      textTheme: _cairoTextTheme(textPrimary),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 1,
        titleTextStyle: GoogleFonts.cairo(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: secondary,
          side: BorderSide(color: secondary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: secondary,
          textStyle: GoogleFonts.cairo(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2C2C2C),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: secondary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: errorColor),
        ),
        labelStyle: GoogleFonts.cairo(color: textSecondary),
        hintStyle: GoogleFonts.cairo(color: textSecondary.withValues(alpha: 0.6)),
        prefixIconColor: textSecondary,
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: EdgeInsets.zero,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: const Color(0xFF1E1E1E),
        selectedItemColor: secondary,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w400),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF2C2C2C),
        selectedColor: primary.withValues(alpha: 0.3),
        labelStyle: GoogleFonts.cairo(fontSize: 13, color: textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: dividerColor),
      ),
      dividerTheme: DividerThemeData(color: dividerColor, thickness: 1),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cardColor,
        titleTextStyle: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.w700, color: textPrimary),
        contentTextStyle: GoogleFonts.cairo(fontSize: 15, color: textSecondary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cardColor,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentTextStyle: GoogleFonts.cairo(color: Colors.white, fontSize: 14),
      ),
    );
  }

  static BoxDecoration gradientDecoration([Color? c1, Color? c2]) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [c1 ?? primaryColor, c2 ?? secondaryColor],
      ),
    );
  }

  static BoxDecoration get cardDecoration {
    return BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static BoxDecoration get softShadowDecoration {
    return BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 12,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}
