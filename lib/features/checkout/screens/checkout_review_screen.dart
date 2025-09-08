import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rikhh_app/core/theme/app_colors.dart';
import 'package:rikhh_app/features/checkout/bloc/checkout_state.dart';
import '../../../shared/components/checkout_scaffold.dart';
import '../../../shared/components/optimized_image.dart';
import '../../../core/services/image_optimization_service.dart';
import '../bloc/checkout_cubit.dart';
import '../models/checkout_models.dart';
import 'checkout_payment_screen.dart';

class CheckoutReviewScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  final CheckoutSession checkoutSession;

  const CheckoutReviewScreen({
    super.key,
    required this.userData,
    required this.checkoutSession,
  });

  @override
  State<CheckoutReviewScreen> createState() => _CheckoutReviewScreenState();
}

class _CheckoutReviewScreenState extends State<CheckoutReviewScreen> {
  final _couponController = TextEditingController();
  String? _selectedPaymentMethod;

  @override
  void initState() {
    super.initState();
    // Set default payment method to cash on delivery
    _selectedPaymentMethod = 'cash_on_delivery';

    // Recalculate summary if values are zero and fetch images from cart if missing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final session = widget.checkoutSession;
      if (session.summary.subtotal == 0.0 &&
          session.summary.total == 0.0 &&
          session.items.isNotEmpty) {
        context.read<CheckoutCubit>().recalculateSummary();
      }

      // Check if any items are missing images and fetch from cart
      final hasMissingImages = session.items.any(
        (item) =>
            item.imageUrl == null ||
            item.imageUrl!.isEmpty ||
            item.imageUrl!.contains('unsplash.com'),
      );

      if (hasMissingImages) {
        context.read<CheckoutCubit>().fetchImagesFromCart(widget.userData);
      }
    });
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CheckoutScaffold(
      title: 'Review Order',
      body: BlocConsumer<CheckoutCubit, CheckoutState>(
        listener: (context, state) {
          if (state.status == CheckoutStatus.couponApplied) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Coupon applied successfully'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state.status == CheckoutStatus.couponRemoved) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Coupon removed')));
          } else if (state.status == CheckoutStatus.shippingMethodUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Shipping method updated'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state.status == CheckoutStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'An error occurred'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          final session = state.checkoutSession ?? widget.checkoutSession;

          // Show loading indicator for operations in progress
          if (state.isOperationInProgress) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Processing...'),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOrderItems(session),
                const SizedBox(height: 24),
                _buildShippingAddress(session),
                const SizedBox(height: 24),
                _buildBillingAddress(session),
                const SizedBox(height: 24),
                _buildShippingMethods(session),
                const SizedBox(height: 24),
                _buildCouponSection(session),
                const SizedBox(height: 24),
                _buildOrderSummary(session),
                const SizedBox(height: 32),
                _buildPaymentMethods(session),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _canProceed() && !state.isOperationInProgress
                        ? _proceedToPayment
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: state.isOperationInProgress
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Proceed to Payment'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderItems(CheckoutSession session) {
    if (session.items.isEmpty) {
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
              const Text('No items found in checkout session'),
            ],
          ),
        ),
      );
    }

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
            ...session.items.asMap().entries.map(
              (entry) => _OrderItemWidget(
                key: ValueKey(entry.value.productId),
                item: entry.value,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingAddress(CheckoutSession session) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Shipping Address',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    // To do
                  },
                  child: const Text('Change'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (session.shippingAddress != null) ...[
              Text(
                '${session.shippingAddress!.firstName} ${session.shippingAddress!.lastName}',
              ),
              Text(session.shippingAddress!.addressLine1),
              if (session.shippingAddress!.addressLine2 != null)
                Text(session.shippingAddress!.addressLine2!),
              Text(
                '${session.shippingAddress!.city}, ${session.shippingAddress!.state} ${session.shippingAddress!.postalCode}',
              ),
              Text(session.shippingAddress!.country),
              const SizedBox(height: 4),
              Text('Phone: ${session.shippingAddress!.phone}'),
            ] else
              const Text('No shipping address selected'),
          ],
        ),
      ),
    );
  }

  Widget _buildBillingAddress(CheckoutSession session) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Billing Address',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    // to do
                  },
                  child: const Text('Change'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (session.billingAddress != null) ...[
              Text(
                '${session.billingAddress!.firstName} ${session.billingAddress!.lastName}',
              ),
              Text(session.billingAddress!.addressLine1),
              if (session.billingAddress!.addressLine2 != null)
                Text(session.billingAddress!.addressLine2!),
              Text(
                '${session.billingAddress!.city}, ${session.billingAddress!.state} ${session.billingAddress!.postalCode}',
              ),
              Text(session.billingAddress!.country),
              const SizedBox(height: 4),
              Text('Phone: ${session.billingAddress!.phone}'),
            ] else
              const Text('No billing address selected'),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingMethods(CheckoutSession session) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Delivery Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.heading,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.local_shipping, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Standard Delivery',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: AppColors.heading,
                          ),
                        ),
                        // Text(
                        //   'Free delivery',
                        //   style: Theme.of(context).textTheme.bodySmall,
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCouponSection(CheckoutSession session) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Coupon Code',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.heading,
              ),
            ),
            const SizedBox(height: 12),
            if (session.couponCode != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Coupon "${session.couponCode}" applied',
                        style: TextStyle(color: Colors.green[800]),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _removeCoupon(),
                      child: const Text('Remove'),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _couponController,
                      decoration: const InputDecoration(
                        hintText: 'Enter coupon code',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _applyCoupon,
                    child: const Text('Apply'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(CheckoutSession session) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Summary',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.heading,
              ),
            ),
            const SizedBox(height: 16),
            _buildSummaryRow('Subtotal', session.summary.subtotal),
            _buildSummaryRow('Shipping', 0.0), // Free shipping
            _buildSummaryRow('Tax', session.summary.tax),
            if (session.summary.discount > 0)
              _buildSummaryRow(
                'Discount',
                -session.summary.discount,
                isDiscount: true,
              ),
            const Divider(),
            _buildSummaryRow('Total', session.summary.total, isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
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
                ? Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.heading,
                  )
                : Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.heading,
                  ),
          ),
          Text(
            '${isDiscount ? '-' : ''}\$${amount.toStringAsFixed(2)}',
            style: isTotal
                ? Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  )
                : isDiscount
                ? const TextStyle(color: Colors.green)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods(CheckoutSession session) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Method',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.heading,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.money, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cash on Delivery',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: AppColors.heading,
                          ),
                        ),
                        Text(
                          'Pay when your order arrives',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _canProceed() {
    return _selectedPaymentMethod != null;
  }

  void _applyCoupon() {
    if (_couponController.text.trim().isEmpty) return;

    context.read<CheckoutCubit>().applyCoupon(
      userData: widget.userData,
      checkoutId: widget.checkoutSession.checkoutId,
      couponCode: _couponController.text.trim(),
    );
  }

  void _removeCoupon() {
    context.read<CheckoutCubit>().removeCoupon(
      userData: widget.userData,
      checkoutId: widget.checkoutSession.checkoutId,
    );
  }

  // Shipping method update removed - using free shipping

  void _proceedToPayment() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutPaymentScreen(
          userData: widget.userData,
          checkoutSession: widget.checkoutSession,
          selectedPaymentMethod: _selectedPaymentMethod!,
        ),
      ),
    );
  }
}

// Optimized widget for order items to prevent unnecessary rebuilds
class _OrderItemWidget extends StatelessWidget {
  final CheckoutItem item;

  const _OrderItemWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: OptimizedImage(
                imageUrl:
                    item.imageUrl ??
                    'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400&h=400&fit=crop',
                fit: BoxFit.cover,
                width: 60,
                height: 60,
                size: ImageSize.thumbnail,
                borderRadius: BorderRadius.circular(8),
                errorWidget: Container(
                  color: Colors.grey[200],
                  child: const Icon(
                    Icons.image_not_supported,
                    color: Colors.grey,
                    size: 24,
                  ),
                ),
                placeholder: Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text('Qty: ${item.quantity}'),
                Text(
                  '\$${item.totalPrice.toStringAsFixed(2)}',
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
    );
  }
}
