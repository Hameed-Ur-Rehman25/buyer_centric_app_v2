import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../screens/auth/login_screen.dart';

class RouteGuard {
  static Widget protectRoute(Widget page) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        if (!authService.isAuthenticated) {
          return const LoginScreen();
        }
        return page;
      },
    );
  }
}
