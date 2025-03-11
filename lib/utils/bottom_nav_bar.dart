import 'package:buyer_centric_app_v2/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BottomNavBar extends StatefulWidget {
  final Function(int) onTabSelected;
  final int currentIndex;

  const BottomNavBar(
      {super.key, required this.onTabSelected, required this.currentIndex});

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: widget.currentIndex,
      onTap: widget.onTabSelected,
      backgroundColor: AppColor.white,
      // selectedItemColor: Colors.white,
      unselectedItemColor: AppColor.black,
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            'assets/svg/home-1.svg',
            height: 28,
          ),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            'assets/svg/image-48.svg',
            height: 28,
          ),
          label: 'Buy',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset('assets/svg/icons8-add-100.svg', height: 32),
          label: 'Upload',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            'assets/svg/car-parts-icon-style-vector-1.svg',
            height: 30,
          ),
          label: 'Car Parts',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            'assets/svg/settings.svg',
            height: 28,
          ),
          label: 'Settings',
        ),
      ],
    );
  }
}
