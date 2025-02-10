import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:buyer_centric_app_v2/routes/app_routes.dart';
import 'package:buyer_centric_app_v2/theme/colors.dart';
import 'package:buyer_centric_app_v2/utils/powered_by.dart';
import 'package:buyer_centric_app_v2/utils/screen_size.dart';
import 'package:buyer_centric_app_v2/widgets/custom_text_button.dart';

/// A stateless widget that represents the splash screen of the app.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            //* Spacer to create space at the top
            const Spacer(
              flex: 3,
            ),
            //* Display the logo
            SvgPicture.asset('assets/svg/logo.svg'),
            //* Spacer to create space between the logo and the button
            const Spacer(
              flex: 2,
            ),
            //* Custom button to navigate to the Get Started screen
            CustomTextButton(
              fontSize: 26,
              text: 'Get Started',
              onPressed: () {
                // Navigate to the Get Started screen
                Navigator.pushReplacementNamed(context, AppRoutes.getStarted);
              },
              backgroundColor: AppColor.buttonGreen,
              fontWeight: FontWeight.bold,
            ),
            //* Spacer to create space between the button and the PoweredBy widget
            Spacer(
              flex: 1,
            ),
            //* Display the PoweredBy widget
            PoweredBy(size: context.screenSize),
          ],
        ),
      ),
    );
  }
}
