// ignore_for_file: deprecated_member_use

import 'package:buyer_centric_app_v2/theme/colors.dart';
import 'package:buyer_centric_app_v2/utils/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// ! IMPORTANT: Screen for creating new car buying posts
///
/// * Key Features:
/// * - Car details input
/// * - Price range selection
/// * - Image display
/// * - Description input
/// * - Firebase integration
/// @see BuyCarScreen

class CreateCarPostScreen extends StatefulWidget {
  // ? Required properties for post creation
  final String make;
  final String model;
  final String year;
  final String imageUrl;

  // * Constructor with required parameters
  const CreateCarPostScreen({
    Key? key,
    required this.make,
    required this.model,
    required this.year,
    required this.imageUrl,
  }) : super(key: key);

  @override
  _CreateCarPostScreenState createState() => _CreateCarPostScreenState();
}

class _CreateCarPostScreenState extends State<CreateCarPostScreen> {
  // * Price range selection
  RangeValues _currentRangeValues = const RangeValues(10000, 50000);

  // * Controllers for form inputs
  final TextEditingController _descriptionController = TextEditingController();
  final Color primaryColor = AppColor.green;
  final Color backgroundColor = AppColor.black;
  final Color textColor = AppColor.white;

  // ! Critical: Creates new post in Firestore
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
          'category': 'car',
        });

        CustomSnackbar.showSuccess(context, 'Post created successfully!');
        Navigator.pop(context);
      }
    } catch (e) {
      CustomSnackbar.showError(
          context, 'Failed to create post. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _buildCarImage(),
                    _buildCarDetails(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            decoration: const BoxDecoration(
              color: AppColor.black,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Text(
              'CREATE CAR POST',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColor.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close, color: AppColor.black),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            visualDensity: VisualDensity.compact,
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildCarDetails(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCarNameAndDetails(context),
          const SizedBox(height: 20),
          _buildPriceRangeSection(context),
          const SizedBox(height: 20),
          _buildDescriptionField(context),
          const SizedBox(height: 20),
          _buildCreatePostButton(context),
        ],
      ),
    );
  }

  Widget _buildCarNameAndDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Car Details',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColor.black,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColor.buttonGreen.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: AppColor.buttonGreen.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.directions_car,
                    color: AppColor.buttonGreen,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Vehicle Information',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColor.black,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              const Divider(
                color: AppColor.buttonGreen,
                thickness: 0.5,
                height: 16,
              ),
              _buildDetailRow('Make', widget.make),
              const SizedBox(height: 8),
              _buildDetailRow('Model', widget.model),
              const SizedBox(height: 8),
              _buildDetailRow('Year', widget.year),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      children: [
        Text(
          '$label:',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColor.black.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColor.black,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }

  Widget _buildPriceRangeSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Price Range',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColor.black,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColor.buttonGreen.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: AppColor.buttonGreen.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: AppColor.buttonGreen,
                  inactiveTrackColor: AppColor.buttonGreen.withOpacity(0.2),
                  thumbColor: AppColor.buttonGreen,
                  overlayColor: AppColor.buttonGreen.withOpacity(0.2),
                  valueIndicatorColor: AppColor.buttonGreen,
                  valueIndicatorTextStyle:
                      const TextStyle(color: AppColor.black),
                ),
                child: RangeSlider(
                  values: _currentRangeValues,
                  min: 0,
                  max: 100000,
                  divisions: 100,
                  labels: RangeLabels(
                    'PKR ${_currentRangeValues.start.round()}',
                    'PKR ${_currentRangeValues.end.round()}',
                  ),
                  onChanged: (values) =>
                      setState(() => _currentRangeValues = values),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PKR ${_currentRangeValues.start.round()}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColor.buttonGreen,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        'Minimum Price',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColor.black.withOpacity(0.7),
                              fontSize: 12,
                            ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'PKR ${_currentRangeValues.end.round()}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColor.buttonGreen,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        'Maximum Price',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColor.black.withOpacity(0.7),
                              fontSize: 12,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColor.black,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: AppColor.buttonGreen.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _descriptionController,
            maxLines: 4,
            style: const TextStyle(color: AppColor.black),
            decoration: InputDecoration(
              hintText: 'Enter car description...',
              hintStyle: TextStyle(color: AppColor.black.withOpacity(0.5)),
              filled: true,
              fillColor: AppColor.white,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide:
                    BorderSide(color: AppColor.buttonGreen.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: AppColor.buttonGreen),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCreatePostButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          FocusScope.of(context).unfocus();
          _createPost();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.buttonGreen,
          foregroundColor: AppColor.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Text(
          'Create Post',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColor.white,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    );
  }

  Widget _buildCarImage() {
    return Container(
      margin: const EdgeInsets.all(16),
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColor.buttonGreen.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColor.buttonGreen.withOpacity(0.4),
            spreadRadius: 3,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: widget.imageUrl.isNotEmpty
          ? Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    widget.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: Container(
                          width: 50,
                          height: 50,
                          padding: const EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(
                            color: AppColor.buttonGreen,
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) =>
                        _buildImageErrorPlaceholder(),
                  ),
                ),
              ],
            )
          : _buildImageErrorPlaceholder(),
    );
  }

  Widget _buildImageErrorPlaceholder() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColor.buttonGreen.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported,
            size: 50,
            color: AppColor.buttonGreen.withOpacity(0.5),
          ),
          const SizedBox(height: 8),
          Text(
            'No image selected',
            style: TextStyle(
              color: AppColor.black,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
