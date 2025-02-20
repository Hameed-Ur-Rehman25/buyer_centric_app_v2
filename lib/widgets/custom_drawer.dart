import 'package:buyer_centric_app_v2/utils/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:buyer_centric_app_v2/theme/colors.dart';
import 'package:buyer_centric_app_v2/routes/app_routes.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColor.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildDrawerHeader(context),
          _buildDrawerItems(context),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        final user = authService.user;
        return DrawerHeader(
          decoration: const BoxDecoration(
            color: AppColor.appBarColor,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 35,
                backgroundColor: Colors.white,
                child:
                    Icon(Icons.person, size: 40, color: AppColor.appBarColor),
              ),
              const SizedBox(height: 10),
              Text(
                user?.username ?? 'Guest User',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                user?.email ?? 'guest@example.com',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDrawerItems(BuildContext context) {
    return Column(
      children: [
        _buildDrawerItem(
          context: context,
          icon: Icons.person_outline,
          title: 'Profile',
          onTap: () {
            // TODO: Navigate to profile screen
            Navigator.pop(context);
          },
        ),
        _buildDrawerItem(
          context: context,
          icon: Icons.shopping_bag_outlined,
          title: 'My Orders',
          onTap: () {
            // TODO: Navigate to orders screen
            Navigator.pop(context);
          },
        ),
        _buildDrawerItem(
          context: context,
          icon: Icons.favorite_border,
          title: 'Wishlist',
          onTap: () {
            // TODO: Navigate to wishlist screen
            Navigator.pop(context);
          },
        ),
        _buildDrawerItem(
          context: context,
          icon: Icons.notifications_none,
          title: 'Notifications',
          onTap: () {
            // TODO: Navigate to notifications screen
            Navigator.pop(context);
          },
        ),
        _buildDrawerItem(
          context: context,
          icon: Icons.settings_outlined,
          title: 'Settings',
          onTap: () {
            // TODO: Navigate to settings screen
            Navigator.pop(context);
          },
        ),
        const Divider(),
        _buildDrawerItem(
          context: context,
          icon: Icons.help_outline,
          title: 'Help & Support',
          onTap: () {
            // TODO: Navigate to help screen
            Navigator.pop(context);
          },
        ),
        _buildDrawerItem(
          context: context,
          icon: Icons.logout,
          title: 'Logout',
          onTap: () async {
            try {
              final authService =
                  Provider.of<AuthService>(context, listen: false);
              await authService.signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              }
            } catch (e) {
              if (context.mounted) {
                CustomSnackbar.showError(context, e.toString());
              }
            }
          },
        ),
      ],
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColor.black),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          color: AppColor.black,
          fontSize: 16,
        ),
      ),
      onTap: onTap,
    );
  }
}
