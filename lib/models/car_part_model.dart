class CarPart {
  final String id;
  final String name;
  final String make;
  final String model;
  final String partType;
  final String description;
  final double price;
  final String condition;
  final String imageUrl;
  final String sellerId;
  final DateTime timestamp;

  CarPart({
    required this.id,
    required this.name,
    required this.make,
    required this.model,
    required this.partType,
    required this.description,
    required this.price,
    required this.condition,
    required this.imageUrl,
    required this.sellerId,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'make': make,
      'model': model,
      'partType': partType,
      'description': description,
      'price': price,
      'condition': condition,
      'imageUrl': imageUrl,
      'sellerId': sellerId,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory CarPart.fromMap(Map<String, dynamic> map) {
    return CarPart(
      id: map['id'] as String,
      name: map['name'] as String,
      make: map['make'] as String,
      model: map['model'] as String,
      partType: map['partType'] as String,
      description: map['description'] as String,
      price: (map['price'] as num).toDouble(),
      condition: map['condition'] as String,
      imageUrl: map['imageUrl'] as String,
      sellerId: map['sellerId'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }
} 