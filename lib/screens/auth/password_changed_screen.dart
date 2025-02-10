import 'package:buyer_centric_app_v2/utils/powered_by.dart';
import 'package:buyer_centric_app_v2/utils/screen_size.dart';
import 'package:buyer_centric_app_v2/widgets/custom_text_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class PasswordChangedScreen extends StatelessWidget {
  const PasswordChangedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Spacer(),
                      SvgPicture.asset(
                        'assets/svg/logo.svg',
                        height: context.screenHeight * 0.06,
                      ),
                    ],
                  ),
                  SizedBox(height: context.screenHeight * 0.18),
                  Image.asset(
                    'assets/images/Illustration.png',
                    height: 100,
                  ),
                  SizedBox(height: context.screenHeight * 0.05),
                  Text(
                    'Password Changed',
                    style: Theme.of(context).textTheme.displayMedium!.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  SizedBox(height: context.screenHeight * 0.01),
                  Text(
                    "Your password has been changed successfully",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54),
                  ),
                  SizedBox(height: context.screenHeight * 0.03),
                ],
              ),
            ),
            CustomTextButton(
              fontSize: 16,
              text: 'Back to login',
              fontWeight: FontWeight.normal,
              onPressed: () {},
            ),
            Spacer(),
            PoweredBy(size: context.screenSize),
          ],
        ),
      ),
    );
  }
}
