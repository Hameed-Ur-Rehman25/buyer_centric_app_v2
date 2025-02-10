import 'package:buyer_centric_app_v2/routes/app_routes.dart';
import 'package:buyer_centric_app_v2/screens/auth/forgot_password_screen.dart';
import 'package:buyer_centric_app_v2/screens/auth/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:buyer_centric_app_v2/utils/powered_by.dart';
import 'package:buyer_centric_app_v2/utils/screen_size.dart';
import 'package:buyer_centric_app_v2/widgets/custom_text_button.dart';
import 'package:buyer_centric_app_v2/widgets/custom_textfield.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isPasswordVisible = false;

  @override
  void dispose() {
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
                      _buildHeader(context),
                      SizedBox(height: context.screenHeight * 0.03),
                      _buildTitle(context),
                      SizedBox(height: context.screenHeight * 0.025),
                      _buildEmailField(),
                      SizedBox(height: context.screenHeight * 0.02),
                      _buildPasswordField(),
                      SizedBox(height: context.screenHeight * 0.015),
                      _buildForgotPasswordButton(),
                      SizedBox(height: context.screenHeight * 0.02),
                      _buildLoginButton(context),
                      SizedBox(height: context.screenHeight * 0.02),
                      _buildDivider(context),
                      SizedBox(height: context.screenHeight * 0.02),
                      _buildSocialLoginIcons(context),
                      SizedBox(height: context.screenHeight * 0.025),
                      _buildSignUpSection(context),
                      const Spacer(),
                      PoweredBy(size: context.screenSize),
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

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: () {
            Navigator.pushReplacementNamed(context, AppRoutes.getStarted);
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
      'Log in',
      style: TextStyle(
        fontSize: context.screenWidth * 0.07,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _buildEmailField() {
    return CustomTextField(
      label: 'Email address',
      hintText: 'Enter your email',
      controller: emailController,
      suffixIcon: const Icon(Icons.check_circle, color: Colors.black),
    );
  }

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
            isPasswordVisible = !isPasswordVisible;
          });
        },
      ),
    );
  }

  Widget _buildForgotPasswordButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ForgotPasswordScreen(),
            ),
          );
        },
        child: const Text(
          'Forgot password?',
          style: TextStyle(color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return CustomTextButton(
      fontSize: (context.screenWidth * 0.045).toInt(),
      text: 'Log in',
      onPressed: () {},
      fontWeight: FontWeight.w500,
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            'Or Login with',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.black,
                ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }

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
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SignUpScreen()),
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
