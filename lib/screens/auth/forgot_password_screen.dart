import 'package:buyer_centric_app_v2/routes/app_routes.dart';
import 'package:buyer_centric_app_v2/theme/colors.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:buyer_centric_app_v2/utils/powered_by.dart';
import 'package:buyer_centric_app_v2/utils/screen_size.dart';
import 'package:buyer_centric_app_v2/widgets/custom_text_button.dart';
import 'package:buyer_centric_app_v2/widgets/custom_textfield.dart';
import 'package:buyer_centric_app_v2/services/auth_service.dart';
import 'package:provider/provider.dart';

/*
 * ! IMPORTANT: Password recovery initiation screen
 * 
 * * Key Features:
 * * - Email input for password reset
 * * - Validation
 * * - Firebase password reset
 * 
 * @see LoginScreen
 */

//! Forgot Password Screen - Displays UI for password recovery
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController =
      TextEditingController(); //* Controller for managing email input

  @override
  void dispose() {
    emailController.dispose(); //! Disposing controller to prevent memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  _buildHeader(context), //* Header with back button and logo
                  SizedBox(height: context.screenHeight * 0.05),
                  _buildTitle(context), //* Screen title - "Forgot password?"
                  const SizedBox(height: 8),
                  _buildSubtitle(), //* Instructional subtitle for the user
                  SizedBox(height: context.screenHeight * 0.03),
                  _buildEmailInputField(), //* Email input field
                  SizedBox(height: context.screenHeight * 0.03),
                ],
              ),
            ),
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: context.screenWidth * 0.06),
              child: _buildSendCodeButton(), //* Button to send reset code
            ),
            SizedBox(height: context.screenHeight * 0.32),
            _buildRememberPasswordText(), //* Text for navigating back to login
            const Spacer(),
            PoweredBy(
                size: context.screenSize), //* Powered by widget for footer
          ],
        ),
      ),
    );
  }

  //* Builds the header with back button and logo
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: () {
            Navigator.pop(context); //* Navigates back to the previous screen
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

  //* Title widget for the screen
  Widget _buildTitle(BuildContext context) {
    return Text(
      'Forgot password?',
      style: Theme.of(context).textTheme.displaySmall!.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
    );
  }

  //* Subtitle providing instructions to the user
  Widget _buildSubtitle() {
    return const Text(
      "Don't worry! It happens. Please enter the email associated with your account.",
      style: TextStyle(color: Colors.black54),
    );
  }

  //* Custom email input field
  Widget _buildEmailInputField() {
    return CustomTextField(
      label: 'Email address',
      controller: emailController,
      hintText: 'Enter your email address',
      keyboardType: TextInputType.emailAddress,
    );
  }

  //* Button to trigger sending the reset code
  Widget _buildSendCodeButton() {
    return CustomTextButton(
      backgroundColor: AppColor.buttonGreen,
      fontSize: 16,
      text: 'Send code',
      fontWeight: FontWeight.normal,
      onPressed: () async {
        if (emailController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter your email address')),
          );
          return;
        }

        try {
          final authService = Provider.of<AuthService>(context, listen: false);
          await authService.sendPasswordResetEmail(emailController.text);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Password reset email sent. Please check your inbox.'),
                backgroundColor: Colors.green,
              ),
            );
            // Navigate back to login screen
            Navigator.pop(context);
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(e.toString()),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
    );
  }

  //* Text with a link to navigate back to the login screen
  Widget _buildRememberPasswordText() {
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
                  Navigator.pop(context); //* Navigates back to the login screen
                },
            ),
          ],
        ),
      ),
    );
  }
}
