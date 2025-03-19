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
                // Display car posts
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
                      index: index,
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.carDetails,
                        arguments: post,
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
