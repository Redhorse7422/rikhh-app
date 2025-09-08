import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/components/checkout_scaffold.dart';
import '../models/checkout_models.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final Order order;

  const OrderConfirmationScreen({super.key, required this.order});

  // Helper method to get the order summary with fallback calculation
  CheckoutSummary get _effectiveOrderSummary {
    // If the order summary has zero values but we have items, recalculate
    if (order.orderSummary.subtotal == 0.0 &&
        order.orderSummary.total == 0.0 &&
        order.items.isNotEmpty) {
      return CheckoutSummary.fromItems(order.items);
    }
    return order.orderSummary;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevent back navigation
      child: CheckoutScaffold(
        title: 'Order Confirmation',
        showBackButton: false,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSuccessHeader(),
              const SizedBox(height: 24),
              _buildOrderInfo(context),
              const SizedBox(height: 24),
              _buildOrderItems(context),
              const SizedBox(height: 24),
              _buildOrderSummary(context),
              const SizedBox(height: 24),
              _buildDeliveryInfo(context),
              const SizedBox(height: 32),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessHeader() {
    return Card(
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.check_circle, size: 64, color: Colors.green[600]),
            const SizedBox(height: 16),
            Text(
              'Order Placed Successfully!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Thank you for your order. We\'ll send you a confirmation email shortly.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.green[700]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderInfo(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Information',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Order Number', order.orderNumber),
            _buildInfoRow('Status', _getStatusText(order.status)),
            _buildInfoRow(
              'Payment Status',
              _getPaymentStatusText(order.paymentStatus),
            ),
            _buildInfoRow('Order Date', _formatDate(order.createdAt)),
            if (order.trackingNumber != null)
              _buildInfoRow('Tracking Number', order.trackingNumber!),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItems(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Items',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (order.items.isEmpty)
              const Text('No items found in this order')
            else
              ...order.items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          image: item.imageUrl != null
                              ? DecorationImage(
                                  image: NetworkImage(item.imageUrl!),
                                  fit: BoxFit.cover,
                                  onError: (exception, stackTrace) {
                                    // Handle image loading error
                                  },
                                )
                              : null,
                        ),
                        child: item.imageUrl == null
                            ? const Icon(Icons.image)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text('Qty: ${item.quantity}'),
                            Text(
                              'Unit: \$${item.unitPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              'Total: \$${item.totalPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(BuildContext context) {
    final effectiveSummary = _effectiveOrderSummary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Summary',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildSummaryRow(context, 'Subtotal', effectiveSummary.subtotal),
            _buildSummaryRow(context, 'Shipping', effectiveSummary.shipping),
            _buildSummaryRow(context, 'Tax', effectiveSummary.tax),
            if (effectiveSummary.discount > 0)
              _buildSummaryRow(
                context,
                'Discount',
                -effectiveSummary.discount,
                isDiscount: true,
              ),
            const Divider(),
            _buildSummaryRow(
              context,
              'Total',
              effectiveSummary.total,
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryInfo(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Delivery Information',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (order.shippingAddress != null) ...[
                Text(
                  'Shipping Address',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${order.shippingAddress!.firstName} ${order.shippingAddress!.lastName}',
                ),
                Text(order.shippingAddress!.addressLine1),
                if (order.shippingAddress!.addressLine2 != null)
                  Text(order.shippingAddress!.addressLine2!),
                Text(
                  '${order.shippingAddress!.city}, ${order.shippingAddress!.state} ${order.shippingAddress!.postalCode}',
                ),
                Text(order.shippingAddress!.country),
                const SizedBox(height: 4),
                Text('Phone: ${order.shippingAddress!.phone}'),
              ],
              if (order.billingAddress != null &&
                  order.billingAddress != order.shippingAddress) ...[
                const SizedBox(height: 16),
                Text(
                  'Billing Address',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${order.billingAddress!.firstName} ${order.billingAddress!.lastName}',
                ),
                Text(order.billingAddress!.addressLine1),
                if (order.billingAddress!.addressLine2 != null)
                  Text(order.billingAddress!.addressLine2!),
                Text(
                  '${order.billingAddress!.city}, ${order.billingAddress!.state} ${order.billingAddress!.postalCode}',
                ),
                Text(order.billingAddress!.country),
                const SizedBox(height: 4),
                Text('Phone: ${order.billingAddress!.phone}'),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // Navigate to home screen
              context.go('/main/home');
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Continue Shopping'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              // Navigate to orders screen
              context.go('/orders');
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('View Order Details'),
          ),
        ),
        if (order.paymentUrl != null) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // Open payment URL
              },
              icon: const Icon(Icons.payment),
              label: const Text('Complete Payment'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.orange,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    String label,
    double amount, {
    bool isDiscount = false,
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
                : null,
          ),
          Text(
            '${isDiscount ? '-' : ''}\$${amount.toStringAsFixed(2)}',
            style: isTotal
                ? Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  )
                : isDiscount
                ? const TextStyle(color: Colors.green)
                : null,
          ),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'processing':
        return 'Processing';
      case 'shipped':
        return 'Shipped';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  String _getPaymentStatusText(String paymentStatus) {
    switch (paymentStatus.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'paid':
        return 'Paid';
      case 'failed':
        return 'Failed';
      case 'refunded':
        return 'Refunded';
      default:
        return paymentStatus;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
