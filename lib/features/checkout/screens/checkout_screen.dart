import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rikhh_app/core/theme/app_colors.dart';
import 'package:rikhh_app/features/checkout/bloc/checkout_state.dart';
import '../../../shared/components/checkout_scaffold.dart';
import '../bloc/checkout_cubit.dart';
import '../models/checkout_models.dart';
import 'address_list_screen.dart';
import 'checkout_review_screen.dart';
import '../../../core/utils/app_logger.dart';

class CheckoutScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const CheckoutScreen({super.key, required this.userData});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  Address? _selectedShippingAddress;
  Address? _selectedBillingAddress;
  bool _useSameAddress = true;

  @override
  void initState() {
    super.initState();
    AppLogger.checkout(
      '🏠 CheckoutScreen: Initializing with user data: ${widget.userData}',
    );
    // Load default addresses
    context.read<CheckoutCubit>().loadDefaultAddresses(widget.userData);
  }

  @override
  Widget build(BuildContext context) {
    return CheckoutScaffold(
      title: 'Checkout',
      body: BlocConsumer<CheckoutCubit, CheckoutState>(
        listener: (context, state) {
          AppLogger.checkout(
            '🏠 CheckoutScreen: State changed - Status: ${state.status}',
          );

          if (state.status == CheckoutStatus.addressLoaded &&
              state.defaultAddresses != null) {
            AppLogger.checkout('🏠 CheckoutScreen: Setting default addresses');
            AppLogger.checkout(
              '  - Shipping address: ${state.defaultAddresses!.shippingAddress?.toString() ?? 'null'}',
            );
            AppLogger.checkout(
              '  - Billing address: ${state.defaultAddresses!.billingAddress?.toString() ?? 'null'}',
            );

            // Set default addresses
            _selectedShippingAddress = state.defaultAddresses!.shippingAddress;
            _selectedBillingAddress = state.defaultAddresses!.billingAddress;
            if (_useSameAddress) {
              _selectedBillingAddress = _selectedShippingAddress;
              AppLogger.checkout(
                '🏠 CheckoutScreen: Using same address for billing',
              );
            }
            AppLogger.checkout('🏠 CheckoutScreen: Address selection updated');
          } else if (state.status == CheckoutStatus.checkoutInitiated) {
            AppLogger.checkout(
              '🏠 CheckoutScreen: Checkout initiated, navigating to review screen',
            );
            // Navigate to review screen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => CheckoutReviewScreen(
                  userData: widget.userData,
                  checkoutSession: state.checkoutSession!,
                ),
              ),
            );
          } else if (state.status == CheckoutStatus.error) {
            AppLogger.checkout(
              '❌ CheckoutScreen: Error occurred: ${state.errorMessage}',
            );
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'An error occurred'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == CheckoutStatus.addressLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Shipping Address'),
                const SizedBox(height: 12),
                _buildAddressCard(
                  address: _selectedShippingAddress,
                  addressType: 'shipping',
                  onTap: () => _selectAddress('shipping'),
                ),
                const SizedBox(height: 24),
                _buildSectionHeader('Billing Address'),
                const SizedBox(height: 12),
                CheckboxListTile(
                  title: const Text('Same as shipping address'),
                  value: _useSameAddress,
                  onChanged: (value) {
                    setState(() {
                      _useSameAddress = value ?? false;
                      if (_useSameAddress) {
                        _selectedBillingAddress = _selectedShippingAddress;
                      }
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                if (!_useSameAddress) ...[
                  const SizedBox(height: 12),
                  _buildAddressCard(
                    address: _selectedBillingAddress,
                    addressType: 'billing',
                    onTap: () => _selectAddress('billing'),
                  ),
                ],
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _canProceed() ? _proceedToCheckout : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Proceed to Checkout'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _buildAddressCard({
    required Address? address,
    required String addressType,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: address == null
              ? Row(
                  children: [
                    Icon(Icons.location_on_outlined, color: Colors.grey[600]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Select $addressType address',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey[400],
                      size: 16,
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_on, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${address.firstName} ${address.lastName}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        if (address.isDefault)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'DEFAULT',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      address.addressLine1,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (address.addressLine2 != null)
                      Text(
                        address.addressLine2!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    Text(
                      '${address.city}, ${address.state} ${address.postalCode}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      address.country,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Phone: ${address.phone}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: onTap,
                          child: const Text('Change'),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  bool _canProceed() {
    return _selectedShippingAddress != null &&
        (_useSameAddress || _selectedBillingAddress != null);
  }

  void _selectAddress(String addressType) async {
    AppLogger.checkout('🏠 CheckoutScreen: Selecting $addressType address');
    AppLogger.checkout(
      '  - Current shipping address: ${_selectedShippingAddress?.toString() ?? 'null'}',
    );
    AppLogger.checkout(
      '  - Current billing address: ${_selectedBillingAddress?.toString() ?? 'null'}',
    );

    final result = await Navigator.push<Address>(
      context,
      MaterialPageRoute(
        builder: (context) => AddressListScreen(
          userData: widget.userData,
          addressType: addressType,
          selectedAddressId: addressType == 'shipping'
              ? _selectedShippingAddress?.id
              : _selectedBillingAddress?.id,
        ),
      ),
    );

    AppLogger.checkout(
      '🏠 CheckoutScreen: Address selection result: ${result?.toString() ?? 'null'}',
    );

    if (result != null) {
      AppLogger.checkout(
        '🏠 CheckoutScreen: Updating address selection for $addressType',
      );
      setState(() {
        if (addressType == 'shipping') {
          _selectedShippingAddress = result;
          if (_useSameAddress) {
            _selectedBillingAddress = result;
            AppLogger.checkout(
              '🏠 CheckoutScreen: Updated both shipping and billing addresses',
            );
          } else {
            AppLogger.checkout(
              '🏠 CheckoutScreen: Updated shipping address only',
            );
          }
        } else {
          _selectedBillingAddress = result;
          AppLogger.checkout('🏠 CheckoutScreen: Updated billing address only');
        }
      });
      AppLogger.checkout(
        '🏠 CheckoutScreen: Address selection updated successfully',
      );
    } else {
      AppLogger.checkout(
        '🏠 CheckoutScreen: No address selected, keeping current selection',
      );
    }
  }

  void _proceedToCheckout() {
    AppLogger.checkout('🏠 CheckoutScreen: Proceeding to checkout');
    AppLogger.checkout(
      '  - Selected shipping address: ${_selectedShippingAddress?.toString() ?? 'null'}',
    );
    AppLogger.checkout(
      '  - Selected billing address: ${_selectedBillingAddress?.toString() ?? 'null'}',
    );
    AppLogger.checkout('  - Use same address: $_useSameAddress');

    if (_selectedShippingAddress == null) {
      AppLogger.checkout(
        '❌ CheckoutScreen: Cannot proceed - no shipping address selected',
      );
      return;
    }

    final billingAddressId = _useSameAddress
        ? _selectedShippingAddress!.id
        : _selectedBillingAddress!.id;

    AppLogger.checkout('🏠 CheckoutScreen: Initiating checkout with:');
    AppLogger.checkout(
      '  - Shipping address ID: ${_selectedShippingAddress!.id}',
    );
    AppLogger.checkout('  - Billing address ID: $billingAddressId');

    context.read<CheckoutCubit>().initiateCheckout(
      userData: widget.userData,
      shippingAddressId: _selectedShippingAddress!.id,
      billingAddressId: billingAddressId,
    );
  }
}
