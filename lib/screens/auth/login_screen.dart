import 'package:buyer_centric_app_v2/routes/app_routes.dart';
import 'package:buyer_centric_app_v2/theme/colors.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:buyer_centric_app_v2/utils/powered_by.dart';
import 'package:buyer_centric_app_v2/utils/screen_size.dart';
import 'package:buyer_centric_app_v2/widgets/custom_text_button.dart';
import 'package:buyer_centric_app_v2/widgets/custom_textfield.dart';

//! Login Screen - Handles user authentication
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  //* Controllers for managing user input
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isPasswordVisible = false; //? Toggles password visibility

  @override
  void dispose() {
    //! Dispose controllers to prevent memory leaks
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: context.screenWidth * 0.065,
                vertical: context.screenHeight * 0.02,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(
                          context), //* App header with back button and logo
                      SizedBox(height: context.screenHeight * 0.03),
                      _buildTitle(context), //* Title of the screen
                      SizedBox(height: context.screenHeight * 0.025),
                      _buildEmailField(), //* Email input field
                      SizedBox(height: context.screenHeight * 0.02),
                      _buildPasswordField(), //* Password input field
                      SizedBox(height: context.screenHeight * 0.015),
                      _buildForgotPasswordButton(), //* Forgot password link
                      SizedBox(height: context.screenHeight * 0.05),
                      _buildLoginButton(context), //* Login button
                      SizedBox(height: context.screenHeight * 0.02),
                      _buildDivider(context), //* Divider with text
                      SizedBox(height: context.screenHeight * 0.02),
                      _buildSocialLoginIcons(context), //* Social login icons
                      SizedBox(height: context.screenHeight * 0.025),
                      _buildSignUpSection(context), //* Sign-up option
                      const Spacer(),
                      PoweredBy(size: context.screenSize), //* Powered by widget
                    ],
                  ),
                ),
              ),
            );
          },
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
            Navigator.pushReplacementNamed(context,
                AppRoutes.getStarted); //! Navigate to Get Started screen
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

  //* Title widget for the login screen
  Widget _buildTitle(BuildContext context) {
    return Text(
      'Log in',
      style: TextStyle(
        fontSize: context.screenWidth * 0.07,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  //* Email input field
  Widget _buildEmailField() {
    return CustomTextField(
      label: 'Email address',
      hintText: 'Enter your email',
      controller: emailController,
      suffixIcon: const Icon(Icons.check_circle, color: Colors.black),
    );
  }

  //* Password input field with visibility toggle
  Widget _buildPasswordField() {
    return CustomTextField(
      label: 'Password',
      hintText: 'Enter your password',
      controller: passwordController,
      obscureText: !isPasswordVisible,
      suffixIcon: IconButton(
        icon: Icon(
          isPasswordVisible ? Icons.visibility : Icons.visibility_off,
        ),
        onPressed: () {
          setState(() {
            isPasswordVisible =
                !isPasswordVisible; //* Toggle password visibility
          });
        },
      ),
    );
  }

  //* Forgot password button
  Widget _buildForgotPasswordButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.forgotPassword, //! Navigate to Forgot Password screen
          );
        },
        child: const Text(
          'Forgot password?',
          style: TextStyle(color: Colors.black),
        ),
      ),
    );
  }

  //* Login button
  Widget _buildLoginButton(BuildContext context) {
    return CustomTextButton(
      fontSize: (context.screenWidth * 0.045).toInt(),
      text: 'Log in',
      onPressed: () {
        //! TODO: Implement login logic
      },
      fontWeight: FontWeight.w500,
    );
  }

  //* Divider with text "Or Login with"
  Widget _buildDivider(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            'Or Login with',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.black.withOpacity(0.4),
                ),
          ),
        ),
        Expanded(child: Divider()),
      ],
    );
  }

  //* Social login icons (Facebook, Google, Apple)
  Widget _buildSocialLoginIcons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Icon(Icons.facebook, size: context.screenWidth * 0.1),
        Icon(Icons.g_mobiledata, size: context.screenWidth * 0.1),
        Icon(Icons.apple, size: context.screenWidth * 0.1),
      ],
    );
  }

  //* Sign-up section for new users
  Widget _buildSignUpSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.black,
              ),
        ),
        InkWell(
          onTap: () {
            Navigator.pushReplacementNamed(
              context,
              AppRoutes.signUp, //! Navigate to Sign-Up screen
            );
          },
          child: Text(
            "Sign up",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }
}
