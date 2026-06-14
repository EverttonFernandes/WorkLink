import 'package:flutter/material.dart';

const workLinkGreen = Color(0xFF16C35B);
const workLinkDark = Color(0xFF10233F);
const workLinkSurface = Color(0xFFF7FBF8);

ThemeData buildWorkLinkTheme({String? fontFamily}) {
  return ThemeData(
    fontFamily: fontFamily,
    useMaterial3: true,
    splashFactory: InkRipple.splashFactory,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: ColorScheme.fromSeed(
      seedColor: workLinkGreen,
      primary: workLinkGreen,
      secondary: const Color(0xFF7D8FA8),
      surface: workLinkSurface,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: workLinkDark,
      elevation: 0,
      centerTitle: false,
      surfaceTintColor: Colors.white,
      titleTextStyle: TextStyle(
        color: workLinkDark,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 18,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(color: Color(0xFFD7E0EA)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(color: Color(0xFFD7E0EA)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(color: workLinkGreen, width: 1.4),
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: const BorderSide(color: Color(0xFFE4EBF2)),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFFEAF8EF),
      selectedColor: const Color(0xFFEAF8EF),
      side: const BorderSide(color: Color(0xFFBFEBCF)),
      labelStyle: const TextStyle(
        color: workLinkDark,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: workLinkGreen,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(58),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: workLinkGreen,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}
