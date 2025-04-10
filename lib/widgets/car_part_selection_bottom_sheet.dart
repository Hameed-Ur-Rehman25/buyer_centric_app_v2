import 'package:buyer_centric_app_v2/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:buyer_centric_app_v2/theme/colors.dart';

class CarPartSelectionBottomSheet extends StatefulWidget {
  final Function(String partId, String partName) onPartSelected;

  const CarPartSelectionBottomSheet({
    super.key,
    required this.onPartSelected,
  });

  @override
  State<CarPartSelectionBottomSheet> createState() =>
      _CarPartSelectionBottomSheetState();
}

class _CarPartSelectionBottomSheetState
    extends State<CarPartSelectionBottomSheet> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _userParts = [];
  String? _selectedPartId;

  @override
  void initState() {
    super.initState();
    _fetchUserParts();
  }

  Future<void> _fetchUserParts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final String? userId = _auth.currentUser?.uid;
      if (userId == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'User not authenticated';
        });
        return;
      }

      final QuerySnapshot snapshot = await _firestore
          .collection('inventoryCarParts')
          .where('userId', isEqualTo: userId)
          .get();

      final List<Map<String, dynamic>> parts = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();

      // Sort parts by creation time (newest first)
      parts.sort((a, b) {
        final aTimestamp = a['createdAt'] as Timestamp?;
        final bTimestamp = b['createdAt'] as Timestamp?;

        if (aTimestamp == null && bTimestamp == null) return 0;
        if (aTimestamp == null) return 1;
        if (bTimestamp == null) return -1;

        return bTimestamp.compareTo(aTimestamp);
      });

      setState(() {
        _userParts = parts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load inventory: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 15,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _buildContent(controller),
              ),
              if (_userParts.isNotEmpty && !_isLoading && _errorMessage == null)
                _buildBottomButton(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      decoration: const BoxDecoration(
        color: AppColor.black,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.build,
            color: AppColor.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          const Text(
            'Select Your Car Part',
            style: TextStyle(
              color: AppColor.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close, color: AppColor.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ScrollController controller) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColor.black),
            SizedBox(height: 16),
            Text(
              'Loading your car parts...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColor.black,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchUserParts,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.black,
                foregroundColor: AppColor.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_userParts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.build_outlined,
                color: AppColor.black,
                size: 60,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No car parts in your inventory',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColor.black,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Add car parts to your inventory to place bids',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () async {
                // Navigate to add car part screen and wait for result
                final result =
                    await Navigator.pushNamed(context, AppRoutes.addParts);

                // If user added a part successfully, refresh the parts list
                if (result == true) {
                  _fetchUserParts();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.black,
                foregroundColor: AppColor.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.add),
              label: const Text(
                'Add a Car Part',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 12),
            child: Text(
              'Your Car Parts (${_userParts.length})',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: controller,
              itemCount: _userParts.length,
              padding: const EdgeInsets.only(bottom: 80),
              itemBuilder: (context, index) {
                final part = _userParts[index];
                final partId = part['id'];
                final partName = part['name'] != null
                    ? '${part['name']} ${part['condition'] ?? ''}'
                    : 'Part ${index + 1}';
                final partImage = part['imageUrl'] ?? '';
                final isSelected = _selectedPartId == partId;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Material(
                    color: isSelected
                        ? AppColor.black.withOpacity(0.05)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    elevation: isSelected ? 0 : 2,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedPartId =
                              _selectedPartId == partId ? null : partId;
                        });
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? AppColor.black
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            _buildPartImage(partImage),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    partName,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? AppColor.black
                                          : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 12,
                                    children: [
                                      if (part['type'] != null)
                                        _buildDetailChip(
                                            Icons.category_outlined,
                                            part['type']),
                                      if (part['compatibility'] != null)
                                        _buildDetailChip(Icons.car_repair,
                                            part['compatibility']),
                                      if (part['price'] != null)
                                        _buildDetailChip(Icons.attach_money,
                                            'PKR ${part['price']}'),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: AppColor.black,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              )
                            else
                              const Icon(
                                Icons.radio_button_unchecked,
                                size: 24,
                                color: Colors.grey,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildPartImage(String imageUrl) {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[200],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: imageUrl.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      color: AppColor.black,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.build_circle,
                    size: 42,
                    color: Colors.grey,
                  );
                },
              ),
            )
          : const Icon(
              Icons.build_outlined,
              size: 42,
              color: Colors.grey,
            ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: 16,
        top: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _selectedPartId != null
              ? () {
                  final partId = _selectedPartId!;
                  final part = _userParts.firstWhere(
                    (p) => p['id'] == partId,
                    orElse: () => {'name': 'Unknown Part'},
                  );
                  final partName = part['name'] != null
                      ? '${part['name']} ${part['condition'] ?? ''}'
                      : 'Selected Part';
                  widget.onPartSelected(partId, partName);
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.black,
            foregroundColor: AppColor.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: Text(
            'Select Car Part',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
        ),
      ),
    );
  }
}
