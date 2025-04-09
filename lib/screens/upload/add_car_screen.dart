import 'package:buyer_centric_app_v2/services/car_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:buyer_centric_app_v2/theme/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddCarScreen extends StatefulWidget {
  const AddCarScreen(BuildContext context, {super.key});

  @override
  State<AddCarScreen> createState() => _AddCarScreenState();
}

class _AddCarScreenState extends State<AddCarScreen> {
  String? selectedMake;
  String? selectedModel;
  String? selectedVariant;
  int? selectedYear;
  final List<File> _imageFiles = [];
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _mileageController = TextEditingController();
  String? selectedCondition;
  // Initialize CarStorageService
  final CarStorageService _carStorageService = CarStorageService();

  bool _isLoading = false;

  // Car data lists
  final List<String> _carMakes = [
    'Toyota',
    'Honda',
    'Ford',
    'Chevrolet',
    'Nissan'
  ];
  final Map<String, List<String>> _makeToModels = {
    'Toyota': ['Camry', 'Corolla', 'Prius'],
    'Honda': ['Civic', 'Accord', 'Fit'],
    'Ford': ['Focus', 'Mustang', 'Explorer'],
    'Chevrolet': ['Malibu', 'Impala', 'Cruze'],
    'Nissan': ['Altima', 'Sentra', 'Maxima']
  };

  // Years list for dropdown (current year to 1970)
  final List<int> _years = List.generate(
      DateTime.now().year - 1969, (index) => DateTime.now().year - index);

  // Car condition options
  final List<String> _conditions = ['Excellent', 'Good', 'Fair', 'Poor'];
  final TextEditingController _yearController = TextEditingController();

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _imageFiles.add(File(image.path));
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _imageFiles.removeAt(index);
    });
  }

  /// Handles the submission of the car details form.
  /// Validates the input fields, uploads the car data, and provides feedback to the user.
  Future<void> _handleSubmit() async {
    // Check if all required fields are filled
    if (_imageFiles.isEmpty ||
        selectedMake == null ||
        selectedModel == null ||
        _descriptionController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _yearController.text.isEmpty) {
      // Show a snackbar if any required field is missing
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    // Set loading state to true
    setState(() {
      _isLoading = true;
    });

    try {
      // Attempt to upload the car details using the CarStorageService
      await _carStorageService.addCompleteCar(
        imageFiles: _imageFiles,
        make: selectedMake!,
        model: selectedModel!,
        description: _descriptionController.text,
        price: double.parse(_priceController.text),
        variant: selectedVariant,
        year: int.parse(_yearController.text),
        mileage: _mileageController.text.isNotEmpty
            ? int.parse(_mileageController.text)
            : null,
        condition: selectedCondition,
      );

      // If the widget is still mounted, show success feedback and navigate back
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Car added successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      // Handle any errors during the upload process
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add car: ${e.toString()}')),
        );
      }
    } finally {
      // Reset the loading state if the widget is still mounted
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Upload Images',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColor.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You can upload multiple images',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColor.black.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 10),

              // Image Preview Grid
              if (_imageFiles.isNotEmpty)
                Container(
                  height: 120,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _imageFiles.length,
                    itemBuilder: (context, index) {
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
                                _imageFiles[index],
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

              // Enhanced Image Upload Section
              GestureDetector(
                onTap: _pickImage,
                child: DottedBorder(
                  borderType: BorderType.RRect,
                  radius: const Radius.circular(12),
                  color: AppColor.grey,
                  strokeWidth: 2,
                  dashPattern: const [8, 4],
                  child: Container(
                    height: 120,
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
                          _imageFiles.isEmpty
                              ? 'Tap to upload car images'
                              : 'Tap to add more images',
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
              const SizedBox(height: 24),

              // Enhanced Car Details Form
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColor.black,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDropdown('Make', _carMakes, selectedMake, (value) {
                      setState(() {
                        selectedMake = value;
                        selectedModel = null;
                      });
                    }),
                    const SizedBox(height: 16),
                    _buildDropdown(
                      'Model',
                      _makeToModels[selectedMake] ?? [],
                      selectedModel,
                      (value) => setState(() => selectedModel = value),
                      enabled: selectedMake != null,
                    ),
                    const SizedBox(height: 16),
                    // Year text field
                    _buildTextField(
                      'Year',
                      _yearController,
                      keyboardType: TextInputType.number,
                      hint: 'Enter car year',
                    ),
                    const SizedBox(height: 16),
                    // Mileage field
                    _buildTextField(
                      'Mileage (km)',
                      _mileageController,
                      keyboardType: TextInputType.number,
                      hint: 'Enter car mileage in kilometers',
                    ),
                    const SizedBox(height: 16),
                    // Condition dropdown
                    _buildDropdown(
                      'Condition',
                      _conditions,
                      selectedCondition,
                      (value) => setState(() => selectedCondition = value),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      'Description',
                      _descriptionController,
                      maxLines: 3,
                      hint: 'Enter car description',
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      'Price',
                      _priceController,
                      keyboardType: TextInputType.number,
                      hint: 'Enter car price',
                      prefix: 'PKR ',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Custom Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColor.buttonGreen,
                    side: BorderSide(
                      color: _isLoading ? Colors.grey : Colors.white,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 12),
                  ),
                  child: _isLoading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              "Adding...",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_circle_outline,
                              color: Colors.white,
                              size: 24,
                            ),
                            SizedBox(width: 12),
                            Text(
                              "Add to catalog",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
          color: Colors.black,
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
                    CircleAvatar(
                      radius: profileIconSize / 2,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: profileIconSize * 0.6,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    // Title
                    Text(
                      'Add Car',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth * 0.055,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // User Avatar
                    CircleAvatar(
                      radius: avatarSize / 2,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
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

  // Enhanced dropdown builder
  Widget _buildDropdown(
    String label,
    List<String> items,
    String? value,
    void Function(String?) onChanged, {
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColor.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      item,
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                );
              }).toList(),
              onChanged: enabled ? onChanged : null,
              isExpanded: true,
              hint: Text(
                'Select $label',
                style: TextStyle(color: AppColor.grey.withOpacity(0.5)),
              ),
              dropdownColor: Colors.white,
              style: const TextStyle(color: Colors.black),
              menuMaxHeight: 300,
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
      ],
    );
  }

  // Enhanced text field builder
  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    TextInputType? keyboardType,
    String? hint,
    String? prefix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColor.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              prefixText: prefix,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }
}
