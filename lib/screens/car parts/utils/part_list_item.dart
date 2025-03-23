import 'package:flutter/material.dart';
import 'package:buyer_centric_app_v2/theme/colors.dart';

class PartListItem extends StatelessWidget {
  final Map<String, dynamic> part;
  final VoidCallback onTap;

  const PartListItem({
    super.key,
    required this.part,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final make = (part['make'] as String?)?.toUpperCase() ?? 'N/A';
    final model = (part['model'] as String?)?.toUpperCase() ?? 'N/A';
    final partType = part['partType'] ?? 'N/A';
    final price = part['price']?.toString() ?? 'N/A';
    final condition = part['condition'] ?? 'N/A';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColor.green.withOpacity(0.3)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _buildLeadingImage(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$make $model',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Part Type: $partType',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'PKR $price',
                          style: const TextStyle(
                            color: AppColor.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColor.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            condition,
                            style: const TextStyle(
                              color: AppColor.green,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColor.green,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeadingImage() {
    final imageUrl = part['imageUrl'] as String?;
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColor.green.withOpacity(0.3),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: imageUrl != null && imageUrl.isNotEmpty
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildPlaceholder(),
              )
            : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColor.green.withOpacity(0.1),
      child: Icon(
        Icons.car_repair,
        size: 32,
        color: AppColor.green.withOpacity(0.5),
      ),
    );
  }
}
