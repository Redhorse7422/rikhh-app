import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:go_router/go_router.dart';
import '../models/order_detail_model.dart';
import '../models/order_status_update_model.dart';
import '../services/orders_api_service.dart';
import '../bloc/orders_bloc.dart';
import '../widgets/order_progress_tracker.dart';
import '../widgets/order_item_detail.dart';
import '../widgets/detail_section.dart';
import '../widgets/order_total_summary.dart';
import '../utils/order_utils.dart';
import '../../../core/theme/app_colors.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  OrderDetailModel? order;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
  }

  Future<void> _loadOrderDetails() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final response = await OrdersService.getOrderDetail(widget.orderId);

      if (response.success) {
        setState(() {
          order = response.data;
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Failed to load order details';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error loading order details: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (error != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Feather.alert_circle, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                'Error',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.heading,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: AppColors.body),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadOrderDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (order == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(child: Text('Order not found')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const Icon(
                      Feather.arrow_left,
                      size: 24,
                      color: AppColors.heading,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Order Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.heading,
                      ),
                    ),
                  ),
                  // Cancel Order Button (only show for certain statuses)
                  if (_canCancelOrder(order!.status))
                    ElevatedButton(
                      onPressed: _cancelOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: AppColors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Cancel Order',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // Order Number and Status
              Row(
                children: [
                  Text(
                    'Order Number',
                    style: TextStyle(fontSize: 14, color: AppColors.body),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    order!.orderNumber,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.heading,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: OrderUtils.getStatusColor(
                        order!.status,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      OrderUtils.getStatusDisplayName(order!.status),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: OrderUtils.getStatusColor(order!.status),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Order Progress Tracker
              OrderProgressTracker(
                status: order!.status,
                title: _getProgressTitle(),
                description: _getProgressDescription(),
              ),

              const SizedBox(height: 16),

              // Order Item Details
              ...order!.items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: OrderItemDetail(
                    item: item,
                    shopName:
                        'Womenza', // This could be dynamic based on seller info
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Delivery Details
              DetailSection(
                title: 'Delivery Details',
                details: [
                  DetailRow(
                    label: 'Shipping Address',
                    value: order!.shippingAddress.fullAddress,
                  ),
                  DetailRow(
                    label: 'Phone Number',
                    value: order!.shippingAddress.phone,
                  ),
                  DetailRow(
                    label: 'Delivery Method',
                    value: order!.shippingMethod.toUpperCase(),
                  ),
                  DetailRow(
                    label: 'Delivery Charges',
                    value: 'Rs.${order!.shippingAmount.toStringAsFixed(0)}',
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Payment Details
              DetailSection(
                title: 'Payment Details',
                details: [
                  DetailRow(
                    label: 'Payment Method',
                    value: _getPaymentMethodDisplayName(order!.paymentMethod),
                  ),
                  DetailRow(
                    label: 'Payment Status',
                    value: _getPaymentStatusDisplayName(order!.paymentStatus),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Order Total Summary
              OrderTotalSummary(
                subtotal: order!.subtotal,
                tax: order!.taxAmount,
                deliveryCharges: order!.shippingAmount,
                total: order!.totalAmount,
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  String _getProgressTitle() {
    switch (order!.status.toLowerCase()) {
      case 'pending':
        return 'Order Pending';
      case 'seller_notified':
        return 'Seller Notified';
      case 'seller_accepted':
      case 'confirmed':
        return 'Order Confirmed';
      case 'processing':
        return 'Order Processing';
      case 'shipped':
        return 'Order Shipped';
      case 'delivered':
        return 'Order Delivered';
      case 'cancelled':
        return 'Order Cancelled';
      default:
        return 'Order Processing';
    }
  }

  String _getProgressDescription() {
    switch (order!.status.toLowerCase()) {
      case 'pending':
        return 'Your order is being reviewed and will be processed soon.';
      case 'seller_notified':
        return 'The seller has been notified about your order.';
      case 'seller_accepted':
      case 'confirmed':
        return 'Your order has been confirmed and is being prepared.';
      case 'processing':
        return 'Your order is being prepared for shipment.';
      case 'shipped':
        return 'Your order is on its way and will arrive soon.';
      case 'delivered':
        return 'Your order has been successfully delivered.';
      case 'cancelled':
        return 'Your order has been cancelled and will not be processed.';
      default:
        return 'Your order is being processed.';
    }
  }

  String _getPaymentMethodDisplayName(String paymentMethod) {
    switch (paymentMethod.toLowerCase()) {
      case 'cash_on_delivery':
        return 'COD';
      case 'credit_card':
        return 'Credit Card';
      case 'debit_card':
        return 'Debit Card';
      case 'net_banking':
        return 'Net Banking';
      case 'upi':
        return 'UPI';
      case 'wallet':
        return 'Wallet';
      default:
        return paymentMethod.toUpperCase();
    }
  }

  String _getPaymentStatusDisplayName(String paymentStatus) {
    switch (paymentStatus.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'captured':
        return 'Paid';
      case 'failed':
        return 'Failed';
      case 'refunded':
        return 'Refunded';
      case 'partially_refunded':
        return 'Partially Refunded';
      default:
        return paymentStatus.toUpperCase();
    }
  }

  bool _canCancelOrder(String status) {
    final lowerStatus = status.toLowerCase();
    return lowerStatus == 'pending' ||
        lowerStatus == 'processing' ||
        lowerStatus == 'seller_accepted' ||
        lowerStatus == 'confirmed' ||
        lowerStatus == 'seller_notified';
  }

  void _cancelOrder() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order'),
        content: const Text(
          'Are you sure you want to cancel this order? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _confirmCancelOrder();
            },
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  void _confirmCancelOrder() async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Cancelling order...'),
          ],
        ),
      ),
    );

    try {
      // Call the API directly for better error handling
      final request = OrderStatusUpdateRequest(
        reason: 'other',
        notes: 'Order cancelled by customer',
      );

      await OrdersService.cancelOrder(widget.orderId, request);

      // Check if widget is still mounted before using context
      if (!mounted) return;

      // Close loading dialog
      Navigator.of(context).pop();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order cancelled successfully'),
          backgroundColor: Colors.green,
        ),
      );

      // Refresh the order details
      _loadOrderDetails();

      // Also refresh the orders list if we can access the bloc
      try {
        if (mounted) {
          context.read<OrdersBloc>().add(RefreshOrders());
        }
      } catch (e) {
        // If OrdersBloc is not available, ignore
      }
    } catch (e) {
      // Check if widget is still mounted before using context
      if (!mounted) return;

      // Close loading dialog
      Navigator.of(context).pop();

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error cancelling order: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
