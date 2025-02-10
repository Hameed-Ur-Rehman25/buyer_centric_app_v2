import 'package:buyer_centric_app_v2/screens/auth/forgot_password_screen.dart';
import 'package:buyer_centric_app_v2/screens/auth/login_screen.dart';
import 'package:buyer_centric_app_v2/screens/auth/password_changed_screen.dart';
import 'package:buyer_centric_app_v2/screens/auth/reset_password_screen.dart';
import 'package:buyer_centric_app_v2/screens/auth/signup_screen.dart';
import 'package:buyer_centric_app_v2/screens/onboarding/get_started_screen.dart';
import 'package:flutter/material.dart';
import 'package:buyer_centric_app_v2/screens/home_screen.dart';
import 'package:buyer_centric_app_v2/screens/onboarding/splash_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String home = '/home';
  static const String getStarted = '/get-started';
  static const String login = '/login';
  static const String signUp = '/sign-up';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String passwordChanged = '/password-changed';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case getStarted:
        return MaterialPageRoute(builder: (_) => const GetStartedScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case signUp:
        return MaterialPageRoute(builder: (_) => const SignUpScreen());
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case resetPassword:
        return MaterialPageRoute(builder: (_) => const ResetPasswordScreen());
      case passwordChanged:
        return MaterialPageRoute(builder: (_) => const PasswordChangedScreen());
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
