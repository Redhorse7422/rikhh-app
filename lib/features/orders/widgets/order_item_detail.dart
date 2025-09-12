import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/order_detail_model.dart';
import '../../../core/theme/app_colors.dart';

class OrderItemDetail extends StatelessWidget {
  final OrderDetailItem item;
  final String shopName;

  const OrderItemDetail({
    super.key,
    required this.item,
    this.shopName = 'Womenza',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Product Image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: AppColors.background,
            ),
            child: item.thumbnailImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: item.thumbnailImage!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppColors.background,
                        child: const Icon(
                          Icons.image,
                          color: AppColors.body,
                          size: 32,
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.background,
                        child: const Icon(
                          Icons.image,
                          color: AppColors.body,
                          size: 32,
                        ),
                      ),
                    ),
                  )
                : Container(
                    color: AppColors.background,
                    child: const Icon(
                      Icons.image,
                      color: AppColors.body,
                      size: 32,
                    ),
                  ),
          ),
          
          const SizedBox(width: 16),
          
          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Name
                Text(
                  item.productName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.heading,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 8),
                
                // Quantity
                _buildDetailRow('QTY', '${item.quantity}'),
                
                // Variants
                ...item.selectedVariants.map((variant) => 
                  _buildDetailRow(variant.attributeName, variant.variantValue)
                ),
                
                // Shop Name
                _buildDetailRow('Shop', shopName),
                
                const SizedBox(height: 8),
                
                // Price
                Text(
                  'Price: ₹${item.unitPrice.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.heading,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.body,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.heading,
            ),
          ),
        ],
      ),
    );
  }
}
