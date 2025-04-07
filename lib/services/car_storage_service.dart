import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart' as path;

class CarStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Upload a single car image to Firebase Storage in inventory folder
  Future<String> uploadCarImage(File imageFile) async {
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

  // Upload multiple car images to Firebase Storage
  Future<List<String>> uploadMultipleCarImages(List<File> imageFiles) async {
    try {
      List<String> imageUrls = [];

      for (File imageFile in imageFiles) {
        String imageUrl = await uploadCarImage(imageFile);
        imageUrls.add(imageUrl);
      }

      return imageUrls;
    } catch (e) {
      throw Exception('Failed to upload multiple images: $e');
    }
  }

  // Store car details in Firestore
  Future<void> addCarToDatabase({
    required String make,
    required String model,
    required String description,
    required double price,
    required List<String> imageUrls,
    String? variant,
    int? year,
  }) async {
    try {
      final String? userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      await _firestore.collection('inventoryCars').add({
        'userId': userId,
        'make': make,
        'model': model,
        'description': description,
        'price': price,
        'imageUrls': imageUrls,
        'mainImageUrl': imageUrls.isNotEmpty ? imageUrls[0] : '',
        'variant': variant,
        'year': year,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to add car details: $e');
    }
  }

  // Complete car addition process with multiple images
  Future<void> addCompleteCar({
    required List<File> imageFiles,
    required String make,
    required String model,
    required String description,
    required double price,
    String? variant,
    int? year,
  }) async {
    try {
      if (imageFiles.isEmpty) {
        throw Exception('At least one image is required');
      }

      // First upload all images
      final List<String> imageUrls = await uploadMultipleCarImages(imageFiles);

      // Then store all car details including the image URLs
      await addCarToDatabase(
        make: make,
        model: model,
        description: description,
        price: price,
        imageUrls: imageUrls,
        variant: variant,
        year: year,
      );
    } catch (e) {
      throw Exception('Failed to complete car addition: $e');
    }
  }

  // For backward compatibility (can be removed later)
  Future<void> addCompleteCarSingleImage({
    required File imageFile,
    required String make,
    required String model,
    required String description,
    required double price,
    String? variant,
    int? year,
  }) async {
    try {
      // First upload the image
      final String imageUrl = await uploadCarImage(imageFile);

      // Then store all car details including the image URL
      await addCarToDatabase(
        make: make,
        model: model,
        description: description,
        price: price,
        imageUrls: [imageUrl],
        variant: variant,
        year: year,
      );
    } catch (e) {
      throw Exception('Failed to complete car addition: $e');
    }
  }

  // Delete a car from the inventory
  Future<void> deleteCar(String carId) async {
    try {
      final String? userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Get the car document to retrieve image URLs
      final DocumentSnapshot carDoc =
          await _firestore.collection('inventoryCars').doc(carId).get();

      if (!carDoc.exists) {
        throw Exception('Car not found');
      }

      final carData = carDoc.data() as Map<String, dynamic>;

      // Check if the car belongs to the current user
      if (carData['userId'] != userId) {
        throw Exception('Not authorized to delete this car');
      }

      // Delete images from Firebase Storage
      final List<dynamic> imageUrls = carData['imageUrls'] ?? [];

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

      // Delete car document from Firestore
      await _firestore.collection('inventoryCars').doc(carId).delete();
    } catch (e) {
      throw Exception('Failed to delete car: $e');
    }
  }
}
