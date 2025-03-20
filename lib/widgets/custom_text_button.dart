import 'package:flutter/material.dart';

class CustomTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? backgroundColor;
  final Widget? child;
  final double height;
  final double? width;

  const CustomTextButton({
    super.key,
    required this.text,
    this.onPressed,
    this.fontSize,
    this.fontWeight,
    this.backgroundColor,
    this.child,
    this.height = 50,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? Colors.black,
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
