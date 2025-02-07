import 'package:buyer_centric_app_v2/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: SvgPicture.asset(
          'assets/svg/logo.svg',
          // ignore: deprecated_member_use
          color: AppColor.black,
        ),
      ),
      body: Center(
        child: SvgPicture.asset(
          'assets/svg/logo.svg',
          color: Colors.white,
        ),
      ),
    );
  }
}
