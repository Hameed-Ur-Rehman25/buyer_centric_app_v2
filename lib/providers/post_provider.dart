import 'package:buyer_centric_app_v2/models/car_post_model.dart';
import 'package:buyer_centric_app_v2/services/car_post_service.dart';
import 'package:flutter/foundation.dart';

class PostProvider extends ChangeNotifier {
  final List<CarPost> _posts = [];
  bool _isLoading = false;
  final _carPostService = CarPostService();

  List<CarPost> get posts => _posts;
  bool get isLoading => _isLoading;

  Future<void> createPost(CarPost post) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _carPostService.createPost(post);
      _posts.insert(0, post);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> placeBid(String postId, Bid bid) async {
    try {
      await _carPostService.placeBid(postId, bid);

      // Update the local post with the new bid
      final postIndex = _posts.indexWhere((post) => post.id == postId);
      if (postIndex != -1) {
        _posts[postIndex].bids.add(bid);
        notifyListeners();
      }
    } catch (e) {
      throw Exception('Failed to place bid: $e');
    }
  }

  void listenToPosts() {
    CarPostService.getPostsStream().listen((snapshot) {
      _posts.clear();
      for (var doc in snapshot.docs) {
        // Convert document to CarPost object
        _posts.add(CarPost.fromMap(doc.data() as Map<String, dynamic>));
      }
      notifyListeners();
    });
  }

  Future<void> findMatchingPosts(Map<String, dynamic> buyerRequest) async {
    _isLoading = true;
    notifyListeners();

    try {
      final matchedPosts = await _carPostService.findMatchingPosts(buyerRequest);
      _posts.clear();
      _posts.addAll(matchedPosts);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
