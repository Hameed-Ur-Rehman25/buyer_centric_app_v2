// Custom Bid class with sellerName field
class CustomBid {
  final String sellerId;
  final String carId;
  final double amount;
  final DateTime timestamp;
  final String sellerName;

  CustomBid({
    required this.sellerId,
    required this.carId,
    required this.amount,
    required this.timestamp,
    this.sellerName = 'Unknown Seller',
  });
}
