import 'package:buyer_centric_app_v2/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:buyer_centric_app_v2/routes/app_routes.dart';
import 'package:buyer_centric_app_v2/services/auth_service.dart';
import 'package:buyer_centric_app_v2/utils/powered_by.dart';
import 'package:buyer_centric_app_v2/utils/screen_size.dart';
import 'package:buyer_centric_app_v2/utils/snackbar.dart';
import 'package:buyer_centric_app_v2/widgets/custom_social_media_button.dart';
import 'package:buyer_centric_app_v2/widgets/custom_text_button.dart';
import 'package:buyer_centric_app_v2/widgets/custom_textfield.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

/*
 * ! IMPORTANT: User authentication login screen
 * 
 * * Key Features:
 * * - Email/Password login
 * * - Form validation
 * * - Error handling
 * * - Firebase Authentication
 * * - Navigation to signup/forgot password
 * 
 */

//! Login Screen - Handles user authentication
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // * Form controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isPasswordVisible = false; //? Toggles password visibility
  bool _isLogging = false;

  @override
  void dispose() {
    //! Dispose controllers to prevent memory leaks
    _emailController.dispose();
    _passwordController.dispose();
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
                      _buildLoginButton(), //* Login button
                      SizedBox(height: context.screenHeight * 0.02),
                      _buildDivider(context), //* Divider with text
                      SizedBox(height: context.screenHeight * 0.02),
                      _buildSocialLoginIcons(context), //* Social login icons
                      // SizedBox(height: context.screenHeight * 0.025),
                      const Spacer(
                        flex: 4,
                      ),
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
      controller: _emailController,
      suffixIcon: const Icon(Icons.check_circle, color: Colors.black),
    );
  }

  //* Password input field with visibility toggle
  Widget _buildPasswordField() {
    return CustomTextField(
      label: 'Password',
      hintText: 'Enter your password',
      controller: _passwordController,
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
  Widget _buildLoginButton() {
    return CustomTextButton(
      backgroundColor: AppColor.buttonGreen,
      text: _isLogging ? 'Logging in...' : 'Log in',
      onPressed: _isLogging ? null : _handleLogin,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      isLoading: _isLogging,
    );
  }

  // ! Critical: Handles user login
  Future<void> _handleLogin() async {
    setState(() {
      _isLogging = true;
    });

    // Create a timeout mechanism
    bool isTimedOut = false;
    Timer? loginTimer;

    loginTimer = Timer(const Duration(seconds: 15), () {
      if (_isLogging && mounted) {
        isTimedOut = true;
        setState(() {
          _isLogging = false;
        });
        CustomSnackbar.showError(context, 'Login timed out. Please try again.');
      }
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );

      // Check if email is verified
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.emailVerified) {
        // Send verification email again
        await user.sendEmailVerification();
        
        if (!mounted) return;
        setState(() {
          _isLogging = false;
        });
        
        CustomSnackbar.showError(
          context,
          'Please verify your email first. A new verification email has been sent.',
        );
        return;
      }

      if (!mounted) return;
      setState(() {
        _isLogging = false;
      });

      // Navigate to home screen
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLogging = false;
      });
      CustomSnackbar.showError(context, e.toString());
    } finally {
      loginTimer?.cancel();
    }
  }

  //* Divider with text "Or Login with"
  Widget _buildDivider(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            'Or Login with',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  // ignore: deprecated_member_use
                  color: Colors.black.withOpacity(0.4),
                ),
          ),
        ),
        const Expanded(
          child: Divider(),
        ),
      ],
    );
  }

  //* Social login icons (Facebook, Google, Apple)
  //TODO: SOCIAL MEDIA LOGIN ICONS METHODS
  Widget _buildSocialLoginIcons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Icon(Icons.facebook, size: context.screenWidth * 0.1),
        CustomSocialMediaButton(
            imagePath: 'assets/icons/fb_logo.jpg', onPressed: () {}),
        // Icon(Icons.g_mobiledata, size: context.screenWidth * 0.1),
        CustomSocialMediaButton(
            imagePath: 'assets/icons/google_logo.jpg', onPressed: () {}),
        // Icon(Icons.apple, size: context.screenWidth * 0.1),
        CustomSocialMediaButton(
            imagePath: 'assets/icons/apple_logo.jpg', onPressed: () {}),
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
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
