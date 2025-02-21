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
      child: Column(
        children: [
          _buildDrawerHeader(context),
          Expanded(child: _buildDrawerItems(context)),
          _buildLogoutButton(context),
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
            color: AppColor.black,
          ),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: AppColor.grey),
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
          ),
        );
      },
    );
  }

  Widget _buildDrawerItems(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      children: [
        _buildDrawerItem(
          context: context,
          icon: Icons.person_outline,
          title: 'Profile',
          onTap: () {
            Navigator.pop(context);
          },
        ),
        _buildDrawerItem(
          context: context,
          icon: Icons.shopping_bag_outlined,
          title: 'Sell Car',
          onTap: () {
            Navigator.pop(context);
          },
        ),
        _buildDrawerItem(
          context: context,
          icon: Icons.favorite_border,
          title: 'Buy Car',
          onTap: () {
            Navigator.pop(context);
          },
        ),
        _buildDrawerItem(
          context: context,
          icon: Icons.notifications_none,
          title: 'My Inventory',
          onTap: () {
            Navigator.pop(context);
          },
        ),
        _buildDrawerItem(
          context: context,
          icon: Icons.help_outline,
          title: 'About',
          onTap: () {
            Navigator.pop(context);
          },
        ),
        _buildDrawerItem(
          context: context,
          icon: Icons.settings_outlined,
          title: 'Settings',
          onTap: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ElevatedButton.icon(
        onPressed: () async {
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
        icon: const Icon(Icons.logout, color: AppColor.white),
        label: const Text(
          'Logout',
          style: TextStyle(color: AppColor.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromRGBO(157, 35, 35, 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: AppColor.black),
          title: Text(
            title,
            style: GoogleFonts.poppins(
              color: AppColor.black,
              fontSize: 16,
            ),
          ),
          onTap: onTap,
        ),
        const Divider(color: AppColor.grey, height: 1),
      ],
    );
  }
}
