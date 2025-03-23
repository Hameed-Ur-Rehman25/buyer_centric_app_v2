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
import 'utils/custom_dropdown.dart';
import 'package:dotted_border/dotted_border.dart';

class CreateCarPartScreen extends StatefulWidget {
  /// ! Required properties for part creation
  final String searchQuery;
  final String? make;
  final String? model;
  final String? partType;
  final String? imageUrl;

  const CreateCarPartScreen({
    super.key,
    this.searchQuery = '',
    this.make,
    this.model,
    this.partType,
    this.imageUrl,
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
  File? _selectedImage;
  bool _isLoading = false;
  RangeValues _currentRangeValues = const RangeValues(1000, 10000);

  /// * Available condition options
  final List<String> conditionOptions = ['New', 'Used', 'Refurbished'];

  @override
  void initState() {
    super.initState();
    if (widget.searchQuery.isNotEmpty) {
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
        setState(() => _selectedImage = File(image.path));
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

  /// ! Critical: Creates new part listing in Firestore
  Future<void> _createPartListing() async {
    if (_partNameController.text.isEmpty) {
      CustomSnackbar.showError(context, 'Please enter part name');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('carParts').add({
          'userId': user.uid,
          'make': widget.make?.toLowerCase(),
          'model': widget.model?.toLowerCase(),
          'partType': _partNameController.text.toLowerCase(),
          'imageUrl': widget.imageUrl ?? '',
          'minPrice': _currentRangeValues.start.toInt(),
          'maxPrice': _currentRangeValues.end.toInt(),
          'description': _descriptionController.text,
          'timestamp': FieldValue.serverTimestamp(),
          'searchKeywords': _generateSearchKeywords(),
        });

        if (mounted) {
          CustomSnackbar.showSuccess(
              context, 'Part listing created successfully!');
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.showError(context, 'Failed to create listing: $e');
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
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
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
      ),
    );
  }

  Widget _buildHeader() {
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
            'CREATE PART LISTING',
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

  Widget _buildImageSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: GestureDetector(
        onTap: _pickImage,
        child: Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColor.green.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: AppColor.green.withOpacity(0.4),
                spreadRadius: 3,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: _selectedImage != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.file(_selectedImage!, fit: BoxFit.cover),
                )
              : widget.imageUrl != null && widget.imageUrl!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.network(
                        widget.imageUrl!,
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
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate,
                          size: 50,
                          color: AppColor.green.withOpacity(0.5),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Tap to add image',
                          style: TextStyle(
                            color: AppColor.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
        ),
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
                color: AppColor.white,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: AppColor.green.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _partNameController,
            style: const TextStyle(color: AppColor.white),
            decoration: InputDecoration(
              hintText: 'Enter part name',
              hintStyle: TextStyle(color: AppColor.white.withOpacity(0.5)),
              filled: true,
              fillColor: AppColor.black,
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
        ),
        const SizedBox(height: 10),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '${widget.make} ${widget.model}\n',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColor.white,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
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
            boxShadow: [
              BoxShadow(
                color: AppColor.green.withOpacity(0.3),
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
                      style: const TextStyle(color: AppColor.white),
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
                        prefixStyle: const TextStyle(color: AppColor.white),
                        hintText: 'Min Price',
                        hintStyle:
                            TextStyle(color: AppColor.white.withOpacity(0.5)),
                        filled: true,
                        fillColor: AppColor.black,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: AppColor.green.withOpacity(0.3)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColor.green),
                        ),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'to',
                      style: TextStyle(color: AppColor.white),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _maxPriceController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: AppColor.white),
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
                        prefixStyle: const TextStyle(color: AppColor.white),
                        hintText: 'Max Price',
                        hintStyle:
                            TextStyle(color: AppColor.white.withOpacity(0.5)),
                        filled: true,
                        fillColor: AppColor.black,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: AppColor.green.withOpacity(0.3)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColor.green),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
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
                          color: AppColor.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                  ),
                  Text(
                    'Max: PKR ${_currentRangeValues.end.round()}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColor.white.withOpacity(0.7),
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
                color: AppColor.white,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: AppColor.green.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _descriptionController,
            maxLines: 4,
            style: const TextStyle(color: AppColor.white),
            decoration: InputDecoration(
              hintText: 'Enter part description...',
              hintStyle: TextStyle(color: AppColor.white.withOpacity(0.5)),
              filled: true,
              fillColor: AppColor.black,
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
        ),
      ],
    );
  }

  Widget _buildCreateButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _createPartListing,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.green,
          foregroundColor: AppColor.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: AppColor.white)
            : Text(
                'Create Listing',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColor.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
      ),
    );
  }
}
