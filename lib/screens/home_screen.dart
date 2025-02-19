import 'package:buyer_centric_app_v2/utils/car_search_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:buyer_centric_app_v2/theme/colors.dart';
import 'package:buyer_centric_app_v2/widgets/custom_app_bar.dart';
import 'package:buyer_centric_app_v2/widgets/post_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    // Delayed start for better effect
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: const CustomAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            //* Home Screen Image with Animation
            _buildAnimatedImage(),
            const SizedBox(height: 20),

            //* All Feature Title with sort and filter buttons
            _buildFeatureTitle(),

            //* Post Cards with Staggered Animations
            _buildPostCards(),

            //* buy/sell title
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 10),
              child: Row(
                children: [
                  Text(
                    'Buy / Sell',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: GoogleFonts.montserrat().fontFamily,
                      color: Colors.black,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.arrow_forward_ios),
                    color: Colors.black,
                  )
                ],
              ),
            ),

            //* car search cards
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: CarSearchCard(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedImage() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Image.asset('assets/images/home_screen_image.png'),
      ),
    );
  }

  Widget _buildFeatureTitle() {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'All Features',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: GoogleFonts.montserrat().fontFamily,
              color: Colors.black,
            ),
          ),
          Row(
            children: [
              TextButton.icon(
                onPressed: () {},
                style: ButtonStyle(
                  overlayColor: MaterialStateProperty.all(Colors.transparent),
                ),
                icon: SvgPicture.asset(
                  'assets/svg/sort-vertical-svgrepo-com.svg',
                  height: 20,
                  color: Colors.black,
                ),
                iconAlignment: IconAlignment.end,
                label:
                    const Text('Sort', style: TextStyle(color: Colors.black)),
              ),
              TextButton.icon(
                onPressed: () {},
                style: ButtonStyle(
                  overlayColor: MaterialStateProperty.all(Colors.transparent),
                ),
                icon:
                    const Icon(Icons.filter_alt_outlined, color: Colors.black),
                iconAlignment: IconAlignment.end,
                label:
                    const Text('Filter', style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPostCards() {
    return const Column(
      children: [
        PostCard(
          index: 0,
          carName: 'BMW 5 Series',
          lowRange: 2000000,
          highRange: 2300000,
          image: 'assets/images/car2.png',
          description:
              '''Car should be in mint condition and should be the exact same model as specified above and for any further details please contact me.''',
        ),
        PostCard(
          index: 1,
          carName: 'Audi A6',
          lowRange: 2500000,
          highRange: 2700000,
          image: 'assets/images/car1.png',
          description:
              '''Car should be in mint condition and should be the exact same model as specified above and for any further details please contact me.''',
        ),
        // PostCard(
        //   index: 2,
        //   carName: 'Mercedes C-Class',
        //   lowRange: 1800000,
        //   highRange: 2100000,
        //   image: 'assets/images/car2.png',
        //   description:
        //       '''Car should be in mint condition and should be the exact same model as specified above and for any further details please contact me.''',
        // ),
        // PostCard(
        //   index: 3,
        //   carName: 'Tesla Model 3',
        //   lowRange: 3000000,
        //   highRange: 3500000,
        //   image: 'assets/images/car2.png',
        //   description:
        //       '''Car should be in mint condition and should be the exact same model as specified above and for any further details please contact me.''',
        // ),
      ],
    );
  }
}
