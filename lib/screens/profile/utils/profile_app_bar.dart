import 'package:buyer_centric_app_v2/theme/colors.dart';
import 'package:buyer_centric_app_v2/utils/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProfileAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showSearchBar;
  const ProfileAppBar({super.key, this.showSearchBar = true});

  @override
  Size get preferredSize => const Size.fromHeight(200); // Base height

  @override
  Widget build(BuildContext context) {
    //* Get screen width and height from your MediaQuery extension
    double screenWidth = context.screenWidth; // Screen width
    double screenHeight = context.screenHeight; // Screen height

    //* Responsive height and padding adjustments
    double appBarHeight = showSearchBar
        ? screenHeight * 0.40
        : screenHeight * 0.20; // 16% of screen height
    double profileIconSize = screenWidth * 0.12; // 12% of screen width
    double menuIconSize = screenWidth * 0.08; // 8% of screen width
    double searchBarHeight = screenHeight * 0.06; // 6% of screen height
    double searchBarPadding = screenWidth * 0.05; // 5% of screen width

    return Padding(
      padding: EdgeInsets.only(bottom: showSearchBar ? screenHeight * 0.05 : 0),
      child: Stack(
        clipBehavior: Clip.none, // Allows search bar to go outside AppBar
        children: [
          //* Main App Bar with curved shape
          Container(
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.08,
            ), // Dynamic padding
            height: appBarHeight, // Responsive AppBar height
            child: SafeArea(
              child: Column(
                children: [
                  SizedBox(
                    height: showSearchBar
                        ? screenHeight * 0.006
                        : screenHeight * 0.010,
                  ), // Top padding
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      //* logo
                      SvgPicture.asset('assets/svg/logo.svg',
                          height: profileIconSize * 0.8,
                          colorFilter: const ColorFilter.mode(
                              Colors.white, BlendMode.srcIn)),

                      //* Menu Icon
                      SvgPicture.asset(
                        'assets/svg/side-menu.svg',
                        height: menuIconSize,
                        colorFilter: const ColorFilter.mode(
                            Colors.white, BlendMode.srcIn),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: screenHeight * 0.02,
                  ), // Space between avatar row and search bar
                ],
              ),
            ),
          ),

          //* Avatar
          Positioned(
            bottom: -profileIconSize / 1,
            // left: (screenWidth - profileIconSize) / 20,

            left: screenWidth * 0.35,
            child: CircleAvatar(
              // radius: profileIconSize / 1, // Adjusted size
              radius: 60,
              backgroundColor: const Color(0xFFFDEDEB),
              child: Image.asset(
                'assets/images/User image.png',
                width: 110,
                // width: profileIconSize,
                // height: profileIconSize * 0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
