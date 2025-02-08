import 'package:buyer_centric_app_v2/screens/home_screen.dart';
import 'package:buyer_centric_app_v2/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// void main() => runApp(
//       kReleaseMode
//           ? const MyApp()
//           : DevicePreview(
//               enabled: !kReleaseMode,
//               builder: (context) => const MyApp(), // Wrap your app
//             ),
//     );
void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Buyer Centric App',
      // ignore: deprecated_member_use
      // useInheritedMediaQuery: true,
      // locale: DevicePreview.locale(context),
      // builder: DevicePreview.appBuilder,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColor.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColor.white,
        ),
        // Define a custom TextTheme using Poppins
        textTheme: GoogleFonts.poppinsTextTheme(
          const TextTheme(
            // Headline styles
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

            // Medium body text
            bodyLarge: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: AppColor.white,
            ),
            bodyMedium: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: AppColor.white),

            // Small text
            bodySmall: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: AppColor.white), // Caption
            labelSmall: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.normal,
                color: AppColor.white), // Overline
          ),
        ),
        // Set Poppins as the default font family
        fontFamily: GoogleFonts.poppins().fontFamily,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColor.white),
      ),
      home: HomeScreen(),
    );
  }
}
