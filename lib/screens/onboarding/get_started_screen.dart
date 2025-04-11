import 'package:buyer_centric_app_v2/routes/app_routes.dart';
import 'package:buyer_centric_app_v2/theme/colors.dart';
import 'package:buyer_centric_app_v2/utils/powered_by.dart';
import 'package:buyer_centric_app_v2/utils/screen_size.dart';
import 'package:buyer_centric_app_v2/widgets/custom_text_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

//! Get Started Screen - Introduction screen with login & sign-up options
class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              const Spacer(flex: 2),
              _buildIllustration(), //* Display the main illustration
              const Spacer(flex: 1),
              _buildTitle(context), //* Title of the screen
              const SizedBox(height: 10),
              _buildSubtitle(context), //* Subtitle with brief description
              const Spacer(flex: 1),
              _buildLoginButton(context), //* Button to navigate to Login screen
              const SizedBox(height: 15),
              _buildSignUpButton(
                  context), //* Button to navigate to Sign-Up screen
              const Spacer(flex: 1),
              PoweredBy(
                  size: context.screenSize), //* Footer with "Powered By" widget
            ],
          ),
        ),
      ),
    );
  }

  //* Widget to display the illustration image
  Widget _buildIllustration() {
    return Image.asset(
      'assets/images/Illustration.png',
      width: 280,
    );
  }

  //* Title text widget
  Widget _buildTitle(BuildContext context) {
    return Text(
      'Explore the App',
      style: Theme.of(context).textTheme.displayMedium!.copyWith(
            color: AppColor.black,
          ),
    );
  }

  //* Subtitle text widget
  Widget _buildSubtitle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Text(
        'Now your finances are in one place and always under control',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              color: AppColor.black,
              fontFamily: GoogleFonts.inter().fontFamily,
            ),
      ),
    );
  }

  //* Login button widget
  Widget _buildLoginButton(BuildContext context) {
    return CustomTextButton(
      fontSize: 16,
      text: 'Log in',
      onPressed: () {
        Navigator.pushReplacementNamed(
            context, AppRoutes.login); //! Navigate to Login screen
      },
      fontWeight: FontWeight.w500,
    );
  }

  //* Sign-up button widget
  Widget _buildSignUpButton(BuildContext context) {
    return CustomTextButton(
      fontSize: 16,
      text: 'Create Account',
      onPressed: () {
        Navigator.pushReplacementNamed(
            context, AppRoutes.signUp); //! Navigate to Sign-Up screen
      },
      fontWeight: FontWeight.w500,
      backgroundColor: AppColor.black,
    );
  }
}
