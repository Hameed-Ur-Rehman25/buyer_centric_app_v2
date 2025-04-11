import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:buyer_centric_app_v2/theme/colors.dart';
import 'package:google_fonts/google_fonts.dart';

class AvailablePartsList extends StatelessWidget {
  final Stream<QuerySnapshot> query;
  final Function(Map<String, dynamic>) onTapPart;
  final String itemType; // Added itemType to handle different display styles

  const AvailablePartsList({
    super.key,
    required this.query,
    required this.onTapPart,
    this.itemType = 'all',
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: query,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(
                color: AppColor.buttonGreen,
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'Error loading items: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        final data = snapshot.data;
        if (data == null || data.docs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Icon(
                    itemType == 'car' ? Icons.directions_car : Icons.build,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    itemType == 'car'
                        ? 'No cars found matching your criteria'
                        : 'No parts found matching your criteria',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: data.docs.length,
            itemBuilder: (context, index) {
              final doc = data.docs[index];
              final item = doc.data() as Map<String, dynamic>;
              
              // Determine if this is a car or part
              final isCar = doc.reference.path.contains('inventoryCars');
              
              return _buildItemCard(context, item, isCar);
            },
          ),
        );
      },
    );
  }

  Widget _buildItemCard(BuildContext context, Map<String, dynamic> item, bool isCar) {
    // Get image URL with fallback logic
    final String imageUrl = _getImageUrl(item);
    
    // Get item name based on type
    final String name = isCar 
        ? item['make'] != null && item['model'] != null
            ? '${_capitalize(item['make'])} ${_capitalize(item['model'])}'
            : 'Car' 
        : item['name'] ?? 'Part';
    
    // Get price or range
    final String price = isCar
        ? item['price'] != null
            ? '\$${item['price']}'
            : 'Price on request'
        : item['price'] != null
            ? '\$${item['price']}'
            : 'Price on request';

    return GestureDetector(
      onTap: () => onTapPart(item),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item image (car or part)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 120,
                          width: double.infinity,
                          color: Colors.grey[200],
                          child: Icon(
                            isCar ? Icons.directions_car : Icons.build,
                            size: 40,
                            color: Colors.grey[400],
                          ),
                        );
                      },
                    )
                  : Container(
                      height: 120,
                      width: double.infinity,
                      color: Colors.grey[200],
                      child: Icon(
                        isCar ? Icons.directions_car : Icons.build,
                        size: 40,
                        color: Colors.grey[400],
                      ),
                    ),
            ),
            
            // Item details
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Item type badge (car or part)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isCar ? Colors.blue[100] : Colors.green[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isCar ? 'Car' : 'Part',
                      style: TextStyle(
                        fontSize: 10,
                        color: isCar ? Colors.blue[800] : Colors.green[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  
                  // Item name
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  // Item details
                  if (isCar && item['year'] != null)
                    Text(
                      'Year: ${item['year']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (!isCar && item['partType'] != null)
                    Text(
                      _capitalize(item['partType']),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  
                  // Price
                  const SizedBox(height: 4),
                  Text(
                    price,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColor.buttonGreen,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to get image URL with fallbacks
  String _getImageUrl(Map<String, dynamic> item) {
    // Check for mainImageUrl first
    if (item['mainImageUrl'] != null && item['mainImageUrl'].toString().isNotEmpty) {
      return item['mainImageUrl'];
    }
    
    // Then check for imageUrl
    if (item['imageUrl'] != null && item['imageUrl'].toString().isNotEmpty) {
      return item['imageUrl'];
    }
    
    // Then check for imageUrls array
    if (item['imageUrls'] is List && (item['imageUrls'] as List).isNotEmpty) {
      return (item['imageUrls'] as List).first.toString();
    }
    
    // Default empty string if no image found
    return '';
  }
  
  // Helper method to capitalize first letter
  String _capitalize(String? text) {
    if (text == null || text.isEmpty) return '';
    return text[0].toUpperCase() + text.substring(1);
  }
}
