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
  final List<String> _partTypes = [
    'Engine',
    'Transmission',
    'Brakes',
    'Suspension',
    'Electrical',
    'Body Parts',
    'Interior',
    'Exterior',
    'Other'
  ];
  final List<String> _imageOptions = [
    'Retrieve from Database',
    'Upload New Image'
  ];

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
        final querySnapshot = await FirebaseFirestore.instance
            .collection('carParts')
            .where('make', isEqualTo: selectedMake!.toLowerCase())
            .where('model', isEqualTo: selectedModel!.toLowerCase())
            .where('partType', isEqualTo: selectedPartType!.toLowerCase())
            .get();

        if (mounted) {
          if (querySnapshot.docs.isEmpty) {
            CustomSnackbar.showError(
                context, 'No matching images found in database');
          } else {
            CustomSnackbar.showSuccess(
                context, 'Matching images found in database');
          }
        }
      } else {
        // Show CreateCarPartScreen as bottom sheet instead of navigation
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
            ),
          ),
        );
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
              _buildSearchBar(),
              _buildFilterContainer(),
              _buildSearchResults(),
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
                hintText: 'Search for parts...',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {
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
                  ),
                ),
              );
            },
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

  Widget _buildFilterContainer() {
    return FilterContainer(
      selectedMake: selectedMake,
      selectedModel: selectedModel,
      selectedPartType: selectedPartType,
      selectedImageOption: selectedImageOption,
      carMakes: _carMakes,
      makeToModels: _makeToModels,
      partTypes: _partTypes,
      imageOptions: _imageOptions,
      onMakeSelected: (value) {
        setState(() {
          selectedMake = value;
          selectedModel = null;
        });
      },
      onModelSelected: (value) => setState(() => selectedModel = value),
      onPartTypeSelected: (value) => setState(() => selectedPartType = value),
      onImageOptionSelected: (value) =>
          setState(() => selectedImageOption = value),
      onContinue: _searchParts,
      isSearching: _isSearching,
    );
  }

  Widget _buildSearchResults() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Available Parts',
            style: TextStyle(
              fontFamily: GoogleFonts.montserrat().fontFamily,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          StreamBuilder<QuerySnapshot>(
            stream: _buildPartsQuery(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(child: Text('Something went wrong'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Text(
                    'No parts found. Try adjusting your search.',
                    style: TextStyle(
                      fontFamily: GoogleFonts.inter().fontFamily,
                      color: Colors.grey[600],
                    ),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final doc = snapshot.data!.docs[index];
                  final data = doc.data() as Map<String, dynamic>;

                  return _buildPartTile(data);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPartTile(Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child:
              data['imageUrl'] != null && data['imageUrl'].toString().isNotEmpty
                  ? Image.network(
                      data['imageUrl'],
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[200],
                        child: const Icon(Icons.build),
                      ),
                    )
                  : Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey[200],
                      child: const Icon(Icons.build),
                    ),
        ),
        title: Text(
          data['name'] ?? 'Unknown Part',
          style: TextStyle(
            fontFamily: GoogleFonts.montserrat().fontFamily,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Price: PKR ${data['price']?.toString() ?? 'N/A'}',
              style: TextStyle(
                fontFamily: GoogleFonts.inter().fontFamily,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Condition: ${data['condition']?.toString() ?? 'N/A'}',
              style: TextStyle(
                fontFamily: GoogleFonts.inter().fontFamily,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        onTap: () => _showPartDetails(data),
      ),
    );
  }

  Stream<QuerySnapshot> _buildPartsQuery() {
    Query query = FirebaseFirestore.instance.collection('car_parts');

    if (selectedMake != null) {
      query = query.where('make', isEqualTo: selectedMake!.toLowerCase());

      if (selectedModel != null) {
        query = query.where('model', isEqualTo: selectedModel!.toLowerCase());

        if (selectedPartType != null) {
          query = query.where('partType',
              isEqualTo: selectedPartType!.toLowerCase());
        }
      }
    }

    return query.limit(20).snapshots();
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
            _detailRow(
                'Price', 'PKR ${partData['price']?.toString() ?? 'N/A'}'),
            _detailRow(
                'Make', (partData['make'] ?? 'N/A').toString().toUpperCase()),
            _detailRow(
                'Model', (partData['model'] ?? 'N/A').toString().toUpperCase()),
            _detailRow('Part Type', partData['partType'] ?? 'N/A'),
            _detailRow('Condition', partData['condition'] ?? 'N/A'),
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

  Widget _detailRow(String label, String value) {
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
