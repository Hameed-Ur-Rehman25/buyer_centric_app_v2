import 'package:buyer_centric_app_v2/routes/app_routes.dart';
import 'package:buyer_centric_app_v2/theme/text_theme.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kReleaseMode;
import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';

import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
      debugShowCheckedModeBanner: false, // Removes debug banner
      // ignore: deprecated_member_use
      useInheritedMediaQuery: kIsWeb,
      locale: kIsWeb ? DevicePreview.locale(context) : null,
      builder: kIsWeb ? DevicePreview.appBuilder : null,
      theme: AppTheme.lightTheme, // Custom light theme
      initialRoute: AppRoutes.splash, // Initial route
      onGenerateRoute: AppRoutes.generateRoute, // Route generator
    );
  }
}
