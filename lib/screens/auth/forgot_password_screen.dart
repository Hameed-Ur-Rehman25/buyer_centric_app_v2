import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:buyer_centric_app_v2/screens/auth/reset_password_screen.dart';
import 'package:buyer_centric_app_v2/utils/powered_by.dart';
import 'package:buyer_centric_app_v2/utils/screen_size.dart';
import 'package:buyer_centric_app_v2/widgets/custom_text_button.dart';
import 'package:buyer_centric_app_v2/widgets/custom_textfield.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  SizedBox(height: context.screenHeight * 0.05),
                  _buildTitle(context),
                  const SizedBox(height: 8),
                  _buildSubtitle(),
                  SizedBox(height: context.screenHeight * 0.03),
                  _buildEmailInputField(emailController),
                  SizedBox(height: context.screenHeight * 0.03),
                ],
              ),
            ),
            _buildSendCodeButton(context),
            SizedBox(height: context.screenHeight * 0.32),
            _buildRememberPasswordText(context),
            const Spacer(),
            PoweredBy(size: context.screenSize),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: () {
            // Navigator.pushReplacement(
            //   context,
            //   MaterialPageRoute(builder: (context) => const LoginScreen()),
            // );

            Navigator.pop(context);
          },
          child: SvgPicture.asset(
            'assets/images/Back.svg',
            height: context.screenHeight * 0.04,
          ),
        ),
        const Spacer(),
        SvgPicture.asset(
          'assets/svg/logo.svg',
          height: context.screenHeight * 0.06,
        ),
      ],
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      'Forgot password?',
      style: Theme.of(context).textTheme.displaySmall!.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildSubtitle() {
    return const Text(
      "Don’t worry! It happens. Please enter the email associated with your account.",
      style: TextStyle(color: Colors.black54),
    );
  }

  Widget _buildEmailInputField(TextEditingController emailController) {
    return CustomTextField(
      label: 'Email address',
      controller: emailController,
      hintText: 'Enter your email address',
      keyboardType: TextInputType.emailAddress,
    );
  }

  Widget _buildSendCodeButton(BuildContext context) {
    return CustomTextButton(
      fontSize: 16,
      text: 'Send code',
      fontWeight: FontWeight.normal,
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ResetPasswordScreen()),
        );
      },
    );
  }

  Widget _buildRememberPasswordText(BuildContext context) {
    return Center(
      child: Text.rich(
        TextSpan(
          text: 'Remember password? ',
          style: const TextStyle(color: Colors.black54),
          children: [
            TextSpan(
              text: 'Log in',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  // Navigator.pushReplacement(
                  //   context,
                  //   MaterialPageRoute(
                  //       builder: (context) => const LoginScreen()),
                  // );
                  Navigator.pop(context);
                },
            ),
          ],
        ),
      ),
    );
  }
}
