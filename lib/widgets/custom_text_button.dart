import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:buyer_centric_app_v2/theme/colors.dart';

class CustomTextButton extends StatelessWidget {
  final int fontSize;
  final FontWeight fontWeight;
  final String text;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color? borderColor; // Optional border color

  const CustomTextButton({
    super.key,
    required this.fontSize,
    required this.text,
    required this.onPressed,
    this.backgroundColor = AppColor.buttonGreen,
    required this.fontWeight,
    this.borderColor, // Allows optional custom border color
  });

  @override
  Widget build(BuildContext context) {
    // Dynamic Text Color Based on Background
    final Color dynamicTextColor =
        backgroundColor == AppColor.buttonGreen ? AppColor.white : Colors.black;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: MaterialButton(
        onPressed: onPressed,
        color: backgroundColor,
        textColor: dynamicTextColor,
        minWidth: double.infinity,
        height: 56,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: backgroundColor != AppColor.buttonGreen
              ? BorderSide(color: borderColor ?? AppColor.grey, width: 1)
              : BorderSide.none,
        ),
        elevation: 0,
        child: Text(
          text,
          style: TextStyle(
            fontWeight: fontWeight,
            fontSize: fontSize.toDouble(),
            fontFamily: GoogleFonts.roboto().fontFamily,
          ),
        ),
      ),
    );
  }
}
