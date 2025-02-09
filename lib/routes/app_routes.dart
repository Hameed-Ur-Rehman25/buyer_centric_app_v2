import 'package:buyer_centric_app_v2/screens/get_started_screen.dart';
import 'package:flutter/material.dart';
import 'package:buyer_centric_app_v2/screens/home_screen.dart';
import 'package:buyer_centric_app_v2/screens/splash_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String home = '/home';
  static const String getStarted = '/getstarted';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case getStarted:
        return MaterialPageRoute(builder: (_) => const GetStartedScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('404 - Page Not Found')),
          ),
        );
    }
  }
}
