import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class OrderTotalSummary extends StatelessWidget {
  final double subtotal;
  final double tax;
  final double deliveryCharges;
  final double total;

  const OrderTotalSummary({
    super.key,
    required this.subtotal,
    required this.tax,
    required this.deliveryCharges,
    required this.total,
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
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Total',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.heading,
            ),
          ),
          const SizedBox(height: 16),

          // Subtotal
          _buildTotalRow('Subtotal:', subtotal),

          // Tax
          _buildTotalRow('Tax:', tax),

          // Delivery
          _buildTotalRow('Delivery:', deliveryCharges),

          const Divider(color: AppColors.divider),

          // Total
          _buildTotalRow('Total to pay:', total, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
              color: isTotal ? AppColors.heading : AppColors.body,
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
              color: isTotal ? AppColors.heading : AppColors.body,
            ),
          ),
        ],
      ),
    );
  }
}
