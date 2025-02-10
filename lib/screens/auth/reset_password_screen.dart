import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:buyer_centric_app_v2/utils/powered_by.dart';
import 'package:buyer_centric_app_v2/utils/screen_size.dart';
import 'package:buyer_centric_app_v2/widgets/custom_text_button.dart';
import 'package:buyer_centric_app_v2/widgets/custom_textfield.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool isPasswordVisible = false;

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
                    _buildHeader(context),
                    const SizedBox(height: 20),
                    _buildTitle(context),
                    const SizedBox(height: 8),
                    _buildSubtitle(),
                    const SizedBox(height: 20),
                    _buildPasswordField('New password', newPasswordController),
                    const SizedBox(height: 20),
                    _buildPasswordField(
                        'Confirm new password', confirmPasswordController),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              _buildResetButton(),
              SizedBox(height: context.screenHeight * 0.28),
              _buildFooter(context),
              SizedBox(height: context.screenHeight * 0.02),
              PoweredBy(size: context.screenSize),
            ],
          ),
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
            //   MaterialPageRoute(
            //       builder: (context) => const LoginScreen()),
            // );
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
      'Reset password',
      style: Theme.of(context).textTheme.displaySmall!.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildSubtitle() {
    return const Text(
      "Please type something you’ll remember",
      style: TextStyle(color: Colors.black54),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller) {
    return CustomTextField(
      label: label,
      controller: controller,
      hintText:
          label == 'New password' ? 'Must be 8 characters' : 'Repeat password',
      obscureText: !isPasswordVisible,
      suffixIcon: IconButton(
        icon: Icon(
          isPasswordVisible ? Icons.visibility : Icons.visibility_off,
          color: Colors.grey,
        ),
        onPressed: () {
          setState(() {
            isPasswordVisible = !isPasswordVisible;
          });
        },
      ),
    );
  }

  Widget _buildResetButton() {
    return CustomTextButton(
      text: 'Reset password',
      onPressed: () {
        // Handle reset password logic
      },
      fontSize: 16,
      fontWeight: FontWeight.normal,
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Center(
      child: Text.rich(
        TextSpan(
          text: 'Already have an account? ',
          style: TextStyle(color: Colors.black54),
          children: [
            TextSpan(
              text: 'Log in',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Navigator.pop(context);
                },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
