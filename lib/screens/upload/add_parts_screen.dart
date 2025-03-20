import 'package:flutter/material.dart';
import 'package:buyer_centric_app_v2/theme/colors.dart';
import 'package:buyer_centric_app_v2/utils/screen_size.dart';

class AddPartsScreen extends StatelessWidget {
  const AddPartsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final profileIconSize = screenWidth * 0.12;
    final avatarSize = screenWidth * 0.1;
    final appBarHeight = screenHeight * 0.08;

    return Scaffold(
      backgroundColor: AppColor.white,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context, screenWidth, screenHeight, profileIconSize,
          avatarSize, appBarHeight),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: screenWidth * 0.04,
            right: screenWidth * 0.04,
            top: appBarHeight + 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 12, bottom: 20),
                child: Text(
                  'How would you like to add parts?',
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.9),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildUploadButton(
                context,
                'Retrieve from Database',
                Icons.search,
                'Find existing parts in our database',
                () {
                  // TODO: Implement database retrieval
                },
              ),
              const SizedBox(height: 16),
              _buildUploadButton(
                context,
                'Upload from Gallery',
                Icons.photo_library,
                'Upload new parts from your gallery',
                () {
                  // TODO: Implement gallery upload
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSize _buildAppBar(
      BuildContext context,
      double screenWidth,
      double screenHeight,
      double profileIconSize,
      double avatarSize,
      double appBarHeight) {
    return PreferredSize(
      preferredSize: Size.fromHeight(appBarHeight),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColor.appBarColor,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(40),
            bottomRight: Radius.circular(40),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.01),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back Button
                    CircleAvatar(
                      radius: profileIconSize / 2,
                      backgroundColor: Colors.black.withOpacity(0.2),
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          color: Colors.black,
                          size: profileIconSize * 0.6,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    // Title
                    Text(
                      'Add Car Parts',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: screenWidth * 0.055,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // User Avatar
                    CircleAvatar(
                      radius: avatarSize / 2,
                      backgroundColor: Colors.black.withOpacity(0.2),
                      child: Icon(
                        Icons.person,
                        color: Colors.black,
                        size: avatarSize * 0.8,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUploadButton(
    BuildContext context,
    String text,
    IconData icon,
    String subtitle,
    VoidCallback onPressed,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonWidth = (screenWidth - (screenWidth * 0.08)) *
        0.6; // Make button smaller (60% of original width)
    final buttonHeight = buttonWidth; // Keep it square

    return Center(
      child: Container(
        width: buttonWidth,
        height: buttonHeight,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.buttonGreen.withOpacity(0.1),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: AppColor.buttonGreen.withOpacity(0.3),
                width: 1,
              ),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColor.buttonGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  icon,
                  color: AppColor.buttonGreen,
                  size: 50, // Slightly reduced icon size
                ),
              ),
              const SizedBox(height: 12),
              Text(
                text,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16, // Slightly reduced font size
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.black.withOpacity(0.7),
                  fontSize: 12, // Slightly reduced font size
                ),
                textAlign: TextAlign.center,
              ),
              // const SizedBox(height: 12),
              // const Icon(
              //   Icons.arrow_forward_ios,
              //   color: AppColor.black,
              //   size: 16, // Slightly reduced arrow size
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
