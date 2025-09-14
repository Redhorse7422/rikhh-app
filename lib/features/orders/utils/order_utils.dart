import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../../../core/theme/app_colors.dart';

class OrderUtils {
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFFF9800); // Orange
      case 'seller_notified':
        return const Color(0xFF2196F3); // Blue
      case 'seller_accepted':
        return const Color(0xFF2196F3); // Blue
      case 'confirmed':
        return const Color(0xFF2196F3); // Blue
      case 'processing':
        return const Color(0xFFFF9800); // Orange
      case 'shipped':
        return const Color(0xFF9C27B0); // Purple
      case 'delivered':
        return const Color(0xFF4CAF50); // Green
      case 'cancelled':
        return const Color(0xFFE53E3E); // Red
      case 'refunded':
        return const Color(0xFF9E9E9E); // Gray
      case 'returned':
        return const Color(0xFF9E9E9E); // Gray
      default:
        return AppColors.body;
    }
  }

  static String getStatusDisplayName(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';

      case 'processing':
      case 'seller_notified':
      case 'seller_accepted':
      case 'confirmed':
      case 'shipped':
        return 'Processing';

      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      case 'refunded':
        return 'Refunded';
      case 'returned':
        return 'Returned';

      default:
        return status;
    }
  }

  static String getDeliveryInfo(OrderModel order) {
    switch (order.status.toLowerCase()) {
      case 'processing':
        return '3-5 days expected';
      case 'confirmed':
        return 'Delivery on ${_formatDate(order.createdAt.add(const Duration(days: 3)))}';
      case 'shipped':
        return 'Out for delivery';
      case 'delivered':
        return 'Delivered on ${_formatDate(order.updatedAt)}';
      case 'cancelled':
        return 'Not Delivered';
      default:
        return 'Processing';
    }
  }

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  static String formatOrderDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final month = months[date.month - 1];
    final day = date.day.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    final ampm = date.hour >= 12 ? 'PM' : 'AM';
    final displayHour = date.hour > 12
        ? date.hour - 12
        : (date.hour == 0 ? 12 : date.hour);

    return '$month $day, ${date.year}, ${displayHour.toString().padLeft(2, '0')}:$minute $ampm';
  }

  static String formatPrice(double price) {
    return '₹${price.toStringAsFixed(0)}';
  }

  static String getOrderId(String id) {
    return '#$id';
  }
}
