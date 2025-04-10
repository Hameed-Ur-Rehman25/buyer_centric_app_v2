import 'package:buyer_centric_app_v2/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:buyer_centric_app_v2/theme/colors.dart';
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
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Warning Icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_rounded,
                  color: Colors.red[700],
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                'Delete Car',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                ),
              ),
              const SizedBox(height: 12),

              // Message
              Text(
                'Are you sure you want to delete "$carName"?',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'This action cannot be undone.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 24),

              // Buttons Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Cancel Button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Colors.grey[400]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'CANCEL',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Delete Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: Colors.red[700],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'DELETE',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
            top: screenHeight * 0.02,
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
    final screenSize = MediaQuery.of(context).size;

    // Use all available images for carousel, starting with mainImageUrl if available
    final List<String> carouselImages = [];
    if (mainImageUrl.isNotEmpty) {
      carouselImages.add(mainImageUrl);
    }

    // Add any additional images that aren't the main image
    for (var url in imageUrls) {
      if (url is String && url.isNotEmpty && url != mainImageUrl) {
        carouselImages.add(url);
      }
    }

    // If no images available, add a placeholder
    if (carouselImages.isEmpty) {
      carouselImages.add('');
    }

    // Page controller for image carousel
    final PageController pageController = PageController();

    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: screenSize.width * 0.04,
        vertical: 10,
      ),
      color: AppColor.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Car Image Carousel with overlapping counter
          Stack(
            children: [
              // Image carousel
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: SizedBox(
                  height: 170,
                  child: Stack(
                    children: [
                      // Carousel
                      PageView.builder(
                        controller: pageController,
                        itemCount: carouselImages.length,
                        itemBuilder: (context, index) {
                          final imageUrl = carouselImages[index];
                          return Center(
                            child: imageUrl.isNotEmpty
                                ? Image.network(
                                    imageUrl,
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: double.infinity,
                                        height: double.infinity,
                                        color: Colors.grey[200],
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.broken_image_rounded,
                                              size: 50,
                                              color: Colors.grey[400],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Image not available',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return SizedBox(
                                        width: double.infinity,
                                        height: double.infinity,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                                : null,
                                            color: AppColor.buttonGreen,
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                : Container(
                                    width: double.infinity,
                                    height: double.infinity,
                                    color: Colors.grey[200],
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.directions_car,
                                          size: 50,
                                          color: Colors.grey[400],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'No images available',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          );
                        },
                      ),

                      // Pagination dots for carousel
                      if (carouselImages.length > 1)
                        Positioned(
                          bottom: 8,
                          left: 0,
                          right: 0,
                          child: StatefulBuilder(
                            builder: (context, setState) {
                              pageController.addListener(() {
                                setState(() {});
                              });
                              final currentPage = pageController.hasClients
                                  ? pageController.page?.round() ?? 0
                                  : 0;

                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  carouselImages.length,
                                  (index) => Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 3),
                                    height: 8,
                                    width: 8,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: currentPage == index
                                          ? AppColor.buttonGreen
                                          : Colors.white.withOpacity(0.8),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Image counter indicator - overlapped on top right
              if (carouselImages.length > 1)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.photo_library,
                          color: AppColor.white,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        StatefulBuilder(
                          builder: (context, setState) {
                            pageController.addListener(() {
                              if (pageController.page?.round() != null) {
                                setState(() {});
                              }
                            });
                            final currentPage = pageController.hasClients
                                ? (pageController.page?.round() ?? 0) + 1
                                : 1;
                            return Text(
                              '$currentPage/${carouselImages.length}',
                              style: const TextStyle(
                                color: AppColor.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          // Car Details section - with white background
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Car name and price row
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColor.buttonGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'PKR $price',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColor.buttonGreen,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Car specifications in chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    // Year chip
                    if (car['year'] != null)
                      _buildInfoChip(
                        Icons.calendar_today,
                        '${car['year']}',
                      ),

                    // Mileage chip
                    if (car['mileage'] != null)
                      _buildInfoChip(
                        Icons.speed,
                        '${car['mileage']} km',
                      ),

                    // Condition chip
                    if (car['condition'] != null)
                      _buildInfoChip(
                        Icons.auto_awesome,
                        '${car['condition']}',
                      ),
                  ],
                ),

                const SizedBox(height: 5),

                // Description
                if (car['description'] != null &&
                    car['description'].toString().trim().isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColor.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        car['description'] ?? 'No description',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColor.black.withOpacity(0.7),
                          fontSize: 13,
                        ),
                      ),
                      if (car['description'].length > 90)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: GestureDetector(
                            onTap: () {
                              // TODO: Show full description
                            },
                            child: const Text(
                              'See more',
                              style: TextStyle(
                                color: AppColor.buttonGreen,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // OutlinedButton.icon(
                    //   onPressed: () {
                    //     // TODO: Add edit functionality
                    //   },
                    //   icon: const Icon(Icons.edit, size: 16),
                    //   label: const Text('Edit'),
                    //   style: OutlinedButton.styleFrom(
                    //     foregroundColor: AppColor.buttonGreen,
                    //     side: const BorderSide(color: AppColor.buttonGreen),
                    //     padding: const EdgeInsets.symmetric(
                    //         horizontal: 12, vertical: 0),
                    //     minimumSize: const Size(0, 34),
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(8),
                    //     ),
                    //   ),
                    // ),
                    const SizedBox(width: 10),
                    OutlinedButton.icon(
                      onPressed: () => _deleteCar(id, carName),
                      icon: const Icon(Icons.delete_outline, size: 16),
                      label: const Text('Delete'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 0),
                        minimumSize: const Size(0, 34),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build info chips
  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: AppColor.grey,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: AppColor.grey.withOpacity(0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: CircleAvatar(
                        radius: profileIconSize / 2,
                        backgroundColor: Colors.white.withOpacity(0.1),
                        child: Icon(
                          Icons.arrow_back,
                          color: Colors.white,
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
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.arrow_downward,
                color: AppColor.buttonGreen,
                size: 20,
              ),
              SizedBox(width: 8),
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
