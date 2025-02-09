import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb, kReleaseMode;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:buyer_centric_app_v2/screens/home_screen.dart';
import 'package:buyer_centric_app_v2/screens/splash_screen.dart';
import 'package:buyer_centric_app_v2/theme/colors.dart';
import 'package:device_preview/device_preview.dart';

void main() {
  runApp(
    kIsWeb
        ? DevicePreview(
            enabled: !kReleaseMode,
            builder: (context) => const MyApp(),
          )
        : const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Buyer Centric App',
      useInheritedMediaQuery: kIsWeb,
      locale: kIsWeb ? DevicePreview.locale(context) : null,
      builder: kIsWeb ? DevicePreview.appBuilder : null,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColor.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColor.white,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(
          const TextTheme(
            displayLarge: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColor.white),
            displayMedium: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColor.white),
            displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            headlineMedium: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColor.white),
            headlineSmall: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColor.white),
            bodyLarge: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: AppColor.white,
            ),
            bodyMedium: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: AppColor.white),
            bodySmall: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: AppColor.white),
            labelSmall: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.normal,
                color: AppColor.white),
          ),
        ),
        fontFamily: GoogleFonts.poppins().fontFamily,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColor.white),
      ),
      home: const SplashScreen(),
    );
  }
}
