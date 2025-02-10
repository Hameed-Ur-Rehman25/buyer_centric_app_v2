import 'package:buyer_centric_app_v2/utils/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:buyer_centric_app_v2/routes/app_routes.dart';
import 'package:buyer_centric_app_v2/theme/colors.dart';
import 'package:buyer_centric_app_v2/utils/powered_by.dart';
import 'package:buyer_centric_app_v2/widgets/custom_text_button.dart';
import 'package:buyer_centric_app_v2/widgets/custom_textfield.dart';

//! Sign Up Screen - Handles user registration
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  //* Controllers for text fields
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  //* State variables for password visibility and terms acceptance
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _acceptTerms = false;

  @override
  void dispose() {
    //! Disposing controllers to prevent memory leaks
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.screenWidth * 0.06,
              ).copyWith(
                bottom: 0,
                top: context.screenHeight * 0.02,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context), //* Header with back button and logo
                  SizedBox(height: context.screenHeight * 0.03),
                  _buildTitle(context), //* Title for the Sign-Up screen
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: context.screenWidth * 0.06,
                ),
                child: Column(
                  children: [
                    SizedBox(height: context.screenHeight * 0.025),
                    _buildTextFields(), //* Text fields for user input
                    SizedBox(height: context.screenHeight * 0.005),
                    _buildTermsAndConditions(), //* Terms and conditions checkbox
                  ],
                ),
              ),
            ),
            Column(
              children: [
                _buildSignUpButton(), //* Sign-up button
                SizedBox(height: context.screenHeight * 0.02),
                _buildLoginOption(), //* Option to navigate to login screen
                const SizedBox(height: 20),
                PoweredBy(size: context.screenSize), //* Powered by widget
              ],
            ),
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
            Navigator.pushReplacementNamed(context,
                AppRoutes.getStarted); //* Navigate back to Get Started screen
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

  //* Builds the screen title
  Widget _buildTitle(BuildContext context) {
    return Text(
      'Sign Up',
      style: Theme.of(context)
          .textTheme
          .displayMedium
          ?.copyWith(color: Colors.black),
    );
  }

  //* Builds the text fields for user input
  Widget _buildTextFields() {
    return Column(
      children: [
        CustomTextField(
          label: 'Username',
          hintText: 'Your username',
          controller: _usernameController,
        ),
        SizedBox(height: context.screenHeight * 0.02),
        CustomTextField(
          label: 'Email',
          hintText: 'example@gmail.com',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: context.screenHeight * 0.02),
        CustomTextField(
          label: 'Create a password',
          hintText: 'Must be at least 8 characters',
          controller: _passwordController,
          obscureText: !_isPasswordVisible,
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            ),
            onPressed: () {
              setState(() {
                _isPasswordVisible =
                    !_isPasswordVisible; //* Toggle password visibility
              });
            },
          ),
        ),
        SizedBox(height: context.screenHeight * 0.02),
        CustomTextField(
          label: 'Confirm password',
          hintText: 'Repeat password',
          controller: _confirmPasswordController,
          obscureText: !_isConfirmPasswordVisible,
          suffixIcon: IconButton(
            icon: Icon(
              _isConfirmPasswordVisible
                  ? Icons.visibility
                  : Icons.visibility_off,
            ),
            onPressed: () {
              setState(() {
                _isConfirmPasswordVisible =
                    !_isConfirmPasswordVisible; //* Toggle confirm password visibility
              });
            },
          ),
        ),
      ],
    );
  }

  //* Builds the terms and conditions checkbox
  Widget _buildTermsAndConditions() {
    return Row(
      children: [
        Checkbox(
          value: _acceptTerms,
          activeColor: AppColor.black,
          shape: const CircleBorder(),
          onChanged: (value) {
            setState(() {
              _acceptTerms = value ?? false; //* Toggle acceptance of terms
            });
          },
        ),
        Expanded(
          child: Text(
            'I accept the terms and privacy policy',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.black),
          ),
        ),
      ],
    );
  }

  //* Builds the sign-up button
  Widget _buildSignUpButton() {
    return CustomTextButton(
      onPressed: () {
        if (_acceptTerms) {
          //! TODO: Implement sign-up logic
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please accept the terms and conditions.'),
            ),
          ); //! Show error if terms not accepted
        }
      },
      fontSize: 16,
      text: 'Sign up',
      fontWeight: FontWeight.w600,
    );
  }

  //* Option for users who already have an account
  Widget _buildLoginOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Already have an account? ",
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: Colors.black),
        ),
        InkWell(
          onTap: () {
            Navigator.pushReplacementNamed(
                context, AppRoutes.login); //* Navigate to login screen
          },
          child: Text(
            "Log in",
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.black, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
