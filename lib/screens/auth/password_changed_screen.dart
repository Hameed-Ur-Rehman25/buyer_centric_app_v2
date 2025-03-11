import 'package:buyer_centric_app_v2/utils/powered_by.dart';
import 'package:buyer_centric_app_v2/utils/screen_size.dart';
import 'package:buyer_centric_app_v2/widgets/custom_text_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

//! Password Changed Screen - Confirmation screen after password reset
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
                  _buildHeader(context), //* App header with logo
                  SizedBox(height: context.screenHeight * 0.18),
                  _buildIllustration(), //* Illustration image
                  SizedBox(height: context.screenHeight * 0.05),
                  _buildTitle(context), //* Title indicating password change
                  SizedBox(height: context.screenHeight * 0.01),
                  _buildSubtitle(), //* Subtitle with success message
                  SizedBox(height: context.screenHeight * 0.03),
                ],
              ),
            ),
            _buildBackToLoginButton(), //* Button to navigate back to login
            const Spacer(),
            PoweredBy(
                size: context.screenSize), //* Footer with "Powered By" widget
          ],
        ),
      ),
    );
  }

  //* App header with logo
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        const Spacer(),
        SvgPicture.asset(
          'assets/svg/logo.svg',
          height: context.screenHeight * 0.06,
        ),
      ],
    );
  }

  //* Illustration image widget
  Widget _buildIllustration() {
    return Image.asset(
      'assets/images/Group 36678.jpg',
      height: 100,
    );
  }

  //* Title indicating password change success
  Widget _buildTitle(BuildContext context) {
    return Text(
      'Password Changed',
      style: Theme.of(context).textTheme.displayMedium!.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
    );
  }

  //* Subtitle providing confirmation message
  Widget _buildSubtitle() {
    return Text(
      "Your password has been changed successfully",
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.black54,
        fontSize: 15,
        fontFamily: GoogleFonts.inter().fontFamily,
      ),
    );
  }

  //* Button to navigate back to the login screen
  Widget _buildBackToLoginButton() {
    return CustomTextButton(
      fontSize: 16,
      text: 'Back to login',
      fontWeight: FontWeight.normal,
      onPressed: () {
        //! TODO: Implement navigation to login screen
      },
    );
  }
}
