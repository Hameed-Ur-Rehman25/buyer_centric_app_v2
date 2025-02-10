import 'package:buyer_centric_app_v2/routes/app_routes.dart';
import 'package:buyer_centric_app_v2/screens/onboarding/get_started_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:buyer_centric_app_v2/screens/auth/login_screen.dart';
import 'package:buyer_centric_app_v2/utils/powered_by.dart';
import 'package:buyer_centric_app_v2/widgets/custom_textfield.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: screenSize.width * 0.06,
                vertical: screenSize.height * 0.02,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context, screenSize),
                      SizedBox(height: screenSize.height * 0.03),
                      _buildTitle(context),
                      SizedBox(height: screenSize.height * 0.025),
                      _buildTextFields(screenSize),
                      SizedBox(height: screenSize.height * 0.02),
                      _buildTermsAndConditions(context),
                      SizedBox(height: screenSize.height * 0.02),
                      _buildSignUpButton(context),
                      SizedBox(height: screenSize.height * 0.02),
                      _buildLoginOption(context),
                      const Spacer(),
                      PoweredBy(size: screenSize),
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

  Widget _buildHeader(BuildContext context, Size screenSize) {
    return Row(
      children: [
        InkWell(
          onTap: () {
            Navigator.pushReplacementNamed(context, AppRoutes.getStarted);
          },
          child: SvgPicture.asset(
            'assets/images/Back.svg',
            height: screenSize.height * 0.04,
          ),
        ),
        const Spacer(),
        SvgPicture.asset(
          'assets/svg/logo.svg',
          height: screenSize.height * 0.06,
        ),
      ],
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      'Sign Up',
      style: Theme.of(context)
          .textTheme
          .displayMedium
          ?.copyWith(color: Colors.black),
    );
  }

  Widget _buildTextFields(Size screenSize) {
    return Column(
      children: [
        CustomTextField(
          label: 'Username',
          hintText: 'Your username',
          controller: _usernameController,
        ),
        SizedBox(height: screenSize.height * 0.02),
        CustomTextField(
          label: 'Email',
          hintText: 'example@gmail.com',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: screenSize.height * 0.02),
        CustomTextField(
          label: 'Create a password',
          hintText: 'Must be at least 8 characters',
          controller: _passwordController,
          obscureText: !_isPasswordVisible,
          suffixIcon: IconButton(
            icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off),
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
          ),
        ),
        SizedBox(height: screenSize.height * 0.02),
        CustomTextField(
          label: 'Confirm password',
          hintText: 'Repeat password',
          controller: _confirmPasswordController,
          obscureText: !_isConfirmPasswordVisible,
          suffixIcon: IconButton(
            icon: Icon(_isConfirmPasswordVisible
                ? Icons.visibility
                : Icons.visibility_off),
            onPressed: () {
              setState(() {
                _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTermsAndConditions(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: _acceptTerms,
          onChanged: (value) {
            setState(() {
              _acceptTerms = value ?? false;
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

  Widget _buildSignUpButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        if (_acceptTerms) {
          // Handle sign-up logic here
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Please accept the terms and conditions.')),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        'Sign Up',
        style: Theme.of(context)
            .textTheme
            .headlineSmall
            ?.copyWith(color: Colors.white),
      ),
    );
  }

  Widget _buildLoginOption(BuildContext context) {
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
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
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
