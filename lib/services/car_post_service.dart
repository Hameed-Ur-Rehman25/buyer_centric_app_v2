import 'package:buyer_centric_app_v2/models/car_post_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class CarPostService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // Create a new post
  Future<String> createPost(CarPost post) async {
    try {
      final docRef = await _firestore.collection('posts').add(post.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create post: $e');
    }
  }

  // Get all posts
  Stream<List<CarPost>> getPosts() {
    return _firestore
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => CarPost.fromMap(doc.data())).toList());
  }

  // Upload car image
  Future<String> uploadCarImage(String filePath) async {
    try {
      final file = File(filePath);
      final ref = _storage.ref().child('car_images/${DateTime.now()}.jpg');
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  // Place bid on a post
  Future<void> placeBid(String postId, Bid bid) async {
    try {
      await _firestore.collection('posts').doc(postId).update({
        'bids': FieldValue.arrayUnion([bid.toMap()])
      });
    } catch (e) {
      throw Exception('Failed to place bid: $e');
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

  // Get bids for a specific post
  static Stream<DocumentSnapshot> getBidsStream(String postId) {
    try {
      return _firestore.collection('posts').doc(postId).snapshots();
    } catch (e) {
      throw Exception('Fetching bids failed: $e');
    }
  }

  // Find matching cars based on buyer request
  Future<List<CarPost>> findMatchingPosts(
      Map<String, dynamic> buyerRequest) async {
    try {
      Query query = _firestore.collection('posts');

      if (buyerRequest['carModel'] != null) {
        query = query.where('carModel', isEqualTo: buyerRequest['carModel']);
      }

      if (buyerRequest['minPrice'] != null &&
          buyerRequest['maxPrice'] != null) {
        query = query
            .where('minPrice', isGreaterThanOrEqualTo: buyerRequest['minPrice'])
            .where('maxPrice', isLessThanOrEqualTo: buyerRequest['maxPrice']);
      }

      final QuerySnapshot snapshot = await query.get();
      return snapshot.docs
          .map((doc) => CarPost.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to find matching posts: $e');
    }
  }
}
