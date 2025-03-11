import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:buyer_centric_app_v2/theme/colors.dart';

class CustomTextField extends StatelessWidget {
  // Required parameters
  final String label;
  final String hintText;
  final TextEditingController controller;

  // Optional parameters with default values
  final bool obscureText;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final TextInputType keyboardType;
  final String? errorText; // Error handling
  final int maxLines; // Support for multi-line text
  final ValueChanged<String>? onChanged; // Callback for real-time text updates

  const CustomTextField({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    this.obscureText = false,
    this.suffixIcon,
    this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.errorText,
    this.maxLines = 1,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label for the text field
        Text(
          label,
          style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: Colors.black,
              fontFamily: GoogleFonts.inter().fontFamily),
        ),
        const SizedBox(height: 8),
        // The actual text field
        TextField(
          controller: controller,
          obscureText: obscureText,
          cursorColor: Colors.black,
          keyboardType: keyboardType,
          maxLines:
              obscureText ? 1 : maxLines, // Prevent multiline for password
          onChanged: onChanged,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: AppColor.grey,
              fontFamily: GoogleFonts.inter().fontFamily,
            ),
            errorText: errorText, // Displays error message if provided
            contentPadding:
                const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.black, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
