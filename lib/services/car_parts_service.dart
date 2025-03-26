import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CarPartsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _collection = 'carParts';

  CollectionReference<Map<String, dynamic>> get _carPartsCollection =>
      _firestore.collection(_collection);

  // Helper method to build query with filters
  Query<Object?> _buildFilteredQuery({
    String? make,
    String? model,
    String? partType,
  }) {
    Query query = _carPartsCollection;

    if (make != null) {
      query = query.where('make', isEqualTo: make.toLowerCase());
    }
    if (model != null) {
      query = query.where('model', isEqualTo: model.toLowerCase());
    }
    if (partType != null) {
      query = query.where('partType', isEqualTo: partType.toLowerCase());
    }

    return query;
  }

  // Get stream of all car parts
  Stream<QuerySnapshot> getAllCarParts() {
    return _carPartsCollection.snapshots();
  }

  // Get filtered car parts
  Stream<QuerySnapshot> getFilteredCarParts({
    String? make,
    String? model,
    String? partType,
  }) {
    return _buildFilteredQuery(
      make: make,
      model: model,
      partType: partType,
    ).limit(20).snapshots();
  }

  // Search car parts
  Future<QuerySnapshot> searchCarParts({
    required String make,
    required String model,
    required String partType,
  }) {
    return _buildFilteredQuery(
      make: make,
      model: model,
      partType: partType,
    ).get();
  }

  // Create new car part
  Future<void> createCarPart(Map<String, dynamic> data) async {
    final String? userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    // Add additional metadata
    final Map<String, dynamic> partData = {
      ...data,
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await _carPartsCollection.add(partData);
  }

  // Get car part by ID
  Future<DocumentSnapshot> getCarPartById(String id) {
    return _carPartsCollection.doc(id).get();
  }

  // Update car part
  Future<void> updateCarPart(String id, Map<String, dynamic> data) async {
    final String? userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final doc = await _carPartsCollection.doc(id).get();
    if (!doc.exists) throw Exception('Part not found');
    if (doc.get('userId') != userId) {
      throw Exception('Not authorized to update this part');
    }

    await _carPartsCollection.doc(id).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Delete car part
  Future<void> deleteCarPart(String id) async {
    final String? userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final doc = await _carPartsCollection.doc(id).get();
    if (!doc.exists) throw Exception('Part not found');
    if (doc.get('userId') != userId) {
      throw Exception('Not authorized to delete this part');
    }

    await _carPartsCollection.doc(id).delete();
  }
}
