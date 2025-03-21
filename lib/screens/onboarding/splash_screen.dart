import 'package:buyer_centric_app_v2/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:buyer_centric_app_v2/services/auth_service.dart';
import 'package:buyer_centric_app_v2/routes/app_routes.dart';
import 'package:buyer_centric_app_v2/theme/colors.dart';
import 'package:buyer_centric_app_v2/utils/powered_by.dart';
import 'package:buyer_centric_app_v2/utils/screen_size.dart';
import 'package:buyer_centric_app_v2/widgets/custom_text_button.dart';

//* A stateful widget that represents the splash screen of the app.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    // Check auth state after a short delay to show splash screen
    Future.delayed(const Duration(seconds: 2), () {
      _checkAuthAndNavigate();
    });
  }

  Future<void> _checkAuthAndNavigate() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    
    // Force a check of the authentication state
    await authService.checkAuthState();
    
    if (mounted) {
      _navigateToNextScreen();
    }
  }
  
  void _navigateToNextScreen() {
    final authService = Provider.of<AuthService>(context, listen: false);
    
    if (authService.isAuthenticated) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.getStarted);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 3),
            SvgPicture.asset(
              'assets/svg/logo.svg',
              height: context.screenHeight * 0.15,
            ),
            const Spacer(flex: 2),
            CustomTextButton(
              fontSize: 26,
              text: 'Get Started',
              onPressed: () {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _navigateToNextScreen();
                });
              },
              backgroundColor: AppColor.buttonGreen,
              fontWeight: FontWeight.bold,
            ),
            const Spacer(flex: 1),
            PoweredBy(size: context.screenSize),
            const Spacer(flex: 3),
          ],
        ),
      ),
    );
  }
}
