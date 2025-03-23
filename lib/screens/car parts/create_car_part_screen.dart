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
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:buyer_centric_app_v2/services/storage_service.dart';
import 'package:image_picker/image_picker.dart';
import 'utils/custom_dropdown.dart';
import 'utils/autocomplete_field.dart';

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
  final TextEditingController _priceController = TextEditingController();

  /// * Services
  // final StorageService _storageService = StorageService(); //TODO: Uncomment this line
  final ImagePicker _imagePicker = ImagePicker();

  /// ? Track states
  String selectedCondition = 'New';
  File? _selectedImage;
  bool _isLoading = false;

  /// * Available condition options
  final List<String> conditionOptions = ['New', 'Used', 'Refurbished'];

  final Color primaryColor = AppColor.green;
  final Color backgroundColor = AppColor.black;
  final Color textColor = AppColor.white;

  @override
  void initState() {
    super.initState();
    if (widget.searchQuery.isNotEmpty) {
      _partNameController.text = widget.searchQuery;
    }
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
    if (_partNameController.text.isEmpty || _priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String? imageUrl = widget.imageUrl;

        // Upload new image if selected
        // if (_selectedImage != null) {
        //   imageUrl = await _storageService.uploadFile(
        //     _selectedImage!,
        //     'car_parts/${widget.make}_${widget.model}_${widget.partType}',
        //   );
        // }

        await FirebaseFirestore.instance.collection('car_parts').add({
          'sellerId': user.uid,
          'name': _partNameController.text,
          'make': widget.make?.toLowerCase() ?? '',
          'model': widget.model?.toLowerCase() ?? '',
          'partType': widget.partType?.toLowerCase() ?? '',
          'description': _descriptionController.text,
          'price': double.tryParse(_priceController.text) ?? 0.0,
          'condition': selectedCondition,
          'imageUrl': imageUrl ?? '',
          'timestamp': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Part listed successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create listing: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
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
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _buildImageSection(),
                    _buildContentCard(),
                    SizedBox(
                        height: MediaQuery.of(context).viewInsets.bottom + 20),
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

  /// * Builds the main content card
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
            _buildPartDetailsSection(),
            Divider(color: primaryColor.withOpacity(0.3)),
            const SizedBox(height: 20),
            _buildPriceSection(),
            Divider(color: primaryColor.withOpacity(0.3)),
            const SizedBox(height: 20),
            _buildDescriptionSection(),
            const SizedBox(height: 24),
            _buildCreateListingButton(),
          ],
        ),
      ),
    );
  }

  /// * Builds the part details section with form fields
  Widget _buildPartDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Part Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 16),
        _buildTextField('Part Name', _partNameController),
        const SizedBox(height: 10),
        _buildDetailTile('Make', widget.make?.toUpperCase() ?? 'Not specified'),
        _buildDetailTile(
            'Model', widget.model?.toUpperCase() ?? 'Not specified'),
        _buildDetailTile(
            'Part Type', widget.partType?.toUpperCase() ?? 'Not specified'),
        const SizedBox(height: 10),
        CustomDropdown(
          label: 'Condition',
          items: conditionOptions,
          value: selectedCondition,
          onChanged: (value) {
            if (value != null) {
              setState(() => selectedCondition = value);
            }
          },
        ),
      ],
    );
  }

  /// * Builds custom text input fields
  Widget _buildTextField(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: TextStyle(color: textColor),
          decoration: InputDecoration(
            hintText: 'Enter $label...',
            hintStyle: TextStyle(color: Colors.grey.withOpacity(0.7)),
            filled: true,
            fillColor: backgroundColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
            ),
          ),
        ),
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

  /// * Builds the image upload section
  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Part Image',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: _selectedImage != null
              ? Image.file(
                  _selectedImage!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
              : widget.imageUrl != null && widget.imageUrl!.isNotEmpty
                  ? Image.network(
                      widget.imageUrl!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return _buildLoadingContainer();
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return _buildImagePlaceholder(
                          Icons.broken_image_rounded,
                          'Image not available',
                        );
                      },
                    )
                  : _buildImagePlaceholder(
                      Icons.add_photo_alternate_outlined,
                      'Add part image',
                    ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.upload_file),
            label: const Text('Upload Image'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor.withOpacity(0.2),
              foregroundColor: primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingContainer() {
    return Container(
      height: 200,
      width: double.infinity,
      color: backgroundColor,
      child: Center(
        child: CircularProgressIndicator(
          color: primaryColor,
        ),
      ),
    );
  }

  /// * Builds placeholder for missing images
  Widget _buildImagePlaceholder(IconData icon, String text) {
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
            icon,
            size: 50,
            color: primaryColor.withOpacity(0.5),
          ),
          const SizedBox(height: 8),
          Text(
            text,
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

  /// * Builds the price input section
  Widget _buildPriceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Price',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _priceController,
          keyboardType: TextInputType.number,
          style: TextStyle(color: textColor),
          decoration: InputDecoration(
            hintText: 'Enter price in PKR',
            hintStyle: TextStyle(color: Colors.grey.withOpacity(0.7)),
            filled: true,
            fillColor: backgroundColor,
            prefixIcon: Icon(
              Icons.attach_money,
              color: primaryColor,
            ),
            prefixText: 'PKR ',
            prefixStyle: TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.bold,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
            ),
          ),
        ),
      ],
    );
  }

  /// * Builds the description input area
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
          decoration: InputDecoration(
            hintText: 'Enter part description...',
            hintStyle: TextStyle(color: Colors.grey.withOpacity(0.7)),
            filled: true,
            fillColor: backgroundColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
            ),
          ),
        ),
      ],
    );
  }

  /// * Builds the create listing button
  Widget _buildCreateListingButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _createPartListing,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(textColor),
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_circle_outline, size: 24),
                  SizedBox(width: 10),
                  Text(
                    'Create Listing',
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
