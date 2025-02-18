import 'package:buyer_centric_app_v2/theme/colors.dart';
import 'package:buyer_centric_app_v2/utils/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(140); // Base height

  @override
  Widget build(BuildContext context) {
    // Get screen width and height from your MediaQuery extension
    double screenWidth = context.screenWidth;
    double screenHeight = context.screenHeight;

    // Responsive height and padding adjustments
    double appBarHeight = screenHeight * 0.16; // 16% of screen height
    double profileIconSize = screenWidth * 0.12; // 12% of screen width
    double menuIconSize = screenWidth * 0.08; // 8% of screen width
    double searchBarHeight = screenHeight * 0.06; // 6% of screen height
    double searchBarPadding = screenWidth * 0.05; // 5% of screen width

    return Padding(
      padding: EdgeInsets.only(bottom: screenHeight * 0.05),
      child: Stack(
        clipBehavior: Clip.none, // Allows search bar to go outside AppBar
        children: [
          // Main App Bar with curved shape
          Container(
            decoration: const BoxDecoration(
              color: AppColor.appBarColor, // Custom color
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.08), // Dynamic padding
            height: appBarHeight, // Responsive AppBar height
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Profile Icon
                CircleAvatar(
                  radius: profileIconSize / 2, // Adjusted size
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                    size: profileIconSize * 0.8, // Scales with screen size
                  ),
                ),

                // Menu Icon
                SvgPicture.asset(
                  'assets/svg/side-menu.svg',
                  height: menuIconSize,
                  colorFilter:
                      const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
              ],
            ),
          ),

          // Search Bar Positioned below the AppBar
          Positioned(
            bottom: -searchBarHeight / 2, // Dynamically positioned
            left: searchBarPadding,
            right: searchBarPadding,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
              height: searchBarHeight,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Icon(Icons.search, color: Colors.grey),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Search any product...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Icon(Icons.mic, color: Colors.grey),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
