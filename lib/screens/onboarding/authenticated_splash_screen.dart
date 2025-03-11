import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:buyer_centric_app_v2/theme/colors.dart';
import 'package:buyer_centric_app_v2/utils/powered_by.dart';
import 'package:buyer_centric_app_v2/utils/screen_size.dart';

class AuthenticatedSplashScreen extends StatelessWidget {
  const AuthenticatedSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 3),
            // Logo
            SvgPicture.asset(
              'assets/svg/logo.svg',
              height: context.screenHeight * 0.15,
            ),
            SizedBox(height: context.screenHeight * 0.03),
            // Welcome back text
            Text(
              'Welcome Back!',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: AppColor.appBarColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Spacer(flex: 3),
            // Powered by widget at bottom
            PoweredBy(size: context.screenSize),
          ],
        ),
      ),
    );
  }
}
