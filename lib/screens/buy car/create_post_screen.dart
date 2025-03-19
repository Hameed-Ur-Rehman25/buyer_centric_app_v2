import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/car_post_model.dart';
import '../../providers/post_provider.dart';
import '../../widgets/post_card.dart';

class CreatePostScreen extends StatefulWidget {
  final Map<String, dynamic> buyerRequest;

  const CreatePostScreen({super.key, required this.buyerRequest});

  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  bool isLoading = true;
  List<CarPost> matchedPosts = [];

  @override
  void initState() {
    super.initState();
    _fetchMatchedPosts();
  }

  Future<void> _fetchMatchedPosts() async {
    try {
      final postProvider = Provider.of<PostProvider>(context, listen: false);
      await postProvider.findMatchingPosts(widget.buyerRequest);
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error finding matches: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
      ),
      body: Consumer<PostProvider>(
        builder: (context, postProvider, child) {
          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final posts = postProvider.posts;
          
          if (posts.isEmpty) {
            return const Center(
              child: Text('No matching posts found'),
            );
          }

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return PostCard(
                carName: post.carModel,
                lowRange: post.minPrice.toInt(),
                highRange: post.maxPrice.toInt(),
                image: post.carImageUrl,
                description: post.description,
                index: index,
                onTap: () => Navigator.pushNamed(
                  context,
                  '/car-details',
                  arguments: post,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
