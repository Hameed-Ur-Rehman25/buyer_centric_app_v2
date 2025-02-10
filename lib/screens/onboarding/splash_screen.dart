import 'package:buyer_centric_app_v2/routes/app_routes.dart';
import 'package:buyer_centric_app_v2/screens/onboarding/get_started_screen.dart';
import 'package:buyer_centric_app_v2/theme/colors.dart';
import 'package:buyer_centric_app_v2/utils/powered_by.dart';
import 'package:buyer_centric_app_v2/utils/screen_size.dart';
import 'package:buyer_centric_app_v2/widgets/custom_text_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            const Spacer(
              flex: 3,
            ),
            SvgPicture.asset('assets/svg/logo.svg'),
            const Spacer(
              flex: 2,
            ),

            //TODO: routing
            CustomTextButton(
              fontSize: 26,
              text: 'Get Started',
              onPressed: () {
                // print('Button pressed');
                // Navigator.pushReplacement(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => const GetStartedScreen(),
                //   ),
                // );
                Navigator.pushReplacementNamed(context, AppRoutes.getStarted);
              },
              backgroundColor: AppColor.buttonGreen,
              fontWeight: FontWeight.bold,
            ),
            Spacer(
              flex: 1,
            ),
            PoweredBy(size: context.screenSize),
          ],
        ),
      ),
    );
  }
}
