import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:buyer_centric_app_v2/services/auth_service.dart';
import 'package:buyer_centric_app_v2/routes/app_routes.dart';
import 'package:buyer_centric_app_v2/theme/colors.dart';
import 'package:buyer_centric_app_v2/utils/powered_by.dart';
import 'package:buyer_centric_app_v2/utils/screen_size.dart';
import 'package:buyer_centric_app_v2/widgets/custom_text_button.dart';
import 'package:buyer_centric_app_v2/screens/onboarding/authenticated_splash_screen.dart';

/// A stateful widget that represents the splash screen of the app.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    final authService = Provider.of<AuthService>(context, listen: false);

    if (!mounted) return;

    if (authService.isAuthenticated) {
      // Show authenticated splash screen and navigate to home
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const AuthenticatedSplashScreen(),
          ),
        );
      }
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.getStarted);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

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
            if (!authService.isAuthenticated) ...[
              CustomTextButton(
                fontSize: 26,
                text: 'Get Started',
                onPressed: () {
                  Navigator.pushReplacementNamed(context, AppRoutes.getStarted);
                },
                backgroundColor: AppColor.buttonGreen,
                fontWeight: FontWeight.bold,
              ),
              const Spacer(flex: 1),
            ],
            PoweredBy(size: context.screenSize),
            if (authService.isAuthenticated) const Spacer(flex: 3),
          ],
        ),
      ),
    );
  }
}
