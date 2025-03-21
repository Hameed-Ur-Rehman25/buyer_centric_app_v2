import 'package:buyer_centric_app_v2/theme/colors.dart';
import 'package:flutter/material.dart';

class CustomTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? backgroundColor;
  final Color? loadingBackgroundColor;
  final Widget? child;
  final double height;
  final double? width;
  final bool isLoading;

  const CustomTextButton({
    super.key,
    required this.text,
    this.onPressed,
    this.fontSize,
    this.fontWeight,
    this.backgroundColor,
    this.loadingBackgroundColor,
    this.child,
    this.height = 50,
    this.width,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isLoading
              ? loadingBackgroundColor ?? AppColor.buttonGreen
              : backgroundColor ?? Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        child: child ??
            Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize ?? 14,
                fontWeight: fontWeight ?? FontWeight.normal,
              ),
            ),
      ),
    );
  }
}
