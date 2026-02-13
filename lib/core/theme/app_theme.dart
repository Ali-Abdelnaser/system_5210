import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // الألوان الأساسية الخاصة بك
  static const Color appRed = Color(0xFFED3D36);
  static const Color appYellow = Color(0xFFFEBE07);
  static const Color appGreen = Color(0xFF47A945);
  static const Color appBlue = Color(0xFF2DA6DD);

  static ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black),
    ),
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: appRed,
      primary: appRed,
      secondary: appGreen,
      tertiary: appBlue,
      surface: Colors.white,
    ),
    textTheme: GoogleFonts.cairoTextTheme().copyWith(
      displayLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      bodyLarge: GoogleFonts.cairo(fontSize: 18, color: Colors.black87),
    ),
  );
}
