import 'package:flutter/material.dart';
import 'package:buyer_centric_app_v2/routes/app_routes.dart';
import 'package:buyer_centric_app_v2/utils/screen_size.dart';

class UploadScreen extends StatelessWidget {
  const UploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Upload',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding:
              EdgeInsets.symmetric(horizontal: context.screenWidth * 0.065),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildUploadButton(
                context,
                'Add Car',
                Icons.directions_car,
                () {
                  // Navigate to add car screen
                  Navigator.pushNamed(context, AppRoutes.addCar);
                },
              ),
              SizedBox(height: context.screenHeight * 0.03),
              _buildUploadButton(
                context,
                'Add Parts',
                Icons.build,
                () {
                  // Navigate to add parts screen
                  Navigator.pushNamed(context, AppRoutes.addParts);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadButton(BuildContext context, String text, IconData icon,
      VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: context.screenHeight * 0.08,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            SizedBox(width: context.screenWidth * 0.02),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
