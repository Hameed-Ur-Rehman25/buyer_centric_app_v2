import 'package:buyer_centric_app_v2/utils/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:buyer_centric_app_v2/screens/profile/utils/profile_app_bar.dart';
import 'package:buyer_centric_app_v2/theme/colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ProfileAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Text(
              'Amna',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            const _ProfileButtons(),
            const _SettingsList(),
          ],
        ),
      ),
      // bottomNavigationBar: BottomNavBar(
      //   currentIndex: 4,
      //   onTabSelected: (index) {},
      // ),
    );
  }
}

class _ProfileButtons extends StatelessWidget {
  const _ProfileButtons();

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double buttonWidth = (screenWidth - 60) / 4;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _ProfileButton(
              'Favorites', 'assets/icons/Frame 23387.png', buttonWidth),
          _ProfileButton('My cars', 'assets/icons/image 48.png', buttonWidth),
          _ProfileButton('My parts',
              'assets/icons/car-parts-icon-style-vector 1.png', buttonWidth),
          _ProfileButton('My ads', 'assets/icons/Frame 23383.png', buttonWidth),
        ],
      ),
    );
  }
}

class _ProfileButton extends StatelessWidget {
  final String title;
  final String imagePath;
  final double width;

  const _ProfileButton(this.title, this.imagePath, this.width);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 113,
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            imagePath,
            height: 50,
          ),
          const SizedBox(height: 5),
          Text(title, style: GoogleFonts.poppins(fontSize: 14)),
        ],
      ),
    );
  }
}

class _SettingsList extends StatelessWidget {
  const _SettingsList();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.4),
          spreadRadius: 1,
          blurRadius: 5,
          offset: const Offset(0, 3),
        ),
      ]),
      child: Container(
        color: Colors.white,
        child: ListView(
          padding: const EdgeInsets.all(10),
          children: const [
            _SettingsOption('My Account', Icons.person, true),
            _SettingsOption('Receive crucial information', Icons.lock, false,
                isSwitch: true),
            _SettingsOption('Change password', Icons.security, false),
            _SettingsOption('Log out', Icons.logout, false),
          ],
        ),
      ),
    );
  }
}

class _SettingsOption extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool hasWarning;
  final bool isSwitch;

  const _SettingsOption(this.title, this.icon, this.hasWarning,
      {this.isSwitch = false});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.teal.shade700),
      title: Text(title, style: GoogleFonts.poppins(fontSize: 16)),
      trailing: isSwitch
          ? Switch(value: false, onChanged: (val) {})
          : hasWarning
              ? const Icon(Icons.warning, color: Colors.red)
              : const Icon(Icons.arrow_forward_ios, size: 16),
    );
  }
}

// class _BottomNavBar extends StatelessWidget {
//   const _BottomNavBar();

//   @override
//   Widget build(BuildContext context) {
//     return BottomNavigationBar(
//       selectedItemColor: Colors.teal.shade700,
//       unselectedItemColor: Colors.grey,
//       showUnselectedLabels: true,
//       items: const [
//         BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
//         BottomNavigationBarItem(icon: Icon(Icons.directions_car), label: 'Buy'),
//         BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: 'Upload'),
//         BottomNavigationBarItem(icon: Icon(Icons.build), label: 'Car parts'),
//         BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Setting'),
//       ],
//     );
//   }
// }
