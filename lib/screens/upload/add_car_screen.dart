import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:buyer_centric_app_v2/theme/colors.dart';

class AddCarScreen extends StatefulWidget {
  const AddCarScreen({super.key});

  @override
  State<AddCarScreen> createState() => _AddCarScreenState();
}

class _AddCarScreenState extends State<AddCarScreen> {
  String? selectedMake;
  String? selectedModel;
  String? selectedVariant;
  int? selectedYear;
  File? _imageFile;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  //TODO: Add CarStorageService
  // final CarStorageService _carStorageService = CarStorageService();

  final bool _isLoading = false;

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

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  // Future<void> _handleSubmit() async {
  //   if (_imageFile == null ||
  //       selectedMake == null ||
  //       selectedModel == null ||
  //       _descriptionController.text.isEmpty ||
  //       _priceController.text.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Please fill all required fields')),
  //     );
  //     return;
  //   }

  //   setState(() {
  //     _isLoading = true;
  //   });

  //   try {
  //     await _carStorageService.addCompleteCar(
  //       imageFile: _imageFile!,
  //       make: selectedMake!,
  //       model: selectedModel!,
  //       description: _descriptionController.text,
  //       price: double.parse(_priceController.text),
  //       variant: selectedVariant,
  //       year: selectedYear,
  //     );

  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Car added successfully!')),
  //       );
  //       Navigator.pop(context);
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Failed to add car: ${e.toString()}')),
  //       );
  //     }
  //   } finally {
  //     if (mounted) {
  //       setState(() {
  //         _isLoading = false;
  //       });
  //     }
  //   }
  // }

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
                'Upload Image',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColor.black,
                ),
              ),
              const SizedBox(height: 10),

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
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _imageFile != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(_imageFile!, fit: BoxFit.cover),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate,
                                size: 50,
                                color: AppColor.black.withOpacity(0.5),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap to upload car image',
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
                  //TODO: Add onPressed
                  // onPressed: _isLoading ? null : _handleSubmit,
                  onPressed: () {},
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
                    CircleAvatar(
                      radius: profileIconSize / 2,
                      backgroundColor: Colors.black.withOpacity(0.2),
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          color: Colors.black,
                          size: profileIconSize * 0.6,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    // Title
                    Text(
                      'Add Car',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: screenWidth * 0.055,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // User Avatar
                    CircleAvatar(
                      radius: avatarSize / 2,
                      backgroundColor: Colors.black.withOpacity(0.2),
                      child: Icon(
                        Icons.person,
                        color: Colors.black,
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
            color: AppColor.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: enabled ? onChanged : null,
              isExpanded: true,
              hint: Text(
                'Select $label',
                style: TextStyle(color: AppColor.grey.withOpacity(0.5)),
              ),
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
