import 'package:buyer_centric_app_v2/routes/app_routes.dart';
import 'package:buyer_centric_app_v2/screens/auth/password_changed_screen.dart';
import 'package:buyer_centric_app_v2/theme/text_theme.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kReleaseMode;
import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';

//TODO: APP ROUTING
//TODO: Auth Screen UI
//TODO: Firebase Integration and Auth Auth Screen Backend
//TODO: Sign up with Facebook Google and Apple(maybe late due to Xcode)

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
      // ignore: deprecated_member_use
      useInheritedMediaQuery: kIsWeb,
      locale: kIsWeb ? DevicePreview.locale(context) : null,
      builder: kIsWeb ? DevicePreview.appBuilder : null,
      theme: AppTheme.lightTheme, // Imported from app_theme.dart
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.generateRoute,
      // home: const PasswordChangedScreen(),
    );
  }
}
