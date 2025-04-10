/*
 * ! IMPORTANT: Main screen for car buying functionality
 * 
 * * Key Features:
 * * - Car listing display
 * * - Search functionality
 * * - Filter options
 * 
 */
import 'package:buyer_centric_app_v2/routes/app_routes.dart';
import 'package:buyer_centric_app_v2/utils/car_search_card.dart';
import 'package:buyer_centric_app_v2/widgets/post_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:buyer_centric_app_v2/providers/post_provider.dart';

class BuyCarScreen extends StatelessWidget {
  const BuyCarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PostProvider>(
      builder: (context, postProvider, child) {
        return InkWell(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                  child: CarSearchCard(),
                ),
                //* Display car posts
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: postProvider.posts.length,
                  itemBuilder: (context, index) {
                    final post = postProvider.posts[index];
                    return PostCard(
                      carName: post.carModel,
                      lowRange: post.minPrice.toInt(),
                      highRange: post.maxPrice.toInt(),
                      image: post.carImageUrl,
                      description: post.description,
                      index: index.toString(),
                      animationIndex: index,
                      imageUrls: post.imageUrls,
                      category: post.category ?? 'car',
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.carDetails,
                        arguments: {
                          'image': post.carImageUrl,
                          'carName': post.carModel,
                          'lowRange': post.minPrice.toInt(),
                          'highRange': post.maxPrice.toInt(),
                          'description': post.description,
                          'index': post.id,
                          'userId': post.buyerId,
                          'imageUrls': post.imageUrls.isNotEmpty 
                              ? List<String>.from(post.imageUrls
                                 .map((url) => url)
                                 .where((url) => url.isNotEmpty == true))
                              : null,
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
