import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/order_model.dart';
import '../utils/order_utils.dart';
import '../../../core/theme/app_colors.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback? onViewDetails;

  const OrderCard({super.key, required this.order, this.onViewDetails});

  @override
  Widget build(BuildContext context) {
    final firstItem = order.items.isNotEmpty ? order.items.first : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image and Status Row
            Row(
              children: [
                // Product Image
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: AppColors.background,
                  ),
                  child: firstItem?.imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: firstItem!.imageUrl!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: AppColors.background,
                              child: const Icon(
                                Icons.image,
                                color: AppColors.body,
                                size: 24,
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: AppColors.background,
                              child: const Icon(
                                Icons.image,
                                color: AppColors.body,
                                size: 24,
                              ),
                            ),
                          ),
                        )
                      : Container(
                          color: AppColors.background,
                          child: const Icon(
                            Icons.image,
                            color: AppColors.body,
                            size: 24,
                          ),
                        ),
                ),
                const SizedBox(width: 12),

                // Order Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Order ID
                      Text(
                        OrderUtils.getOrderId(order.orderNumber),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.heading,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: OrderUtils.getStatusColor(
                            order.status,
                          ).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          OrderUtils.getStatusDisplayName(order.status),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: OrderUtils.getStatusColor(order.status),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Date and Time
            Text(
              OrderUtils.formatOrderDate(order.createdAt),
              style: const TextStyle(fontSize: 14, color: AppColors.body),
            ),

            // const SizedBox(height: 8),

            // Delivery Information
            // Text(
            //   OrderUtils.getDeliveryInfo(order),
            //   style: const TextStyle(fontSize: 14, color: AppColors.body),
            // ),
            const SizedBox(height: 12),

            // Price and Quantity Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${OrderUtils.formatPrice(order.totalAmount)} (COD)',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.heading,
                  ),
                ),
                Text(
                  'Item x ${order.items.length}',
                  style: const TextStyle(fontSize: 14, color: AppColors.body),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // View Details Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onViewDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonSecondary,
                  foregroundColor: AppColors.heading,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'View Details',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
