import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:buyer_centric_app_v2/theme/colors.dart';

class CustomTextButton extends StatelessWidget {
  final int fontSize;
  final FontWeight fontWeight;
  final String text;
  final Function onPressed;
  final Color backgroundColor;

  const CustomTextButton({
    super.key,
    required this.fontSize,
    required this.text,
    required this.onPressed,
    this.backgroundColor = AppColor.buttonGreen,
    required this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    // Dynamic Text Color
    final Color dynamicTextColor =
        backgroundColor == AppColor.buttonGreen ? AppColor.white : Colors.black;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: MaterialButton(
        onPressed: () => onPressed(),
        color: backgroundColor,
        textColor: dynamicTextColor,
        minWidth: double.infinity,
        height: 56,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: backgroundColor != AppColor.buttonGreen
              ? const BorderSide(color: AppColor.grey, width: 1)
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
