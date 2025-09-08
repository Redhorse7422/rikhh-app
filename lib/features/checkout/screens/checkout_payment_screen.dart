import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rikhh_app/core/theme/app_colors.dart';
import 'package:rikhh_app/features/checkout/bloc/checkout_state.dart';
import '../../../shared/components/checkout_scaffold.dart';
import '../bloc/checkout_cubit.dart';
import '../models/checkout_models.dart';
import 'order_confirmation_screen.dart';

class CheckoutPaymentScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  final CheckoutSession checkoutSession;
  final String selectedPaymentMethod;

  const CheckoutPaymentScreen({
    super.key,
    required this.userData,
    required this.checkoutSession,
    required this.selectedPaymentMethod,
  });

  @override
  State<CheckoutPaymentScreen> createState() => _CheckoutPaymentScreenState();
}

class _CheckoutPaymentScreenState extends State<CheckoutPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  // Credit card fields
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardNameController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _cardNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CheckoutScaffold(
      title: 'Payment',
      body: BlocConsumer<CheckoutCubit, CheckoutState>(
        listener: (context, state) {
          if (state.status == CheckoutStatus.orderConfirmed) {
            // Navigate to order confirmation
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    OrderConfirmationScreen(order: state.order!),
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
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOrderSummary(),
                  const SizedBox(height: 24),
                  _buildPaymentMethodSection(),
                  const SizedBox(height: 24),
                  // Credit card form removed - only cash on delivery
                  _buildNotesSection(),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: state.status == CheckoutStatus.loading
                          ? null
                          : _placeOrder,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: state.status == CheckoutStatus.loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(_getPlaceOrderButtonText()),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderSummary() {
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
            _buildSummaryRow(
              'Subtotal',
              widget.checkoutSession.summary.subtotal,
            ),
            _buildSummaryRow(
              'Shipping',
              0.0, // Free shipping
            ),
            _buildSummaryRow('Tax', widget.checkoutSession.summary.tax),
            if (widget.checkoutSession.summary.discount > 0)
              _buildSummaryRow(
                'Discount',
                -widget.checkoutSession.summary.discount,
                isDiscount: true,
              ),
            const Divider(),
            _buildSummaryRow(
              'Total',
              widget.checkoutSession.summary.total,
              isTotal: true,
            ),
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

  Widget _buildPaymentMethodSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Method',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
                  Icon(_getPaymentMethodIcon(), color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getPaymentMethodName(),
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          _getPaymentMethodDescription(),
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

  Widget _buildNotesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Notes (Optional)',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                hintText: 'Any special instructions for your order...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getPaymentMethodIcon() {
    switch (widget.selectedPaymentMethod) {
      case 'credit_card':
        return Icons.credit_card;
      case 'paypal':
        return Icons.payment;
      case 'cash_on_delivery':
        return Icons.money;
      default:
        return Icons.payment;
    }
  }

  String _getPaymentMethodName() {
    switch (widget.selectedPaymentMethod) {
      case 'credit_card':
        return 'Credit Card';
      case 'paypal':
        return 'PayPal';
      case 'cash_on_delivery':
        return 'Cash on Delivery';
      default:
        return widget.selectedPaymentMethod;
    }
  }

  String _getPaymentMethodDescription() {
    switch (widget.selectedPaymentMethod) {
      case 'credit_card':
        return 'Pay with your credit or debit card';
      case 'paypal':
        return 'Pay securely with PayPal';
      case 'cash_on_delivery':
        return 'Pay when your order arrives';
      default:
        return '';
    }
  }

  String _getPlaceOrderButtonText() {
    switch (widget.selectedPaymentMethod) {
      case 'credit_card':
        return 'Pay \$${widget.checkoutSession.summary.total.toStringAsFixed(2)}';
      case 'paypal':
        return 'Pay with PayPal';
      case 'cash_on_delivery':
        return 'Place Order (Pay on Delivery)';
      default:
        return 'Place Order';
    }
  }

  void _placeOrder() {
    // No validation needed for cash on delivery

    final customerInfo = CustomerInfo(
      email: widget.userData['email'] ?? '',
      firstName: widget.userData['firstName'] ?? '',
      lastName: widget.userData['lastName'] ?? '',
      phone: widget.userData['phone'] ?? '',
    );

    context.read<CheckoutCubit>().confirmOrder(
      userData: widget.userData,
      checkoutId: widget.checkoutSession.checkoutId,
      customerInfo: customerInfo,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      couponCode: widget.checkoutSession.couponCode,
    );
  }
}
