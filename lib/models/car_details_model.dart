class CarDetails {
  final String imageUrl;
  final String description;
  final String sellerId;
  // Add other relevant fields

  CarDetails({
    required this.imageUrl,
    required this.description,
    required this.sellerId,
    // Initialize other fields
  });

  factory CarDetails.fromMap(Map<String, dynamic> map) {
    return CarDetails(
      imageUrl: map['imageUrl'] ?? '',
      description: map['description'] ?? '',
      sellerId: map['sellerId'] ?? '',
      // Map other fields
    );
  }
}
