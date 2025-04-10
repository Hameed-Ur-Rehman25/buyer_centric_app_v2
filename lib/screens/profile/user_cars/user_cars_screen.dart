import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:buyer_centric_app_v2/services/auth_service.dart';
import 'package:buyer_centric_app_v2/theme/colors.dart';
import 'package:buyer_centric_app_v2/widgets/post_card.dart';
import 'package:buyer_centric_app_v2/routes/app_routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class UserCarsScreen extends StatefulWidget {
  const UserCarsScreen({super.key});

  @override
  State<UserCarsScreen> createState() => _UserCarsScreenState();
}

class _UserCarsScreenState extends State<UserCarsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: AppBar(
        title: Text(
          'My Cars',
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
              child: Text('Please log in to view your cars'),
            );
          }

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('posts')
                .where('userId', isEqualTo: currentUser.uid)
                .where('category', isEqualTo: 'car')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                debugPrint('Error in car posts query: ${snapshot.error}');
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
                        'Error loading car posts',
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
                              builder: (context) => const UserCarsScreen(),
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

              final carPosts = snapshot.data?.docs ?? [];

              if (carPosts.isEmpty) {
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
                      const Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: Text(
                          'Your Car Posts',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColor.black,
                          ),
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: carPosts.length,
                        itemBuilder: (context, index) {
                          final doc = carPosts[index];
                          final data = doc.data() as Map<String, dynamic>;

                          return PostCard(
                            index: index.toString(),
                            animationIndex: index,
                            carName:
                                "${data['make'] ?? ''} ${data['model'] ?? ''}",
                            lowRange: (data['minPrice'] as num?)?.toInt() ?? 0,
                            highRange: (data['maxPrice'] as num?)?.toInt() ?? 0,
                            image: data['imageUrl'] ?? 'assets/images/car1.png',
                            description: data['description']?.isNotEmpty == true
                                ? data['description']
                                : 'No description',
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes.carDetails,
                              arguments: {
                                'image': data['imageUrl'] ?? 'assets/images/car1.png',
                                'carName': "${data['make'] ?? ''} ${data['model'] ?? ''}",
                                'lowRange': (data['minPrice'] as num?)?.toInt() ?? 0,
                                'highRange': (data['maxPrice'] as num?)?.toInt() ?? 0,
                                'description': data['description'] ?? 'No description',
                                'index': doc.id,
                                'userId': data['userId'] ?? '',
                                'imageUrls': data['imageUrls'] is List
                                    ? List<String>.from(
                                        (data['imageUrls'] as List)
                                            .map((url) => url?.toString() ?? '')
                                            .where((url) => url.isNotEmpty == true)
                                      )
                                    : null,
                              },
                            ),
                            onDelete: () => _showDeleteDialog(context, doc.id),
                            userId: data['userId'],
                            imageUrls: data['imageUrls'] is List
                                ? List<String>.from(
                                    (data['imageUrls'] as List)
                                        .map((url) => url?.toString() ?? '')
                                        .where((url) => url.isNotEmpty == true)
                                  )
                                : null,
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
            Icons.directions_car_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'You haven\'t created any car posts yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.createPost,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.buttonGreen,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Create Your First Post',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
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
