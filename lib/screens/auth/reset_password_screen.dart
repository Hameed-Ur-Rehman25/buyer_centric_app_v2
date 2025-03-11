import 'package:buyer_centric_app_v2/routes/app_routes.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:buyer_centric_app_v2/utils/powered_by.dart';
import 'package:buyer_centric_app_v2/utils/screen_size.dart';
import 'package:buyer_centric_app_v2/widgets/custom_text_button.dart';
import 'package:buyer_centric_app_v2/widgets/custom_textfield.dart';

//! Reset Password Screen - Allows users to set a new password
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  //* Controllers for password input fields
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  //* State variables for password visibility
  bool isNewPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context), //* Header with back button and logo
                    const SizedBox(height: 20),
                    _buildTitle(context), //* Title of the screen
                    const SizedBox(height: 13),
                    _buildSubtitle(), //* Subtitle with instructions
                    const SizedBox(height: 30),
                    _buildPasswordField('New password', newPasswordController,
                        isNewPasswordVisible, () {
                      setState(() {
                        isNewPasswordVisible =
                            !isNewPasswordVisible; //* Toggle new password visibility
                      });
                    }),
                    const SizedBox(height: 20),
                    _buildPasswordField(
                        'Confirm new password',
                        confirmPasswordController,
                        isConfirmPasswordVisible, () {
                      setState(() {
                        isConfirmPasswordVisible =
                            !isConfirmPasswordVisible; //* Toggle confirm password visibility
                      });
                    }),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              _buildResetButton(), //* Button to reset password
              SizedBox(height: context.screenHeight * 0.28),
              _buildFooter(context), //* Footer with login option
              SizedBox(height: context.screenHeight * 0.01),
              PoweredBy(size: context.screenSize), //* Powered By widget
            ],
          ),
        ),
      ),
    );
  }

  //* Header with back button and logo
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: () {
            Navigator.pop(context); //! Navigate back to previous screen
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

  //* Title of the screen
  Widget _buildTitle(BuildContext context) {
    return Text(
      'Reset password',
      style: Theme.of(context).textTheme.displaySmall!.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
    );
  }

  //* Subtitle with instructions
  Widget _buildSubtitle() {
    return const Text(
      "Please type something you’ll remember",
      style: TextStyle(color: Colors.black54),
    );
  }

  //* Password input field with visibility toggle
  Widget _buildPasswordField(
    String label,
    TextEditingController controller,
    bool isVisible,
    VoidCallback toggleVisibility,
  ) {
    return CustomTextField(
      label: label,
      controller: controller,
      hintText:
          label == 'New password' ? 'Must be 8 characters' : 'Repeat password',
      obscureText: !isVisible,
      suffixIcon: IconButton(
        icon: Icon(
          isVisible ? Icons.visibility : Icons.visibility_off,
          color: Colors.grey,
        ),
        onPressed: toggleVisibility,
      ),
    );
  }

  //* Button to reset the password
  Widget _buildResetButton() {
    return CustomTextButton(
      text: 'Reset password',
      onPressed: () {
        //! TODO: Implement reset password logic
      },
      fontSize: 16,
      fontWeight: FontWeight.normal,
    );
  }

  //* Footer with login option
  Widget _buildFooter(BuildContext context) {
    return Center(
      child: Text.rich(
        TextSpan(
          text: 'Already have an account? ',
          style: const TextStyle(color: Colors.black54),
          children: [
            TextSpan(
              text: 'Log in',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Navigator.pushReplacementNamed(context, AppRoutes.login);
                }, //! Navigate back to login screen
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    //! Dispose controllers to prevent memory leaks
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
