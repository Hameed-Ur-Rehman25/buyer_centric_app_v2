// import 'dart:io';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:path/path.dart' as path;

// class CarStorageService {
//   final FirebaseStorage _storage = FirebaseStorage.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   // Upload car image to Firebase Storage
//   Future<String> uploadCarImage(File imageFile) async {
//     try {
//       final String fileName = 'car_images/${DateTime.now().millisecondsSinceEpoch}_${path.basename(imageFile.path)}';
//       final Reference storageRef = _storage.ref().child(fileName);
      
//       final UploadTask uploadTask = storageRef.putFile(imageFile);
//       final TaskSnapshot snapshot = await uploadTask;
      
//       return await snapshot.ref.getDownloadURL();
//     } catch (e) {
//       throw Exception('Failed to upload image: $e');
//     }
//   }

//   // Store car details in Firestore
//   Future<void> addCarToDatabase({
//     required String make,
//     required String model,
//     required String description,
//     required double price,
//     required String imageUrl,
//     String? variant,
//     int? year,
//   }) async {
//     try {
//       final String? userId = _auth.currentUser?.uid;
//       if (userId == null) throw Exception('User not authenticated');

//       await _firestore.collection('cars').add({
//         'userId': userId,
//         'make': make,
//         'model': model,
//         'description': description,
//         'price': price,
//         'imageUrl': imageUrl,
//         'variant': variant,
//         'year': year,
//         'createdAt': FieldValue.serverTimestamp(),
//         'status': 'active',
//       });
//     } catch (e) {
//       throw Exception('Failed to add car details: $e');
//     }
//   }

//   // Complete car addition process
//   Future<void> addCompleteCar({
//     required File imageFile,
//     required String make,
//     required String model,
//     required String description,
//     required double price,
//     String? variant,
//     int? year,
//   }) async {
//     try {
//       // First upload the image
//       final String imageUrl = await uploadCarImage(imageFile);
      
//       // Then store all car details including the image URL
//       await addCarToDatabase(
//         make: make,
//         model: model,
//         description: description,
//         price: price,
//         imageUrl: imageUrl,
//         variant: variant,
//         year: year,
//       );
//     } catch (e) {
//       throw Exception('Failed to complete car addition: $e');
//     }
//   }
// } 