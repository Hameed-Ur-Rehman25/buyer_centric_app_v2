import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:buyer_centric_app_v2/services/auth_service.dart';
import 'package:buyer_centric_app_v2/theme/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:buyer_centric_app_v2/routes/app_routes.dart';
import 'package:buyer_centric_app_v2/widgets/post_card.dart';

class UserCarPartsScreen extends StatefulWidget {
  const UserCarPartsScreen({super.key});

  @override
  State<UserCarPartsScreen> createState() => _UserCarPartsScreenState();
}

class _UserCarPartsScreenState extends State<UserCarPartsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: AppBar(
        title: Text(
          'My Car Parts Posts',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColor.appBarColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<AuthService>(
        builder: (context, authService, child) {
          final currentUser = authService.currentUser;
          if (currentUser == null) {
            return const Center(
              child: Text('Please log in to view your car parts'),
            );
          }

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('posts')
                .where('userId', isEqualTo: currentUser.uid)
                .where('category', isEqualTo: 'car_part')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                debugPrint('Error in car parts query: ${snapshot.error}');
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 60,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading car parts',
                        style: GoogleFonts.poppins(
                          color: Colors.red,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please try again later',
                        style: GoogleFonts.poppins(color: Colors.grey),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const UserCarPartsScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.buttonGreen,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Refresh'),
                      ),
                    ],
                  ),
                );
              }

              final carParts = snapshot.data?.docs ?? [];

              if (carParts.isEmpty) {
                return _buildEmptyState(context);
              }

              return RefreshIndicator(
                onRefresh: () async {
                  // This is a no-op because StreamBuilder already refreshes
                  // when the stream emits a new value
                },
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // const Padding(
                      //   padding: EdgeInsets.only(bottom: 16),
                      //   child: Text(
                      //     'Your Car Parts Posts',
                      //     style: TextStyle(
                      //       fontSize: 20,
                      //       fontWeight: FontWeight.bold,
                      //       color: AppColor.black,
                      //     ),
                      //   ),
                      // ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: carParts.length,
                        itemBuilder: (context, index) {
                          final doc = carParts[index];
                          final data = doc.data() as Map<String, dynamic>;

                          // Get image URLs - start with mainImageUrl, then fallback to imageUrl
                          String imageUrl = data['mainImageUrl'] ?? '';
                          if (imageUrl.isEmpty) {
                            imageUrl = data['imageUrl'] ?? '';
                          }

                          // Get all image URLs for carousel if available
                          List<String> imageUrls = [];
                          if (data['imageUrls'] != null &&
                              data['imageUrls'] is List) {
                            imageUrls = List<String>.from(
                                (data['imageUrls'] as List)
                                    .map((url) => url?.toString() ?? '')
                                    .where((url) => url.isNotEmpty));
                          }

                          // If we don't have a main image but have imageUrls, use the first one
                          if (imageUrl.isEmpty && imageUrls.isNotEmpty) {
                            imageUrl = imageUrls.first;
                          }

                          // Final fallback to placeholder
                          if (imageUrl.isEmpty) {
                            imageUrl = 'assets/images/car_part_placeholder.png';
                          }

                          // Get price range
                          final int minPrice =
                              (data['minPrice'] as num?)?.toInt() ?? 0;
                          final int maxPrice =
                              (data['maxPrice'] as num?)?.toInt() ?? 0;

                          return PostCard(
                            carName: "${data['name'] ?? ''} ${data['partType'] ?? ''}",
                            lowRange: minPrice,
                            highRange: maxPrice,
                            image: imageUrl,
                            description: data['description'] ?? 'No description',
                            index: doc.id,
                            animationIndex: index,
                            userId: currentUser.uid,
                            isBuyer: true,
                            imageUrls: imageUrls,
                            category: data['category'] ?? 'car_part',
                            onTap: () {
                              // Navigate to car part details
                              // Navigator.pushNamed(
                              //   context,
                              //   AppRoutes.carPartDetails,
                              //   arguments: {
                              //     ...data,
                              //     'id': doc.id,
                              //   },
                              // );
                            },
                            onDelete: () => _showDeleteDialog(context, doc.id),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.build_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'You haven\'t posted any car parts yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          //!Commented out button for creating a new post
          // const SizedBox(height: 24),
          // ElevatedButton(
          //   onPressed: () {
          //     Navigator.pushNamed(
          //       context,
          //       AppRoutes.createPost,
          //     );
          //   },
          //   style: ElevatedButton.styleFrom(
          //     backgroundColor: AppColor.buttonGreen,
          //     padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(8),
          //     ),
          //   ),
          //   child: const Text(
          //     'Create Your First Post',
          //     style: TextStyle(
          //       color: Colors.white,
          //       fontSize: 16,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  // * Shows delete confirmation dialog
  Future<void> _showDeleteDialog(BuildContext context, String postId) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await FirebaseFirestore.instance
                    .collection('posts')
                    .doc(postId)
                    .delete();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Post deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error deleting post: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
