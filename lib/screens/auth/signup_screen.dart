import 'package:buyer_centric_app_v2/services/auth_service.dart';
import 'package:buyer_centric_app_v2/utils/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:buyer_centric_app_v2/routes/app_routes.dart';
import 'package:buyer_centric_app_v2/theme/colors.dart';
import 'package:buyer_centric_app_v2/utils/powered_by.dart';
import 'package:buyer_centric_app_v2/utils/screen_size.dart';
import 'package:buyer_centric_app_v2/widgets/custom_text_button.dart';
import 'package:buyer_centric_app_v2/widgets/custom_textfield.dart';
import 'package:provider/provider.dart';

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

  bool _isLoading = false;

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
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
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
                            _buildHeader(
                                context), //* Header with back button and logo
                            SizedBox(height: context.screenHeight * 0.03),
                            _buildTitle(
                                context), //* Title for the Sign-Up screen
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
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: context.screenWidth * 0.06),
                            child: _buildSignUpButton(),
                          ), //* Sign-up button
                          SizedBox(height: context.screenHeight * 0.02),
                          _buildLoginOption(), //* Option to navigate to login screen
                          const SizedBox(height: 20),
                          PoweredBy(
                              size: context.screenSize), //* Powered by widget
                        ],
                      ),
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
      onPressed: _isLoading ? null : _handleSignUp,
      backgroundColor: AppColor.buttonGreen,
      isLoading: _isLoading,
      fontSize: 16,
      text: _isLoading ? 'Signing up...' : 'Sign up',
      fontWeight: FontWeight.w600,
    );
  }

  Future<void> _handleSignUp() async {
    // Validate inputs
    if (!_validateInputs()) return;

    if (!_acceptTerms) {
      CustomSnackbar.showError(
          context, 'Please accept the terms and conditions');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      // Check if email already exists in database
      final userExists = await authService.checkIfUserExists(_emailController.text.trim());
      
      if (userExists) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        CustomSnackbar.showError(context, 'This email is already registered');
        return;
      }

      // Attempt to create the account
      await authService.signUpWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _usernameController.text.trim(),
      );

      if (!mounted) return;

      // Reset loading state
      setState(() {
        _isLoading = false;
      });

      // Show success message and navigate
      CustomSnackbar.showSuccess(
        context,
        'Account created successfully!',
      );

      // Add a small delay to show the success message
      await Future.delayed(const Duration(milliseconds: 800));

      if (!mounted) return;

      // Navigate to home screen and remove all previous routes
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.home,
        (route) => false,
      );

    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      CustomSnackbar.showError(
        context,
        _getErrorMessage(e.toString()),
      );
    }
  }

  bool _validateInputs() {
    if (_usernameController.text.trim().isEmpty) {
      CustomSnackbar.showError(context, 'Please enter a username');
      return false;
    }

    if (_emailController.text.trim().isEmpty) {
      CustomSnackbar.showError(context, 'Please enter an email');
      return false;
    }

    if (!_isValidEmail(_emailController.text.trim())) {
      CustomSnackbar.showError(context, 'Please enter a valid email');
      return false;
    }

    if (_passwordController.text.isEmpty) {
      CustomSnackbar.showError(context, 'Please enter a password');
      return false;
    }

    if (_passwordController.text.length < 8) {
      CustomSnackbar.showError(
          context, 'Password must be at least 8 characters long');
      return false;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      CustomSnackbar.showError(context, 'Passwords do not match');
      return false;
    }

    return true;
  }

  bool _isValidEmail(String email) {
    return RegExp(
      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
    ).hasMatch(email);
  }

  String _getErrorMessage(String error) {
    if (error.contains('email-already-in-use')) {
      return 'This email is already registered';
    }
    if (error.contains('invalid-email')) {
      return 'Please enter a valid email';
    }
    if (error.contains('weak-password')) {
      return 'Please enter a stronger password';
    }
    return 'Failed to sign up. Please try again.';
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
