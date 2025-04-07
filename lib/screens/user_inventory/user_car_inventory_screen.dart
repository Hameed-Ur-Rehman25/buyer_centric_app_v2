import 'package:buyer_centric_app_v2/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:buyer_centric_app_v2/theme/colors.dart';
import 'package:buyer_centric_app_v2/utils/screen_size.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:buyer_centric_app_v2/widgets/custom_text_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:buyer_centric_app_v2/services/car_storage_service.dart';

class UserCarInventoryScreen extends StatefulWidget {
  const UserCarInventoryScreen({super.key});

  @override
  State<UserCarInventoryScreen> createState() => _UserCarInventoryScreenState();
}

class _UserCarInventoryScreenState extends State<UserCarInventoryScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CarStorageService _carStorageService = CarStorageService();

  bool _isLoading = true;
  bool _isDeletingCar = false;
  String? _errorMessage;
  List<Map<String, dynamic>> _userCars = [];

  @override
  void initState() {
    super.initState();
    _fetchUserCars();
  }

  Future<void> _fetchUserCars() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final String? userId = _auth.currentUser?.uid;
      if (userId == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'User not authenticated';
        });
        return;
      }

      // Option 1: Remove ordering to avoid needing composite index
      final QuerySnapshot snapshot = await _firestore
          .collection('inventoryCars')
          .where('userId', isEqualTo: userId)
          .get();

      final List<Map<String, dynamic>> cars = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();

      // Sort the cars in memory instead of in the query
      cars.sort((a, b) {
        final aTimestamp = a['createdAt'] as Timestamp?;
        final bTimestamp = b['createdAt'] as Timestamp?;

        if (aTimestamp == null && bTimestamp == null) return 0;
        if (aTimestamp == null) return 1;
        if (bTimestamp == null) return -1;

        // Sort in descending order (newest first)
        return bTimestamp.compareTo(aTimestamp);
      });

      setState(() {
        _userCars = cars;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load inventory: ${e.toString()}';
      });
    }
  }

  Future<void> _deleteCar(String carId, String carName) async {
    // Show confirmation dialog
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Car'),
        content: Text(
            'Are you sure you want to delete "$carName"?\n\nThis action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (confirmDelete != true) return;

    // User confirmed deletion
    setState(() => _isDeletingCar = true);

    try {
      await _carStorageService.deleteCar(carId);

      // Remove the car from the list
      setState(() {
        _userCars.removeWhere((car) => car['id'] == carId);
        _isDeletingCar = false;
      });

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Car deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isDeletingCar = false);

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete car: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
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
        child: Padding(
          padding: EdgeInsets.only(
            left: screenWidth * 0.04,
            right: screenWidth * 0.04,
            top: appBarHeight + 20,
          ),
          child: Column(
            children: [
              // Car Inventory Content
              Expanded(
                child: _buildInventoryContent(),
              ),
            ],
          ),
        ),
      ),
      // Main Floating Action Button for adding a car
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Refresh button (smaller)
          FloatingActionButton.small(
            heroTag: 'refreshBtn',
            onPressed: _fetchUserCars,
            backgroundColor: Colors.white,
            foregroundColor: AppColor.buttonGreen,
            tooltip: 'Refresh',
            elevation: 4,
            child: const Icon(Icons.refresh),
          ),
          const SizedBox(height: 16),
          // Add Car button (primary)
          FloatingActionButton.extended(
            heroTag: 'addCarBtn',
            onPressed: () async {
              await Navigator.pushNamed(context, AppRoutes.addCar);
              // Refresh the list when returning from the add car screen
              _fetchUserCars();
            },
            backgroundColor: AppColor.buttonGreen,
            foregroundColor: Colors.white,
            elevation: 6,
            icon: const Icon(Icons.add_circle_outline),
            label: const Text(
              'Add Car',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildInventoryContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'Error occurred',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchUserCars,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.buttonGreen,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (_userCars.isEmpty) {
      return _buildEmptyInventory(context);
    }

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _fetchUserCars,
          color: AppColor.buttonGreen,
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 80), // Add padding for FAB
            itemCount: _userCars.length,
            itemBuilder: (context, index) {
              final car = _userCars[index];
              return _buildCarCard(car);
            },
          ),
        ),

        // Loading overlay for car deletion
        if (_isDeletingCar)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }

  Widget _buildCarCard(Map<String, dynamic> car) {
    final String id = car['id'] ?? '';
    final make = car['make'] ?? 'Unknown';
    final model = car['model'] ?? 'Model';
    final price = car['price'] != null ? car['price'].toString() : 'N/A';
    final List<dynamic> imageUrls = car['imageUrls'] ?? [];
    final String mainImageUrl = car['mainImageUrl'] ?? '';
    final String carName = '$make $model';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: AppColor.grey.withOpacity(0.3), width: 1),
      ),
      elevation: 2,
      child: InkWell(
        onTap: () {
          // Navigate to car details or edit page
          // TODO: Implement navigation to detail/edit page
        },
        borderRadius: BorderRadius.circular(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Car Image with Badge
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
              child: Stack(
                children: [
                  Container(
                    height: 180,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: mainImageUrl.isNotEmpty
                        ? Image.network(
                            mainImageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(
                                  Icons.broken_image,
                                  color: Colors.grey,
                                  size: 50,
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                  color: AppColor.buttonGreen,
                                ),
                              );
                            },
                          )
                        : const Center(
                            child: Icon(
                              Icons.directions_car,
                              color: Colors.grey,
                              size: 50,
                            ),
                          ),
                  ),

                  // Image Count Badge
                  if (imageUrls.length > 1)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.photo_library,
                              color: Colors.white,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${imageUrls.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Car Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          carName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColor.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        'PKR $price',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColor.buttonGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 16,
                        color: AppColor.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          car['description'] ?? 'No description',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColor.black.withOpacity(0.6),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: AppColor.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            car['year']?.toString() ?? 'N/A',
                            style: TextStyle(
                              color: AppColor.grey.withOpacity(0.8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          OutlinedButton.icon(
                            onPressed: () {
                              // TODO: Add edit functionality
                            },
                            icon: const Icon(Icons.edit, size: 16),
                            label: const Text('Edit'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColor.buttonGreen,
                              side:
                                  const BorderSide(color: AppColor.buttonGreen),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 0),
                              minimumSize: const Size(0, 30),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: () => _deleteCar(id, carName),
                            icon: const Icon(Icons.delete_outline, size: 16),
                            label: const Text('Delete'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 0),
                              minimumSize: const Size(0, 30),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
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
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: CircleAvatar(
                        radius: profileIconSize / 2,
                        backgroundColor: Colors.black.withOpacity(0.2),
                        child: Icon(
                          Icons.arrow_back,
                          color: Colors.black,
                          size: profileIconSize * 0.6,
                        ),
                      ),
                    ),
                    // Title
                    Text(
                      'Your Inventory',
                      style: TextStyle(
                        color: Colors.white,
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

  Widget _buildEmptyInventory(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_car_outlined,
            size: 80,
            color: AppColor.grey.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Your car inventory will appear here',
            style: TextStyle(
              color: Colors.black.withOpacity(0.6),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first car to get started',
            style: TextStyle(
              color: Colors.black.withOpacity(0.4),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          // Visual hint to use the FAB
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.arrow_downward,
                color: AppColor.buttonGreen,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Tap the "Add Car" button below',
                style: TextStyle(
                  color: AppColor.buttonGreen,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
