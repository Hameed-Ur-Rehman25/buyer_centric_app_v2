import 'package:buyer_centric_app_v2/theme/colors.dart';
import 'package:buyer_centric_app_v2/widgets/post_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.homebackgroundColor,
      appBar: AppBar(
        elevation: 0, // Remove the shadow
        title: SvgPicture.asset(
          'assets/svg/logo.svg',
          height: 36,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13.0),
            child: SvgPicture.asset(
              'assets/svg/side-menu.svg',
              height: 30,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              child: Image.asset('assets/images/home_screen_image.png'),
            ),
            const SizedBox(
              height: 20,
            ),
            PostCard(
              lowRange: 2000000,
              highRange: 2300000,
              image: 'assets/images/car2.png',
              carName: 'BMW 5 Series',
            ),
            PostCard(
              lowRange: 2000000,
              highRange: 2300000,
              image: 'assets/images/car1.png',
              carName: 'BMW 5 Series',
            ),
            PostCard(
              lowRange: 2000000,
              highRange: 2300000,
              image: 'assets/images/car2.png',
              carName: 'BMW 5 Series',
            ),
            PostCard(
              lowRange: 2000000,
              highRange: 2300000,
              image: 'assets/images/car2.png',
              carName: 'BMW 5 Series',
            ),
          ],
        ),
      ),
    );
  }
}
