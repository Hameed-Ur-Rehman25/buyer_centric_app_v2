// ignore_for_file: deprecated_member_use

import 'package:buyer_centric_app_v2/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CreateCarPostScreen extends StatefulWidget {
  final String make;
  final String model;
  final String year;
  final String imageUrl;

  const CreateCarPostScreen({
    super.key,
    required this.make,
    required this.model,
    required this.year,
    required this.imageUrl,
  });

  @override
  _CreateCarPostScreenState createState() => _CreateCarPostScreenState();
}

class _CreateCarPostScreenState extends State<CreateCarPostScreen> {
  RangeValues _currentRangeValues = const RangeValues(10000, 50000);
  final TextEditingController _descriptionController = TextEditingController();
  final Color primaryColor = AppColor.green;
  final Color backgroundColor = AppColor.black;
  final Color textColor = AppColor.white;

  // Function to create a new post in Firestore
  Future<void> _createPost() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('posts').add({
          'userId': user.uid,
          'make': widget.make,
          'model': widget.model,
          'year': widget.year,
          'imageUrl': widget.imageUrl,
          'minPrice': _currentRangeValues.start.toInt(),
          'maxPrice': _currentRangeValues.end.toInt(),
          'description': _descriptionController.text,
          'timestamp': FieldValue.serverTimestamp(),
          'offers': [],
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to create post. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final profileIconSize = screenWidth * 0.12;
    final menuIconSize = screenWidth * 0.08;
    final appBarHeight = screenHeight * 0.08;

    return Scaffold(
      backgroundColor: backgroundColor,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
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
                      // Back Button with Profile Style
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: CircleAvatar(
                          radius: profileIconSize / 2,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          child: Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: profileIconSize * 0.6,
                          ),
                        ),
                      ),
                      // Title
                      Text(
                        'Create Post',
                        style: TextStyle(
                          color: textColor,
                          fontSize: screenWidth * 0.055,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Menu Icon
                      SvgPicture.asset(
                        'assets/svg/side-menu.svg',
                        height: menuIconSize,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                  height: appBarHeight + MediaQuery.of(context).padding.top),
              _buildContentCard(),
            ],
          ),
        ),
      ),
    );
  }

  // Widget to build the main content card
  Widget _buildContentCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryColor.withOpacity(0.3), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCarDetailsSection(),
            Divider(color: primaryColor.withOpacity(0.3)),
            const SizedBox(height: 20),
            _buildImageSection(),
            Divider(color: primaryColor.withOpacity(0.3)),
            const SizedBox(height: 20),
            _buildPriceRangeSection(),
            Divider(color: primaryColor.withOpacity(0.3)),
            const SizedBox(height: 20),
            _buildDescriptionSection(),
            const SizedBox(height: 24),
            _buildCreatePostButton(),
          ],
        ),
      ),
    );
  }

  // Widget to build the car details section
  Widget _buildCarDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Car Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 16),
        _buildDetailTile('Make', widget.make.toUpperCase()),
        _buildDetailTile('Model', widget.model.toUpperCase()),
        _buildDetailTile('Year', widget.year),
      ],
    );
  }

  // Widget to build a detail tile
  Widget _buildDetailTile(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: primaryColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: primaryColor,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  // Widget to build the car image section
  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Car Image',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: widget.imageUrl.isNotEmpty
              ? Image.network(
                  widget.imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 200,
                      width: double.infinity,
                      color: backgroundColor,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                          color: primaryColor,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(15),
                        border:
                            Border.all(color: primaryColor.withOpacity(0.3)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image_rounded,
                            size: 50,
                            color: primaryColor.withOpacity(0.5),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Image not available',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                )
              : Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: primaryColor.withOpacity(0.3)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_not_supported,
                        size: 50,
                        color: primaryColor.withOpacity(0.5),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No image selected',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  // Widget to build the price range section
  Widget _buildPriceRangeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Price Range',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: primaryColor.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: primaryColor,
                  inactiveTrackColor: primaryColor.withOpacity(0.2),
                  thumbColor: primaryColor,
                  overlayColor: primaryColor.withOpacity(0.2),
                  valueIndicatorColor: primaryColor,
                  valueIndicatorTextStyle: TextStyle(color: backgroundColor),
                  rangeThumbShape: const RoundRangeSliderThumbShape(
                    enabledThumbRadius: 8,
                    elevation: 4,
                  ),
                  rangeTrackShape: const RoundedRectRangeSliderTrackShape(),
                  rangeValueIndicatorShape:
                      const PaddleRangeSliderValueIndicatorShape(),
                ),
                child: RangeSlider(
                  values: _currentRangeValues,
                  min: 0,
                  max: 100000,
                  divisions: 100,
                  labels: RangeLabels(
                    '\$${_currentRangeValues.start.toInt()}',
                    '\$${_currentRangeValues.end.toInt()}',
                  ),
                  onChanged: (RangeValues values) {
                    setState(() {
                      _currentRangeValues = values;
                    });
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '\$${_currentRangeValues.start.round()}',
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '\$${_currentRangeValues.end.round()}',
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Widget to build the description section
  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _descriptionController,
          maxLines: 4,
          style: TextStyle(color: textColor),
          decoration: const InputDecoration(
            hintText: 'Enter car description...',
            hintStyle: TextStyle(color: Colors.grey),
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  // Widget to build the create post button
  Widget _buildCreatePostButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _createPost,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 0,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, size: 24),
            SizedBox(width: 10),
            Text(
              'Create Post',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
