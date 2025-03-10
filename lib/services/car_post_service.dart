import 'package:cloud_firestore/cloud_firestore.dart';

class CarPostService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //* Method to create a post
  static Future<void> createPost(Map<String, dynamic> postData) async {
    try {
      await _firestore.collection('posts').add(postData);
    } catch (e) {
      throw Exception('Creating post failed: $e');
    }
  }

  //* Method to fetch all posts
  static Stream<QuerySnapshot> getPostsStream() {
    try {
      return _firestore
          .collection('posts')
          .orderBy('timestamp', descending: true)
          .snapshots();
    } catch (e) {
      throw Exception('Fetching posts failed: $e');
    }
  }

  //* Method to fetch user-specific posts
  static Stream<QuerySnapshot> getUserPostsStream(String userId) {
    try {
      return _firestore
          .collection('posts')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .snapshots();
    } catch (e) {
      throw Exception('Fetching user posts failed: $e');
    }
  }

  //* Method to delete a post
  static Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).delete();
    } catch (e) {
      throw Exception('Deleting post failed: $e');
    }
  }

  //* Method to update a post
  static Future<void> updatePost(
      String postId, Map<String, dynamic> updatedData) async {
    try {
      await _firestore.collection('posts').doc(postId).update(updatedData);
    } catch (e) {
      throw Exception('Updating post failed: $e');
    }
  }
}
