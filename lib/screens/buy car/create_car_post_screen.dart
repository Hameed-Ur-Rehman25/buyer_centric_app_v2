// ignore_for_file: deprecated_member_use

import 'package:buyer_centric_app_v2/theme/colors.dart';
import 'package:buyer_centric_app_v2/utils/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:buyer_centric_app_v2/utils/image_utils.dart';

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

  // Additional car attributes
  final String? color;
  final String? transmission;
  final String? fuelType;
  final String? engine;
  final String? bodyType;
  final List<String>? features;

  // Image gallery
  final List<String>? imageUrls;

  // * Constructor with required parameters
  const CreateCarPostScreen({
    super.key,
    required this.make,
    required this.model,
    required this.year,
    required this.imageUrl,
    this.color,
    this.transmission,
    this.fuelType,
    this.engine,
    this.bodyType,
    this.features,
    this.imageUrls,
  });

  @override
  _CreateCarPostScreenState createState() => _CreateCarPostScreenState();
}

class _CreateCarPostScreenState extends State<CreateCarPostScreen> {
  // * Price range selection
  RangeValues _currentRangeValues = const RangeValues(10000, 50000);
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();

  // * Controllers for form inputs
  final TextEditingController _descriptionController = TextEditingController();
  final Color primaryColor = AppColor.green;
  final Color backgroundColor = AppColor.black;
  final Color textColor = AppColor.white;

  // Image carousel state
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();
  bool _isInitialImageLoading = true;

  // Add isLoading state variable to the class
  bool _isLoading = false;

  // New image carousel widget
  Widget _buildCarImageCarousel() {
    // Use imageUrls array if available, fallback to single imageUrl if not
    final List<String> images =
        widget.imageUrls != null && widget.imageUrls!.isNotEmpty
            ? widget.imageUrls!
            : [widget.imageUrl];

    // Filter out any empty image URLs
    final List<String> validImages =
        images.where((url) => url.isNotEmpty).toList();

    if (validImages.isEmpty) {
      return _buildImageErrorPlaceholder();
    }

    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          height: 220,
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: PageView.builder(
              controller: _pageController,
              itemCount: validImages.length,
              onPageChanged: (index) {
                setState(() {
                  _currentImageIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return ImageUtils.loadNetworkImage(
                  imageUrl: validImages[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  backgroundColor: AppColor.black.withOpacity(0.1),
                  loadingWidget: Center(
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: AppColor.black.withOpacity(0.1),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: AppColor.buttonGreen,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Loading image...',
                              style: TextStyle(
                                color: AppColor.black.withOpacity(0.7),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  errorWidget: Container(
                    color: Colors.grey[200],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.grey,
                          size: 40,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Failed to load image',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {}); // Trigger rebuild to retry loading
                          },
                          child: const Text(
                            'Retry',
                            style: TextStyle(
                              color: AppColor.buttonGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // Loading overlay for initial load
        if (_isInitialImageLoading)
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  color: AppColor.buttonGreen,
                ),
              ),
            ),
          ),

        // Image counter indicator
        if (validImages.length > 1)
          Positioned(
            top: 28,
            right: 28,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColor.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_currentImageIndex + 1}/${validImages.length}',
                style: const TextStyle(
                  color: AppColor.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

        // Navigation arrows
        if (validImages.length > 1) ...[
          // Left arrow
          Positioned(
            left: 28,
            top: 0,
            bottom: 0,
            child: _currentImageIndex > 0
                ? IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColor.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios,
                        color: AppColor.white,
                        size: 16,
                      ),
                    ),
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  )
                : const SizedBox(),
          ),

          // Right arrow
          Positioned(
            right: 28,
            top: 0,
            bottom: 0,
            child: _currentImageIndex < validImages.length - 1
                ? IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColor.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios,
                        color: AppColor.white,
                        size: 16,
                      ),
                    ),
                    onPressed: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  )
                : const SizedBox(),
          ),
        ],
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _minPriceController.text = _currentRangeValues.start.round().toString();
    _maxPriceController.text = _currentRangeValues.end.round().toString();

    // Set initial loading to false after a short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _isInitialImageLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // ! Critical: Creates new post in Firestore
  Future<void> _createPost() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Debug logs for image URLs
        print('Creating post with imageUrl: ${widget.imageUrl}');
        if (widget.imageUrls != null) {
          print(
              'Creating post with imageUrls array: ${widget.imageUrls!.length} images');
          widget.imageUrls!.forEach((url) => print('Image URL: $url'));
        } else {
          print('No imageUrls array provided, using single imageUrl');
        }

        // Prepare post data for Firestore
        final postData = {
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
          // Add additional attributes if available
          if (widget.color != null) 'color': widget.color,
          if (widget.transmission != null) 'transmission': widget.transmission,
          if (widget.fuelType != null) 'fuelType': widget.fuelType,
          if (widget.engine != null) 'engine': widget.engine,
          if (widget.bodyType != null) 'bodyType': widget.bodyType,
          if (widget.features != null) 'features': widget.features,
        };

        // Always include imageUrls field, either from the provided array or create from single imageUrl
        if (widget.imageUrls != null && widget.imageUrls!.isNotEmpty) {
          // Filter out empty URLs
          final List<String> validImageUrls =
              widget.imageUrls!.where((url) => url.isNotEmpty).toList();
          postData['imageUrls'] = validImageUrls;
        } else if (widget.imageUrl.isNotEmpty) {
          // Create a single-item array from imageUrl
          postData['imageUrls'] = [widget.imageUrl];
        } else {
          // Empty array fallback
          postData['imageUrls'] = [];
        }

        // Create the post in Firestore
        await FirebaseFirestore.instance.collection('posts').add(postData);

        // Show success snackbar
        CustomSnackbar.showSuccess(context, 'Post created successfully!');

        // Pop the screen after a short delay to show the snackbar
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.pop(context);
          }
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        CustomSnackbar.showError(
            context, 'You must be logged in to create a post');
      }
    } catch (e) {
      print('Error creating post: $e');
      setState(() {
        _isLoading = false;
      });
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
                    _buildCarImageCarousel(),
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

              // Add additional car details if available
              if (widget.color != null) ...[
                const SizedBox(height: 8),
                _buildDetailRow('Color', widget.color!),
              ],
              if (widget.transmission != null) ...[
                const SizedBox(height: 8),
                _buildDetailRow('Transmission', widget.transmission!),
              ],
              if (widget.fuelType != null) ...[
                const SizedBox(height: 8),
                _buildDetailRow('Fuel Type', widget.fuelType!),
              ],
              if (widget.engine != null) ...[
                const SizedBox(height: 8),
                _buildDetailRow('Engine', widget.engine!),
              ],
              if (widget.bodyType != null) ...[
                const SizedBox(height: 8),
                _buildDetailRow('Body Type', widget.bodyType!),
              ],

              // Display features if available
              if (widget.features != null && widget.features!.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildFeaturesList(context),
              ],
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
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _minPriceController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: AppColor.black),
                      onChanged: (value) {
                        final minPrice =
                            double.tryParse(value) ?? _currentRangeValues.start;
                        if (minPrice <= _currentRangeValues.end &&
                            minPrice >= 0 &&
                            minPrice <= 100000000) {
                          setState(() {
                            _currentRangeValues =
                                RangeValues(minPrice, _currentRangeValues.end);
                          });
                        }
                      },
                      decoration: InputDecoration(
                        prefixText: 'PKR ',
                        prefixStyle: const TextStyle(color: AppColor.black),
                        hintText: 'Min Price',
                        hintStyle:
                            TextStyle(color: AppColor.black.withOpacity(0.5)),
                        filled: true,
                        fillColor: AppColor.white,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: AppColor.buttonGreen.withOpacity(0.3)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: AppColor.buttonGreen),
                        ),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'to',
                      style: TextStyle(color: AppColor.black),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _maxPriceController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: AppColor.black),
                      onChanged: (value) {
                        final maxPrice =
                            double.tryParse(value) ?? _currentRangeValues.end;
                        if (maxPrice >= _currentRangeValues.start &&
                            maxPrice >= 0 &&
                            maxPrice <= 100000000) {
                          setState(() {
                            _currentRangeValues = RangeValues(
                                _currentRangeValues.start, maxPrice);
                          });
                        }
                      },
                      decoration: InputDecoration(
                        prefixText: 'PKR ',
                        prefixStyle: const TextStyle(color: AppColor.black),
                        hintText: 'Max Price',
                        hintStyle:
                            TextStyle(color: AppColor.black.withOpacity(0.5)),
                        filled: true,
                        fillColor: AppColor.white,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: AppColor.buttonGreen.withOpacity(0.3)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: AppColor.buttonGreen),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: AppColor.buttonGreen,
                  inactiveTrackColor: AppColor.buttonGreen.withOpacity(0.2),
                  thumbColor: AppColor.buttonGreen,
                  overlayColor: AppColor.buttonGreen.withOpacity(0.2),
                  valueIndicatorColor: AppColor.buttonGreen,
                  valueIndicatorTextStyle:
                      const TextStyle(color: AppColor.white),
                ),
                child: RangeSlider(
                  values: _currentRangeValues,
                  min: 0,
                  max: 100000000,
                  divisions: 100,
                  labels: RangeLabels(
                    'PKR ${_currentRangeValues.start.round()}',
                    'PKR ${_currentRangeValues.end.round()}',
                  ),
                  onChanged: (values) {
                    setState(() {
                      _currentRangeValues = values;
                      _minPriceController.text =
                          values.start.round().toString();
                      _maxPriceController.text = values.end.round().toString();
                    });
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Min: PKR ${_currentRangeValues.start.round()}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColor.black.withOpacity(0.7),
                          fontSize: 12,
                        ),
                  ),
                  Text(
                    'Max: PKR ${_currentRangeValues.end.round()}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColor.black.withOpacity(0.7),
                          fontSize: 12,
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
        onPressed: _isLoading
            ? null
            : () {
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
        child: _isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: AppColor.white,
                      strokeWidth: 2,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Creating post...',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColor.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              )
            : Text(
                'Create Post',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColor.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
      ),
    );
  }

  Widget _buildImageErrorPlaceholder() {
    return Container(
      margin: const EdgeInsets.all(16),
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColor.grey.withOpacity(0.3)),
        color: Colors.grey[200],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.car_crash_outlined,
            color: Colors.grey,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            'No car images available',
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Features list widget
  Widget _buildFeaturesList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(
          color: AppColor.buttonGreen,
          thickness: 0.5,
          height: 16,
        ),
        Text(
          'Features',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColor.black,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.features!
              .map((feature) => _buildFeatureChip(feature))
              .toList(),
        ),
      ],
    );
  }

  // Feature chip widget
  Widget _buildFeatureChip(String feature) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColor.buttonGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColor.buttonGreen.withOpacity(0.3)),
      ),
      child: Text(
        feature,
        style: TextStyle(
          color: AppColor.black.withOpacity(0.8),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
