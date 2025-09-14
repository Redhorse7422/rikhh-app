import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../features/auth/bloc/auth_bloc.dart';
import '../../../features/checkout/bloc/checkout_cubit.dart';
import '../../../features/checkout/bloc/checkout_state.dart';
import '../../../features/checkout/models/checkout_models.dart';
import '../../../features/checkout/screens/add_address_screen.dart';

class AddressListScreen extends StatefulWidget {
  const AddressListScreen({super.key});

  @override
  State<AddressListScreen> createState() => _AddressListScreenState();
}

class _AddressListScreenState extends State<AddressListScreen> {
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  void _loadAddresses() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated && authState.user.isNotEmpty) {
      context.read<CheckoutCubit>().loadAddresses(authState.user);
    }
  }

  List<Address> _filterAddresses(List<Address> addresses) {
    if (_selectedFilter == 'All') {
      return addresses;
    } else if (_selectedFilter == 'Shipping') {
      return addresses.where((address) => address.type == 'shipping').toList();
    } else if (_selectedFilter == 'Billing') {
      return addresses.where((address) => address.type == 'billing').toList();
    }
    return addresses;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Feather.arrow_left, color: AppColors.heading),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'My Addresses',
          style: TextStyle(
            color: AppColors.heading,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Feather.plus, color: AppColors.primary),
            onPressed: _navigateToAddAddress,
          ),
        ],
      ),
      body: BlocConsumer<CheckoutCubit, CheckoutState>(
        listener: (context, state) {
          if (state.status == CheckoutStatus.addressError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Failed to load addresses'),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state.isOperationInProgress) {
            // Show loading indicator for operations
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 16),
                    Text('Processing...'),
                  ],
                ),
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == CheckoutStatus.addressLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final filteredAddresses = _filterAddresses(state.addresses);
          if (filteredAddresses.isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            children: [
              // Address Type Tabs
              _buildAddressTypeTabs(),

              // Address List
              Expanded(child: _buildAddressList(filteredAddresses)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAddressTypeTabs() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(child: _buildTabButton('All', _selectedFilter == 'All')),
          Expanded(
            child: _buildTabButton('Shipping', _selectedFilter == 'Shipping'),
          ),
          Expanded(
            child: _buildTabButton('Billing', _selectedFilter == 'Billing'),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.body,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildAddressList(List<Address> addresses) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: addresses.length,
      itemBuilder: (context, index) {
        final address = addresses[index];
        return _buildAddressCard(address);
      },
    );
  }

  Widget _buildAddressCard(Address address) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with name and type
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: address.isDefault
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: address.isDefault
                        ? AppColors.primary
                        : Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    address.type == 'shipping'
                        ? Feather.truck
                        : Feather.credit_card,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${address.firstName} ${address.lastName}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.heading,
                        ),
                      ),
                      Text(
                        address.type.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.body,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (address.isDefault)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
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
                PopupMenuButton(
                  icon: Icon(Feather.more_vertical, color: AppColors.body),
                  itemBuilder: (context) => [
                    if (!address.isDefault)
                      const PopupMenuItem(
                        value: 'set_default',
                        child: ListTile(
                          leading: Icon(Feather.star),
                          title: Text('Set as Default'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                        leading: Icon(Feather.edit_3),
                        title: Text('Edit'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Feather.trash_2, color: Colors.red),
                        title: Text(
                          'Delete',
                          style: TextStyle(color: Colors.red),
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      _navigateToEditAddress(address);
                    } else if (value == 'delete') {
                      _showDeleteConfirmation(address);
                    } else if (value == 'set_default') {
                      _setAsDefaultAddress(address);
                    }
                  },
                ),
              ],
            ),
          ),

          // Address Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  address.addressLine1,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.heading,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (address.addressLine2 != null &&
                    address.addressLine2!.isNotEmpty)
                  Text(
                    address.addressLine2!,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.heading,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  '${address.city}, ${address.state} ${address.postalCode}',
                  style: TextStyle(fontSize: 14, color: AppColors.body),
                ),
                Text(
                  address.country,
                  style: TextStyle(fontSize: 14, color: AppColors.body),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Feather.phone, size: 16, color: AppColors.body),
                    const SizedBox(width: 8),
                    Text(
                      address.phone,
                      style: TextStyle(fontSize: 14, color: AppColors.body),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Feather.mail, size: 16, color: AppColors.body),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        address.email,
                        style: TextStyle(fontSize: 14, color: AppColors.body),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    String title = 'No Addresses Found';
    String message =
        'Add your first address to get started with faster checkout and delivery.';

    if (_selectedFilter == 'Shipping') {
      title = 'No Shipping Addresses';
      message =
          'Add your first shipping address for faster checkout and delivery.';
    } else if (_selectedFilter == 'Billing') {
      title = 'No Billing Addresses';
      message = 'Add your first billing address for payment processing.';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(Feather.map_pin, size: 48, color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.heading,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.body,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _navigateToAddAddress,
              icon: const Icon(Feather.plus),
              label: const Text('Add Address'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToAddAddress() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated && authState.user.isNotEmpty) {
      String addressType = 'shipping'; // Default to shipping
      if (_selectedFilter == 'Billing') {
        addressType = 'billing';
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddAddressScreen(
            userData: authState.user,
            addressType: addressType,
          ),
        ),
      ).then((_) {
        // Refresh addresses after adding
        if (mounted) {
          _loadAddresses();
        }
      });
    }
  }

  void _navigateToEditAddress(Address address) {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated && authState.user.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddAddressScreen(
            userData: authState.user,
            addressType: address.type,
            existingAddress: address,
          ),
        ),
      ).then((_) {
        // Refresh addresses after editing
        if (mounted) {
          _loadAddresses();
        }
      });
    }
  }

  void _showDeleteConfirmation(Address address) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Feather.trash_2, color: Colors.red, size: 24),
            const SizedBox(width: 12),
            const Text(
              'Delete Address',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete this ${address.type} address? This action cannot be undone.',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.body, fontSize: 16),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAddress(address);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Delete', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  void _deleteAddress(Address address) {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated && authState.user.isNotEmpty) {
      context
          .read<CheckoutCubit>()
          .deleteAddress(authState.user, address.id)
          .then((_) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Address deleted successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          });
    }
  }

  void _setAsDefaultAddress(Address address) {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated && authState.user.isNotEmpty) {
      context
          .read<CheckoutCubit>()
          .setDefaultAddress(authState.user, address.id)
          .then((_) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Address set as default successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          });
    }
  }
}
