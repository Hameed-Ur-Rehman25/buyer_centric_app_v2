import 'package:buyer_centric_app_v2/screens/auth/forgot_password_screen.dart';
import 'package:buyer_centric_app_v2/screens/auth/login_screen.dart';
import 'package:buyer_centric_app_v2/screens/auth/password_changed_screen.dart';
import 'package:buyer_centric_app_v2/screens/auth/reset_password_screen.dart';
import 'package:buyer_centric_app_v2/screens/auth/signup_screen.dart';
import 'package:buyer_centric_app_v2/screens/buy_car_screen.dart';
import 'package:buyer_centric_app_v2/screens/home/utils/sell_car_screen.dart';
import 'package:buyer_centric_app_v2/screens/onboarding/get_started_screen.dart';
import 'package:flutter/material.dart';
import 'package:buyer_centric_app_v2/screens/home/home_screen.dart';
import 'package:buyer_centric_app_v2/screens/onboarding/splash_screen.dart';
import 'package:buyer_centric_app_v2/routes/route_guard.dart';

class AppRoutes {
  static const String splash = '/';
  static const String home = '/home';
  static const String getStarted = '/get-started';
  static const String login = '/login';
  static const String signUp = '/sign-up';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String passwordChanged = '/password-changed';
  static const String sellCar = '/sell-car';
  static const String buyCar = '/buy-car';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) {
        switch (settings.name) {
          case splash:
            return const SplashScreen();
          case getStarted:
            return const GetStartedScreen();
          case login:
            return const LoginScreen();
          case signUp:
            return const SignUpScreen();
          case forgotPassword:
            return const ForgotPasswordScreen();
          case resetPassword:
            return const ResetPasswordScreen();
          case passwordChanged:
            return const PasswordChangedScreen();
          case home:
            return RouteGuard.protectRoute(const HomeScreen());
          case sellCar:
            return RouteGuard.protectRoute(const SellCarScreen());
          case buyCar:
            return RouteGuard.protectRoute(const BuyCarScreen());

          default:
            return const Scaffold(
              body: Center(child: Text('404 - Page Not Found')),
            );
        }
      },
    );
  }
}
