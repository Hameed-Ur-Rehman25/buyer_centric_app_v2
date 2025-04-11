/*
 * ! IMPORTANT: This file contains the main car parts search and listing screen

 * * Key Features:
 * * - Car parts search functionality
 * * - Filter system for make, model, and part type
 * * - Image source selection
 * * - Real-time parts listing display
 */
import 'package:buyer_centric_app_v2/utils/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:buyer_centric_app_v2/theme/colors.dart';
import 'package:buyer_centric_app_v2/widgets/custom_app_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:buyer_centric_app_v2/screens/car%20parts/create_car_part_screen.dart';
import 'utils/filter_container.dart';
import 'utils/available_parts_list.dart';
import 'utils/models/car_data.dart';

class CarPartsScreen extends StatefulWidget {
  const CarPartsScreen({super.key});

  @override
  State<CarPartsScreen> createState() => _CarPartsScreenState();
}

class _CarPartsScreenState extends State<CarPartsScreen> {
  String? selectedMake;
  String? selectedModel;
  String? selectedPartType;
  String? selectedImageOption;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      //! Trigger rebuild to update the query
    });
  }

  Future<void> _searchParts() async {
    if (selectedMake == null ||
        selectedModel == null ||
        selectedPartType == null ||
        selectedImageOption == null) {
      CustomSnackbar.showError(
          context, 'Please select make, model, part type, and image option');
      return;
    }

    setState(() => _isSearching = true);

    try {
      if (selectedImageOption == 'Retrieve from Database') {
        final querySnapshot = await _buildPartsQuery().get();

        if (mounted) {
          if (querySnapshot.docs.isEmpty) {
            CustomSnackbar.showError(
                context, 'No matching parts found in database');
            // Do not navigate to create screen if no matches found
            setState(() => _isSearching = false);
          } else {
            CustomSnackbar.showSuccess(
                context, 'Matching parts found in database');

            // Get the first matching part's image URL
            String? imageUrl;
            if (querySnapshot.docs.isNotEmpty) {
              final partData =
                  querySnapshot.docs.first.data() as Map<String, dynamic>;
              // Check for mainImageUrl first, fall back to imageUrl if needed
              imageUrl = partData['mainImageUrl'] as String? ??
                  partData['imageUrl'] as String?;

              // If mainImageUrl/imageUrl is null but imageUrls array exists, use the first one
              if (imageUrl == null &&
                  partData['imageUrls'] != null &&
                  (partData['imageUrls'] as List).isNotEmpty) {
                imageUrl = (partData['imageUrls'] as List).first.toString();
              }
            }

            // Navigate to create screen with the found image
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => DraggableScrollableSheet(
                initialChildSize: 0.9,
                minChildSize: 0.5,
                maxChildSize: 0.95,
                builder: (context, scrollController) => CreateCarPartScreen(
                  searchQuery: _searchController.text,
                  make: selectedMake,
                  model: selectedModel,
                  partType: selectedPartType,
                  imageUrl: imageUrl,
                  isImageFromDatabase: true,
                  partName: selectedPartType != 'Other'
                      ? (selectedPartType ?? '')
                      : '',
                ),
              ),
            );
          }
        }
      } else {
        _showCreatePartScreen();
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.showError(context, 'Error: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  void _showCreatePartScreen() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => CreateCarPartScreen(
          searchQuery: _searchController.text,
          make: selectedMake,
          model: selectedModel,
          partType: selectedPartType,
          isImageFromDatabase: selectedImageOption == 'Retrieve from Database',
          partName: selectedPartType != 'Other' ? (selectedPartType ?? '') : '',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Dismiss keyboard and any open dropdowns when tapping outside
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: AppColor.white,
        appBar: const CustomAppBar(showSearchBar: false),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // _buildSearchBar(),
              FilterContainer(
                selectedMake: selectedMake,
                selectedModel: selectedModel,
                selectedPartType: selectedPartType,
                selectedImageOption: selectedImageOption,
                carMakes: CarData.carMakes,
                makeToModels: CarData.makeToModels,
                partTypes: CarData.partTypes,
                imageOptions: CarData.imageOptions,
                onMakeSelected: (value) {
                  setState(() {
                    selectedMake = value;
                    selectedModel = null;
                  });
                },
                onModelSelected: (value) =>
                    setState(() => selectedModel = value),
                onPartTypeSelected: (value) =>
                    setState(() => selectedPartType = value),
                onImageOptionSelected: (value) =>
                    setState(() => selectedImageOption = value),
                onContinue: _searchParts,
                isSearching: _isSearching,
                continueButtonStyle: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Row(
                  children: [
                    Text(
                      'Available Parts',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: GoogleFonts.montserrat().fontFamily,
                        color: AppColor.black,
                      ),
                    ),
                  ],
                ),
              ),
              AvailablePartsList(
                query: _buildPartsQuery().snapshots(),
                onTapPart: _showPartDetails,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for parts by name, description...',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onSubmitted: (_) => _searchParts(),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: _searchParts,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.buttonGreen,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Search',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Query _buildPartsQuery() {
    Query query = FirebaseFirestore.instance.collection('carParts');

    // Apply filters if selected
    if (selectedMake != null) {
      query = query.where('make', isEqualTo: selectedMake!.toLowerCase());
    }
    if (selectedModel != null) {
      query = query.where('model', isEqualTo: selectedModel!.toLowerCase());
    }
    if (selectedPartType != null) {
      query =
          query.where('partType', isEqualTo: selectedPartType!.toLowerCase());
    }

    // Apply text search if there's input
    final searchText = _searchController.text.trim().toLowerCase();
    if (searchText.isNotEmpty) {
      // Search in name and description fields
      query = query.where('searchKeywords', arrayContains: searchText);
    }

    return query.limit(20);
  }

  void _showPartDetails(Map<String, dynamic> partData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              partData['name'] ?? 'Part Details',
              style: TextStyle(
                fontFamily: GoogleFonts.montserrat().fontFamily,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            if (partData['imageUrl'] != null &&
                partData['imageUrl'].toString().isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  partData['imageUrl'],
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 15),
            _buildDetailRow(
                'Price', 'PKR ${partData['price']?.toString() ?? 'N/A'}'),
            _buildDetailRow(
                'Make', (partData['make'] ?? 'N/A').toString().toUpperCase()),
            _buildDetailRow(
                'Model', (partData['model'] ?? 'N/A').toString().toUpperCase()),
            _buildDetailRow('Part Type', partData['partType'] ?? 'N/A'),
            _buildDetailRow('Condition', partData['condition'] ?? 'N/A'),
            const SizedBox(height: 10),
            Text(
              'Description',
              style: TextStyle(
                fontFamily: GoogleFonts.montserrat().fontFamily,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              partData['description'] ?? 'No description available',
              style: TextStyle(
                fontFamily: GoogleFonts.inter().fontFamily,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.buttonGreen,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Contact Seller',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontFamily: GoogleFonts.montserrat().fontFamily,
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontFamily: GoogleFonts.inter().fontFamily,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
