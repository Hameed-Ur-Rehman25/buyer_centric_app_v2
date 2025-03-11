import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:buyer_centric_app_v2/theme/colors.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColor.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColor.white,
    ),
    textTheme: GoogleFonts.poppinsTextTheme(
      const TextTheme(
        displayLarge: TextStyle(
            fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black),
        displayMedium: TextStyle(
            fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
        displaySmall: TextStyle(
            fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
        headlineMedium: TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        headlineSmall: TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        bodyLarge: TextStyle(
            fontSize: 16, fontWeight: FontWeight.normal, color: Colors.black),
        bodyMedium: TextStyle(
            fontSize: 14, fontWeight: FontWeight.normal, color: Colors.black),
        bodySmall: TextStyle(
            fontSize: 12, fontWeight: FontWeight.normal, color: Colors.black),
        labelSmall: TextStyle(
            fontSize: 10, fontWeight: FontWeight.normal, color: Colors.black),
      ),
    ),
    fontFamily: GoogleFonts.poppins().fontFamily,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColor.white),
  );
}
