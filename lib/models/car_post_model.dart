class CarPost {
  final String id;
  final String buyerId;
  final String carModel;
  final String description;
  final double minPrice;
  final double maxPrice;
  final String carImageUrl;
  final DateTime timestamp;
  final List<Bid> bids;
  final List<String> offers;
  final List<String> imageUrls;
  final String category;

  CarPost({
    required this.id,
    required this.buyerId,
    required this.carModel,
    required this.description,
    required this.minPrice,
    required this.maxPrice,
    required this.carImageUrl,
    required this.timestamp,
    this.bids = const [],
    this.offers = const [],
    this.imageUrls = const [],
    this.category = 'car',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'buyerId': buyerId,
      'carModel': carModel,
      'description': description,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'carImageUrl': carImageUrl,
      'timestamp': timestamp.toIso8601String(),
      'bids': bids.map((bid) => bid.toMap()).toList(),
      'offers': offers,
      'imageUrls': imageUrls,
      'category': category,
    };
  }

  factory CarPost.fromMap(Map<String, dynamic> map) {
    return CarPost(
      id: map['id'] as String,
      buyerId: map['buyerId'] as String,
      carModel: map['carModel'] as String,
      description: map['description'] as String,
      minPrice: (map['minPrice'] as num).toDouble(),
      maxPrice: (map['maxPrice'] as num).toDouble(),
      carImageUrl: map['carImageUrl'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      bids: (map['bids'] as List<dynamic>?)
              ?.map((e) => Bid.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      offers: (map['offers'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      imageUrls: (map['imageUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      category: map['category'] as String? ?? 'car',
    );
  }
}

class Bid {
  final String sellerId;
  final String carId;
  final double amount;
  final DateTime timestamp;

  Bid({
    required this.sellerId,
    required this.carId,
    required this.amount,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'sellerId': sellerId,
      'carId': carId,
      'amount': amount,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Bid.fromMap(Map<String, dynamic> map) {
    return Bid(
      sellerId: map['sellerId'],
      carId: map['carId'],
      amount: map['amount'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
