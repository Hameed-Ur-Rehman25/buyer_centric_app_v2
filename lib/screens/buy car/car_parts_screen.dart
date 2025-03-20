import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:buyer_centric_app_v2/theme/colors.dart';
import 'package:buyer_centric_app_v2/widgets/custom_app_bar.dart';
import 'package:buyer_centric_app_v2/utils/bottom_nav_bar.dart';
import 'package:buyer_centric_app_v2/models/car_part_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:buyer_centric_app_v2/screens/buy car/create_car_part_screen.dart';

class CarPartsScreen extends StatefulWidget {
  const CarPartsScreen({super.key});

  @override
  State<CarPartsScreen> createState() => _CarPartsScreenState();
}

class _CarPartsScreenState extends State<CarPartsScreen> {
  String? selectedMake;
  String? selectedModel;
  String? selectedPartType;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

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

  Future<void> _searchParts() async {
    if (selectedMake == null ||
        selectedModel == null ||
        selectedPartType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select all required fields')),
      );
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('car_parts')
          .where('make', isEqualTo: selectedMake!.toLowerCase())
          .where('model', isEqualTo: selectedModel!.toLowerCase())
          .where('partType', isEqualTo: selectedPartType!.toLowerCase())
          .get();

      if (mounted) {
        if (querySnapshot.docs.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('No parts found for the selected criteria')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error searching parts: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: const CustomAppBar(showSearchBar: false),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Text search bar with button
            Padding(
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
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateCarPartScreen(
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
            ),

            // Filter container
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(15),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                  _buildDropdown(
                    'Part Type',
                    _partTypes,
                    selectedPartType,
                    (value) => setState(() => selectedPartType = value),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSearching ? null : _searchParts,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.buttonGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isSearching
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Search Parts',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),

            // Display search results here
            Padding(
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
                        return const Center(
                          child: Text('Something went wrong'),
                        );
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
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
                                child: data['imageUrl'] != null &&
                                        data['imageUrl'].toString().isNotEmpty
                                    ? Image.network(
                                        data['imageUrl'],
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Container(
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
                                  fontFamily:
                                      GoogleFonts.montserrat().fontFamily,
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
                                      fontFamily:
                                          GoogleFonts.inter().fontFamily,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Condition: ${data['condition']?.toString() ?? 'N/A'}',
                                    style: TextStyle(
                                      fontFamily:
                                          GoogleFonts.inter().fontFamily,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () {
                                // Navigate to part details screen or show a dialog with more info
                                _showPartDetails(data);
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper to build the query for StreamBuilder
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

  // Show part details in a modal bottom sheet
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
                onPressed: () {
                  // Implement contact seller or purchase logic
                  Navigator.pop(context);
                },
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

  // Helper for part details modal
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
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
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
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
