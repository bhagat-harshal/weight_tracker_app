import 'package:flutter/material.dart';

class AppTheme {
  // Light theme matching the provided mock (soft background, white cards, iOS-like)
  static ThemeData light(Color primaryColor) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    );

    const radius16 = BorderRadius.all(Radius.circular(16));
    const radius12 = BorderRadius.all(Radius.circular(12));

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      // Soft bluish/gray background similar to the mock
      scaffoldBackgroundColor: const Color(0xFFF6F8FB),
      // Typography
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 48, fontWeight: FontWeight.w700),
        displayMedium: TextStyle(fontSize: 36, fontWeight: FontWeight.w700),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
        bodySmall: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      // AppBar - primary colored with white foreground (Dashboard header uses a custom container)
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
      ),
      // Cards: white surface, rounded, subtle shadow
      cardTheme: const CardThemeData(
        color: Colors.white,
        elevation: 1.5,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: radius16),
      ),
      // Inputs with rounded corners and filled background
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius12,
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius12,
          borderSide: BorderSide(color: primaryColor, width: 1.5),
        ),
        border: const OutlineInputBorder(borderRadius: radius12),
      ),
      // Chips look like segmented controls
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFEFF3F8),
        selectedColor: primaryColor.withOpacity(0.15),
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        selectedShadowColor: Colors.transparent,
        disabledColor: const Color(0xFFEFF3F8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        shape: const StadiumBorder(),
        brightness: Brightness.light,
      ),
      // Switches/checkboxes match primary
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith(
          (s) => s.contains(MaterialState.selected) ? Colors.white : const Color(0xFF9CA3AF),
        ),
        trackColor: MaterialStateProperty.resolveWith(
          (s) => s.contains(MaterialState.selected) ? primaryColor : const Color(0xFFE5E7EB),
        ),
      ),
      // Floating action button for the Add button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 3,
        shape: const CircleBorder(),
      ),
      // Bottom navigation like the mock (labels visible)
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: const Color(0xFF9CA3AF),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        type: BottomNavigationBarType.fixed,
        elevation: 10,
      ),
      dividerColor: const Color(0xFFE5E7EB),
    );
  }
}
