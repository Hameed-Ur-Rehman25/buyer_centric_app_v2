import 'package:buyer_centric_app_v2/theme/colors.dart';
import 'package:buyer_centric_app_v2/utils/screen_size.dart';
import 'package:buyer_centric_app_v2/widgets/custom_app_bar.dart';
import 'package:buyer_centric_app_v2/widgets/post_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
      // appBar: PreferredSize(
      //   preferredSize: Size.fromHeight(context.screenHeight * 0.12),
      //   child: Stack(
      //     children: [
      //       Column(
      //         children: [
      //           AppBar(
      //             elevation: 0,
      //             backgroundColor: AppColor.appBarColor,
      //             //curve bottom corners of appbar
      //             shape: const RoundedRectangleBorder(
      //               borderRadius: BorderRadius.only(
      //                 bottomLeft: Radius.circular(40),
      //                 bottomRight: Radius.circular(40),
      //               ),
      //             ),
      //             title: Row(
      //               children: [
      //                 SvgPicture.asset(
      //                   'assets/svg/logo.svg',
      //                   height: 36,
      //                 ),

      //                 const Spacer(), // This will push the menu icon to the right
      //                 Padding(
      //                   padding: const EdgeInsets.symmetric(horizontal: 13.0),
      //                   child: SvgPicture.asset(
      //                     'assets/svg/side-menu.svg',
      //                     height: 30,
      //                   ),
      //                 ),
      //               ],
      //             ),
      //             centerTitle: false,
      //           ),
      //         ],
      //       ),
      //     ],
      //   ),
      // ),
      appBar: const CustomAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            //* AppBar with Logo and Menu Icon with Search Bar
            // Container(
            //   height: context.screenHeight * 0.12,
            //   padding: const EdgeInsets.symmetric(
            //     horizontal: 24,
            //   ),
            //   decoration: BoxDecoration(
            //     color: AppColor.appBarColor,
            //   ),
            //   child: Row(
            //     children: [
            //       SvgPicture.asset(
            //         'assets/svg/logo.svg',
            //         height: 36,
            //       ),
            //       const Spacer(),
            //       SvgPicture.asset(
            //         'assets/svg/side-menu.svg',
            //         height: 30,
            //       ),
            //     ],
            //   ),
            // ),

            //* Home Screen Image with Animation
            FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Image.asset('assets/images/home_screen_image.png'),
              ),
            ),
            const SizedBox(height: 20),

            //* Post Cards with Staggered Animations
            const PostCard(
              index: 0,
              carName: 'BMW 5 Series',
              lowRange: 2000000,
              highRange: 2300000,
              image: 'assets/images/car2.png',
              description:
                  '''Car should be in mint condition and should be the exact same model as specified above and for any further details please contact me.''',
            ),
            const PostCard(
              index: 1,
              carName: 'Audi A6',
              lowRange: 2500000,
              highRange: 2700000,
              image: 'assets/images/car1.png',
              description:
                  '''Car should be in mint condition and should be the exact same model as specified above and for any further details please contact me.''',
            ),
            const PostCard(
              index: 2,
              carName: 'Mercedes C-Class',
              lowRange: 1800000,
              highRange: 2100000,
              image: 'assets/images/car2.png',
              description:
                  '''Car should be in mint condition and should be the exact same model as specified above and for any further details please contact me.''',
            ),
            const PostCard(
              index: 3,
              carName: 'Tesla Model 3',
              lowRange: 3000000,
              highRange: 3500000,
              image: 'assets/images/car2.png',
              description:
                  '''Car should be in mint condition and should be the exact same model as specified above and for any further details please contact me.''',
            ),
          ],
        ),
      ),
    );
  }
}
