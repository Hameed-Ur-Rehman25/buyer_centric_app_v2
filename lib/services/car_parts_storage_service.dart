import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart' as path;

class CarPartsStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Upload a single car part image to Firebase Storage in inventory folder
  Future<String> uploadCarPartImage(File imageFile) async {
    try {
      final String fileName =
          'inventory/${DateTime.now().millisecondsSinceEpoch}_${path.basename(imageFile.path)}';
      final Reference storageRef = _storage.ref().child(fileName);

      final UploadTask uploadTask = storageRef.putFile(imageFile);
      final TaskSnapshot snapshot = await uploadTask;

      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  // Upload multiple car part images to Firebase Storage
  Future<List<String>> uploadMultipleCarPartImages(List<File> imageFiles) async {
    try {
      List<String> imageUrls = [];

      for (File imageFile in imageFiles) {
        String imageUrl = await uploadCarPartImage(imageFile);
        imageUrls.add(imageUrl);
      }

      return imageUrls;
    } catch (e) {
      throw Exception('Failed to upload multiple images: $e');
    }
  }

  // Upload a single car part image to Firebase Storage in carParts folder
  Future<String> uploadCarPartPostImage(File imageFile) async {
    try {
      final String fileName =
          'carParts/${DateTime.now().millisecondsSinceEpoch}_${path.basename(imageFile.path)}';
      final Reference storageRef = _storage.ref().child(fileName);

      final UploadTask uploadTask = storageRef.putFile(imageFile);
      final TaskSnapshot snapshot = await uploadTask;

      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  // Store car part details in Firestore
  Future<void> addCarPartToDatabase({
    required String name,
    required String category,
    required String description,
    required double price,
    required List<String> imageUrls,
    String? brand,
    String? compatibility,
    String? condition,
    int? quantity,
  }) async {
    try {
      final String? userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      await _firestore.collection('inventoryCarParts').add({
        'userId': userId,
        'name': name,
        'category': category,
        'description': description,
        'price': price,
        'imageUrls': imageUrls,
        'mainImageUrl': imageUrls.isNotEmpty ? imageUrls[0] : '',
        'brand': brand,
        'compatibility': compatibility,
        'condition': condition,
        'quantity': quantity,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to add car part details: $e');
    }
  }

  // Complete car part addition process with multiple images
  Future<void> addCompleteCarPart({
    required List<File> imageFiles,
    required String name,
    required String category,
    required String description,
    required double price,
    String? brand,
    String? compatibility,
    String? condition,
    int? quantity,
  }) async {
    try {
      if (imageFiles.isEmpty) {
        throw Exception('At least one image is required');
      }

      // First upload all images
      final List<String> imageUrls = await uploadMultipleCarPartImages(imageFiles);

      // Then store all car part details including the image URLs
      await addCarPartToDatabase(
        name: name,
        category: category,
        description: description,
        price: price,
        imageUrls: imageUrls,
        brand: brand,
        compatibility: compatibility,
        condition: condition,
        quantity: quantity,
      );
    } catch (e) {
      throw Exception('Failed to complete car part addition: $e');
    }
  }

  // Delete a car part from the inventory
  Future<void> deleteCarPart(String partId) async {
    try {
      final String? userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Get the car part document to retrieve image URLs
      final DocumentSnapshot partDoc =
          await _firestore.collection('inventoryCarParts').doc(partId).get();

      if (!partDoc.exists) {
        throw Exception('Car part not found');
      }

      final partData = partDoc.data() as Map<String, dynamic>;

      // Check if the car part belongs to the current user
      if (partData['userId'] != userId) {
        throw Exception('Not authorized to delete this car part');
      }

      // Delete images from Firebase Storage
      final List<dynamic> imageUrls = partData['imageUrls'] ?? [];

      for (String imageUrl in List<String>.from(imageUrls)) {
        try {
          // Extract storage path from URL
          final ref = _storage.refFromURL(imageUrl);
          await ref.delete();
        } catch (e) {
          // Continue with other images if one fails
          print('Failed to delete image: $e');
        }
      }

      // Delete car part document from Firestore
      await _firestore.collection('inventoryCarParts').doc(partId).delete();
    } catch (e) {
      throw Exception('Failed to delete car part: $e');
    }
  }
} 