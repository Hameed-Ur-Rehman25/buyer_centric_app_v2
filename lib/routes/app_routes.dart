import 'package:buyer_centric_app_v2/screens/auth/forgot_password_screen.dart';
import 'package:buyer_centric_app_v2/screens/auth/login_screen.dart';
import 'package:buyer_centric_app_v2/screens/auth/password_changed_screen.dart';
import 'package:buyer_centric_app_v2/screens/auth/reset_password_screen.dart';
import 'package:buyer_centric_app_v2/screens/auth/signup_screen.dart';
import 'package:buyer_centric_app_v2/screens/buy%20car/buy_car_screen.dart';
import 'package:buyer_centric_app_v2/screens/car%20details/car_details_screen.dart';
import 'package:buyer_centric_app_v2/screens/home/utils/sell_car_screen.dart';
import 'package:buyer_centric_app_v2/screens/onboarding/get_started_screen.dart';
import 'package:buyer_centric_app_v2/screens/upload/add_car_screen.dart';
import 'package:buyer_centric_app_v2/screens/upload/add_parts_screen.dart';
import 'package:buyer_centric_app_v2/screens/upload/upload_screen.dart';
import 'package:flutter/material.dart';
import 'package:buyer_centric_app_v2/screens/home/home_screen.dart';
import 'package:buyer_centric_app_v2/screens/onboarding/splash_screen.dart';
import 'package:buyer_centric_app_v2/routes/route_guard.dart';
import 'package:buyer_centric_app_v2/screens/chat/chat_screen.dart';
import 'package:buyer_centric_app_v2/screens/buy%20car/create_car_post_screen.dart';
import 'package:buyer_centric_app_v2/screens/profile/user_cars/user_cars_screen.dart';
import 'package:buyer_centric_app_v2/screens/user_inventory/user_car_inventory_screen.dart';
import 'package:buyer_centric_app_v2/screens/user_inventory/user_car_part_inventory_screen.dart';

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
  static const String carDetails = '/car-details';
  static const String chat = '/chat';
  static const String upload = '/upload';
  static const String addCar = '/add-car';
  static const String addParts = '/add-parts';
  static const String createPost = '/create-post';
  static const String userCars = '/user-cars';
  static const String userInventory = '/user-inventory';
  static const String userPartInventory = '/user-part-inventory';

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
          case chat:
            final args = settings.arguments as Map<String, dynamic>;
            return ChatScreen(postId: args['postId'], carName: args['carName']);
          case upload:
            return const UploadScreen();
          case addCar:
            return AddCarScreen(context);
          case addParts:
            return const AddPartsScreen();
          case createPost:
            final args = settings.arguments as Map<String, dynamic>;
            return RouteGuard.protectRoute(
              CreateCarPostScreen(
                make: args['make'],
                key: args['make'],
                model: args['model'],
                year: args['year'],
                imageUrl: args['imageUrl'],
              ),
            );
          case carDetails:
            final args = settings.arguments as Map<String, dynamic>;
            return CarDetailsScreen(
              image: args['image'] ?? '',
              carName: args['carName'] ?? '',
              lowRange: args['lowRange'] ?? 0,
              highRange: args['highRange'] ?? 0,
              description: args['description'] ?? '',
              index: args['index'] ?? '',
              userId: args['userId'] ?? '',
            );
          case userCars:
            return RouteGuard.protectRoute(const UserCarsScreen());
          case userInventory:
            return RouteGuard.protectRoute(const UserCarInventoryScreen());
          case userPartInventory:
            return RouteGuard.protectRoute(const UserCarPartInventoryScreen());
          default:
            return const Scaffold(
              body: Center(child: Text('404 - Page Not Found')),
            );
        }
      },
    );
  }
}
