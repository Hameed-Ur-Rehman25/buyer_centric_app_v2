import 'package:buyer_centric_app_v2/theme/colors.dart';
import 'package:buyer_centric_app_v2/utils/powered_by.dart';
import 'package:buyer_centric_app_v2/widgets/custom_text_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            const Spacer(
              flex: 2,
            ),

            Image.asset('assets/images/Illustration.png', width: 280),
            const Spacer(
              flex: 1,
            ),

            //* Explore the App
            Text(
              'Explore the App',
              style: Theme.of(context).textTheme.displayMedium!.copyWith(
                    color: AppColor.black,
                  ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Text(
                'Now your finances are in one place and always under control',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: AppColor.black,
                    ),
              ),
            ),
            const Spacer(
              flex: 1,
            ),
            CustomTextButton(
              fontSize: 16,
              text: 'Log in',
              onPressed: () {},
              fontWeight: FontWeight.w500,
            ),
            const SizedBox(
              height: 15,
            ),
            CustomTextButton(
              fontSize: 16,
              text: 'Create Account',
              onPressed: () {},
              fontWeight: FontWeight.w700,
              backgroundColor: AppColor.white,
            ),
            Spacer(
              flex: 1,
            ),
            PoweredBy(size: size),
          ],
        ),
      ),
    );
  }
}
