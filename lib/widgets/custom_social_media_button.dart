import 'package:buyer_centric_app_v2/theme/colors.dart';
import 'package:flutter/material.dart';

class CustomSocialMediaButton extends StatelessWidget {
  final String imagePath;
  final Function onPressed;

  const CustomSocialMediaButton({
    super.key,
    required this.imagePath,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: () {},
      // ignore: prefer_const_constructors
      padding: EdgeInsets.symmetric(
        vertical: 15,
        // horizontal: 25,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: AppColor.grey.withOpacity(0.5),
        ),
      ),
      child: Image.asset(
        imagePath,
        height: 20,
      ),
    );
  }
}
