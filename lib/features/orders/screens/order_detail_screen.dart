import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:go_router/go_router.dart';
import '../models/order_detail_model.dart';
import '../services/orders_api_service.dart';
import '../widgets/order_progress_tracker.dart';
import '../widgets/order_item_detail.dart';
import '../widgets/detail_section.dart';
import '../widgets/order_total_summary.dart';
import '../utils/order_utils.dart';
import '../../../core/theme/app_colors.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({
    super.key,
    required this.orderId,
  });

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
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
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
              Icon(
                Feather.alert_circle,
                size: 64,
                color: AppColors.error,
              ),
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
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.body,
                ),
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
        body: const Center(
          child: Text('Order not found'),
        ),
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
                  if (order!.status.toLowerCase() == 'processing' ||
                      order!.status.toLowerCase() == 'pending')
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
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.body,
                    ),
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
                      color: OrderUtils.getStatusColor(order!.status).withOpacity(0.1),
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
              ...order!.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: OrderItemDetail(
                  item: item,
                  shopName: 'Womenza', // This could be dynamic based on seller info
                ),
              )),
              
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
      case 'processing':
      case 'pending':
        return 'Order Pending';
      case 'confirmed':
      case 'dispatched':
        return 'Order Dispatched';
      case 'shipped':
        return 'Order out of Delivery';
      case 'delivered':
        return 'Order Delivered';
      default:
        return 'Order Processing';
    }
  }

  String _getProgressDescription() {
    switch (order!.status.toLowerCase()) {
      case 'processing':
      case 'pending':
        return 'Your order is being prepared.';
      case 'confirmed':
      case 'dispatched':
        return 'Your order has been dispatched from our warehouse.';
      case 'shipped':
        return 'Your order is currently routed to your address.';
      case 'delivered':
        return 'Your order has been successfully delivered.';
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

  void _cancelOrder() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order'),
        content: const Text('Are you sure you want to cancel this order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Handle order cancellation
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Order cancelled successfully'),
                ),
              );
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }
}
