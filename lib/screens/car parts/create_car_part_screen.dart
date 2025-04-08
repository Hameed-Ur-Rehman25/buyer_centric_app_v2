/*
 * ! IMPORTANT: Screen for creating new car part listings
 * 
 * * Key Features:
 * * - Part details input
 * * - Image upload/selection
 * * - Price setting
 * * - Description input
 * * - Firebase integration
 * 
 * @see CarPartsScreen
 */

import 'dart:io';
import 'package:buyer_centric_app_v2/theme/colors.dart';
import 'package:buyer_centric_app_v2/utils/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:buyer_centric_app_v2/services/storage_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:buyer_centric_app_v2/services/car_parts_storage_service.dart';

class CreateCarPartScreen extends StatefulWidget {
  ///! Required properties for part creation
  final String searchQuery;
  final String? make;
  final String? model;
  final String? partType;
  final String? imageUrl;
  final bool isImageFromDatabase;
  final String partName;

  const CreateCarPartScreen({
    super.key,
    this.searchQuery = '',
    this.make,
    this.model,
    this.partType,
    this.imageUrl,
    this.isImageFromDatabase = false,
    this.partName = '',
  });

  @override
  _CreateCarPartScreenState createState() => _CreateCarPartScreenState();
}

class _CreateCarPartScreenState extends State<CreateCarPartScreen> {
  /// * Controllers for form inputs
  final TextEditingController _partNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();

  /// * Services
  // final StorageService _storageService = StorageService(); //TODO: Uncomment this line
  final ImagePicker _imagePicker = ImagePicker();

  /// ? Track states
  String selectedCondition = 'New';
  List<File> _selectedImages = [];
  bool _isLoading = false;
  RangeValues _currentRangeValues = const RangeValues(1000, 10000);

  /// * Available condition options
  final List<String> conditionOptions = ['New', 'Used', 'Refurbished'];

  @override
  void initState() {
    super.initState();
    if (widget.partName.isNotEmpty) {
      _partNameController.text = widget.partName;
    } else if (widget.searchQuery.isNotEmpty) {
      _partNameController.text = widget.searchQuery;
    }
    _minPriceController.text = _currentRangeValues.start.round().toString();
    _maxPriceController.text = _currentRangeValues.end.round().toString();
  }

  @override
  void dispose() {
    _partNameController.dispose();
    _descriptionController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image =
          await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() => _selectedImages.add(File(image.path)));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  /// Helper method to capitalize first letter
  String capitalizeFirstLetter(String? text) {
    if (text == null || text.isEmpty) return '';
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  /// ! Critical: Creates new part listing in Firestore
  Future<void> _createCarPartsPost() async {
    // Check if part type is empty
    if (_partNameController.text.trim().isEmpty) {
      CustomSnackbar.showError(context, 'Please enter the part type');
      return;
    }

    // Check for image based on the image source
    if (!widget.isImageFromDatabase) {
      if (_selectedImages.isEmpty) {
        CustomSnackbar.showError(context, 'Please upload at least one image');
        return;
      }
    } else if (widget.imageUrl == null || widget.imageUrl!.isEmpty) {
      CustomSnackbar.showError(context, 'No image found from database');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Capitalize make and model
        final capitalizedMake = capitalizeFirstLetter(widget.make);
        final capitalizedModel = capitalizeFirstLetter(widget.model);

        List<String> imageUrls = [];
        if (!widget.isImageFromDatabase && _selectedImages.isNotEmpty) {
          // Upload the images to Firebase Storage
          final CarPartsStorageService storageService =
              CarPartsStorageService();
          imageUrls =
              await storageService.uploadMultipleCarPartImages(_selectedImages);
        } else if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
          imageUrls = [widget.imageUrl!];
        }

        await FirebaseFirestore.instance.collection('posts').add({
          'userId': user.uid,
          'make': capitalizedMake,
          'model': capitalizedModel,
          'name': _partNameController.text.trim(),
          'partType': widget.partType?.toLowerCase(),
          'imageUrls': imageUrls,
          'mainImageUrl': imageUrls.isNotEmpty ? imageUrls[0] : '',
          'minPrice': _currentRangeValues.start.toInt(),
          'maxPrice': _currentRangeValues.end.toInt(),
          'description': _descriptionController.text.trim(),
          'timestamp': FieldValue.serverTimestamp(),
          'searchKeywords': _generateSearchKeywords(),
          'condition': selectedCondition,
          'category': 'car_part',
          'offers': [],
        });

        if (mounted) {
          CustomSnackbar.showSuccess(
              context, 'Car part post created successfully!');
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.showError(context, 'Failed to create car part post: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<String> _generateSearchKeywords() {
    final Set<String> keywords = {};
    void addKeywords(String? text) {
      if (text != null && text.isNotEmpty) {
        keywords.addAll(text.toLowerCase().split(' '));
      }
    }

    addKeywords(widget.make);
    addKeywords(widget.model);
    addKeywords(_partNameController.text);
    addKeywords(_descriptionController.text);
    return keywords.toList();
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
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _buildImageSection(),
                    _buildDetailsSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
              'CREATE CAR PART POST',
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

  Widget _buildImageSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (_selectedImages.isNotEmpty)
            Container(
              height: 120,
              margin: const EdgeInsets.only(bottom: 16),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount:
                    _selectedImages.length + 1, // +1 for the upload container
                itemBuilder: (context, index) {
                  if (index == _selectedImages.length) {
                    // Upload container
                    return GestureDetector(
                      onTap: widget.isImageFromDatabase ? null : _pickImage,
                      child: Container(
                        width: 120,
                        height: 120,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColor.grey.withOpacity(0.3),
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate,
                              size: 30,
                              color: AppColor.black.withOpacity(0.5),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add More',
                              style: TextStyle(
                                color: AppColor.black.withOpacity(0.5),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // Image preview
                  return Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColor.grey.withOpacity(0.3),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _selectedImages[index],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 5,
                        right: 13,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.7),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 20,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                      if (index == 0)
                        Positioned(
                          bottom: 5,
                          left: 5,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColor.appBarColor.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'Main',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          if (_selectedImages.isEmpty)
            GestureDetector(
              onTap: widget.isImageFromDatabase ? null : _pickImage,
              child: DottedBorder(
                borderType: BorderType.RRect,
                radius: const Radius.circular(12),
                color: AppColor.grey,
                strokeWidth: 2,
                dashPattern: const [8, 4],
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate,
                        size: 40,
                        color: AppColor.black.withOpacity(0.5),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.isImageFromDatabase
                            ? 'No database image found'
                            : 'Tap to upload car images',
                        style: TextStyle(
                          color: AppColor.black.withOpacity(0.5),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPartInfo(),
          const SizedBox(height: 20),
          _buildPriceRangeSection(),
          const SizedBox(height: 20),
          _buildDescriptionField(),
          const SizedBox(height: 20),
          _buildCreateButton(),
        ],
      ),
    );
  }

  Widget _buildPartInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Part Details',
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
            controller: _partNameController,
            style: const TextStyle(color: AppColor.black),
            readOnly: widget.partName.isNotEmpty,
            decoration: InputDecoration(
              hintText: 'Enter part name',
              hintStyle: TextStyle(color: AppColor.black.withOpacity(0.5)),
              filled: true,
              fillColor: widget.partName.isNotEmpty
                  ? AppColor.black.withOpacity(0.05)
                  : AppColor.white,
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
                    'Vehicle Details',
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
              _buildDetailRow('Make', widget.make ?? 'N/A'),
              const SizedBox(height: 8),
              _buildDetailRow('Model', widget.model ?? 'N/A'),
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
          capitalizeFirstLetter(value),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColor.black,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }

  Widget _buildPriceRangeSection() {
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
                color: AppColor.buttonGreen.withOpacity(0.3),
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
                            minPrice <= 100000) {
                          setState(() {
                            _currentRangeValues = RangeValues(
                              minPrice,
                              _currentRangeValues.end,
                            );
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
                            maxPrice <= 100000) {
                          setState(() {
                            _currentRangeValues = RangeValues(
                              _currentRangeValues.start,
                              maxPrice,
                            );
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

  Widget _buildDescriptionField() {
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
              hintText: 'Enter part description...',
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

  Widget _buildCreateButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _createCarPartsPost,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.buttonGreen,
          foregroundColor: AppColor.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: AppColor.black)
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
}
