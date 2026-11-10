import 'package:flutter/material.dart';

class AppTheme {
  static const Color yellow = Color(0xFFF6BD00);
  static const Color background = Color(0xFF121312);
  static const Color surface = Color(0xFF282A28);
  static const Color red = Color(0xFFE82626);

  static const RoundedRectangleBorder buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(15)),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: background,
    appBarTheme: const AppBarThemeData(
      backgroundColor: background,
      foregroundColor: yellow,
      centerTitle: true,
    ),
    inputDecorationTheme: const InputDecorationThemeData(
      hintStyle: TextStyle(color: Colors.white),
      prefixIconColor: Colors.white,
      filled: true,
      fillColor: surface,
      contentPadding: EdgeInsets.symmetric(vertical: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(15)),
        borderSide: BorderSide.none,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: yellow,
        foregroundColor: background,
        elevation: 0,
        shape: buttonShape,
        textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: yellow,
        side: const BorderSide(color: yellow, width: 2),
        shape: buttonShape,
        textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      backgroundColor: surface,
      elevation: 0,
      selectedItemColor: yellow,
      unselectedItemColor: Colors.white,
      showSelectedLabels: false,
      showUnselectedLabels: false,
    ),
  );
}
