// ignore_for_file: deprecated_member_use

import 'package:buyer_centric_app_v2/theme/colors.dart';
import 'package:buyer_centric_app_v2/utils/snackbar.dart';
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

  /// Function to create a new post in Firestore
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

        CustomSnackbar.showSuccess(context, 'Post created successfully!');
        Navigator.pop(context);
      }
    } catch (e) {
      CustomSnackbar.showError(context, 'Failed to create post. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Container(
        decoration: const BoxDecoration(
          color: AppColor.black,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _buildCarImage(),
                    _buildCarDetails(context),
                    SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 20),
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
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 20),
          decoration: const BoxDecoration(
            color: AppColor.black,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15),
              bottomRight: Radius.circular(15),
            ),
          ),
          child: Text(
            'CREATE POST',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColor.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: IconButton(
            icon: const Icon(Icons.close, color: AppColor.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ],
    );
  }

  Widget _buildCarImage() {
    return Container(
      margin: const EdgeInsets.all(16),
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColor.green.withOpacity(0.3)),
      ),
      child: widget.imageUrl.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                widget.imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      color: AppColor.green,
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) =>
                    _buildImageErrorPlaceholder(),
              ),
            )
          : _buildImageErrorPlaceholder(),
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
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '${widget.make} ${widget.model}\n',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColor.white,
                  fontWeight: FontWeight.w900,
                ),
          ),
          TextSpan(
            text: 'Year: ${widget.year}',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColor.green,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRangeSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Price Range',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColor.white,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColor.black,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColor.green.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: AppColor.green,
                  inactiveTrackColor: AppColor.green.withOpacity(0.2),
                  thumbColor: AppColor.green,
                  overlayColor: AppColor.green.withOpacity(0.2),
                  valueIndicatorColor: AppColor.green,
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
                  Text(
                    'PKR ${_currentRangeValues.start.round()}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColor.green,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    'PKR ${_currentRangeValues.end.round()}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColor.green,
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

  Widget _buildDescriptionField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColor.white,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _descriptionController,
          maxLines: 4,
          style: const TextStyle(color: AppColor.white),
          decoration: InputDecoration(
            hintText: 'Enter car description...',
            hintStyle: TextStyle(color: AppColor.white.withOpacity(0.5)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: AppColor.green.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: AppColor.green),
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
          backgroundColor: AppColor.green,
          foregroundColor: AppColor.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Text(
          'Create Post',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColor.black,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    );
  }

  /// Builds a placeholder for image error or no image selected
  Widget _buildImageErrorPlaceholder() {
    return Container(
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
    );
  }
}
