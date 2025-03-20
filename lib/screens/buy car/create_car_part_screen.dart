// ignore_for_file: deprecated_member_use

import 'package:buyer_centric_app_v2/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CreateCarPartScreen extends StatefulWidget {
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
  final TextEditingController _partNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  String selectedCondition = 'New';
  final List<String> conditionOptions = ['New', 'Used', 'Refurbished'];
  
  final Color primaryColor = AppColor.green;
  final Color backgroundColor = AppColor.black;
  final Color textColor = AppColor.white;

  // Initialize with search query if provided
  @override
  void initState() {
    super.initState();
    if (widget.searchQuery.isNotEmpty) {
      _partNameController.text = widget.searchQuery;
    }
  }

  // Function to create a new part in Firestore
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

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('car_parts').add({
          'sellerId': user.uid,
          'name': _partNameController.text,
          'make': widget.make?.toLowerCase() ?? '',
          'model': widget.model?.toLowerCase() ?? '',
          'partType': widget.partType?.toLowerCase() ?? '',
          'description': _descriptionController.text,
          'price': double.tryParse(_priceController.text) ?? 0.0,
          'condition': selectedCondition,
          'imageUrl': widget.imageUrl ?? '',
          'timestamp': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Part listed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create listing: $e'),
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
                        'List Car Part',
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
              SizedBox(height: appBarHeight + MediaQuery.of(context).padding.top),
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
            _buildPartDetailsSection(),
            Divider(color: primaryColor.withOpacity(0.3)),
            const SizedBox(height: 20),
            _buildImageSection(),
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

  // Widget to build the part details section
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
        _buildDetailTile('Model', widget.model?.toUpperCase() ?? 'Not specified'),
        _buildDetailTile('Part Type', widget.partType?.toUpperCase() ?? 'Not specified'),
        const SizedBox(height: 10),
        _buildConditionDropdown(),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
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

  Widget _buildConditionDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Condition',
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: primaryColor.withOpacity(0.3)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedCondition,
              isExpanded: true,
              dropdownColor: backgroundColor,
              style: TextStyle(color: textColor),
              icon: Icon(Icons.arrow_drop_down, color: primaryColor),
              items: conditionOptions.map((String condition) {
                return DropdownMenuItem<String>(
                  value: condition,
                  child: Text(condition),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedCondition = newValue;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  // Widget to build the part image section
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
          child: widget.imageUrl != null && widget.imageUrl!.isNotEmpty
              ? Image.network(
                  widget.imageUrl!,
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
            onPressed: () {
              // TODO: Implement image upload functionality
            },
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

  // Widget to build the price section
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

  // Widget to build the create listing button
  Widget _buildCreateListingButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _createPartListing,
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