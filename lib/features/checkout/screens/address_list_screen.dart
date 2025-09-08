import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rikhh_app/features/checkout/bloc/checkout_state.dart';
import '../../../shared/components/checkout_scaffold.dart';
import '../bloc/checkout_cubit.dart';
import '../models/checkout_models.dart';
import 'add_address_screen.dart';

class AddressListScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  final String? selectedAddressId;
  final String addressType; // 'shipping' or 'billing'
  final Function(Address)? onAddressSelected;

  const AddressListScreen({
    super.key,
    required this.userData,
    this.selectedAddressId,
    required this.addressType,
    this.onAddressSelected,
  });

  @override
  State<AddressListScreen> createState() => _AddressListScreenState();
}

class _AddressListScreenState extends State<AddressListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CheckoutCubit>().loadAddresses(widget.userData);
  }

  @override
  Widget build(BuildContext context) {
    return CheckoutScaffold(
      title: '${widget.addressType} Addresses',
      body: Column(
        children: [
          // Add button in the body since we can't use actions in CheckoutScaffold
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select your ${widget.addressType} address',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                ElevatedButton.icon(
                  onPressed: _navigateToAddAddress,
                  icon: const Icon(Icons.add),
                  label: const Text('Add New'),
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocConsumer<CheckoutCubit, CheckoutState>(
              listener: (context, state) {
                if (state.status == CheckoutStatus.addressError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        state.errorMessage ?? 'Failed to load addresses',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state.status == CheckoutStatus.addressLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.addresses.isEmpty) {
                  return _buildEmptyState();
                }

                // ✅ Wrap your list inside a RadioGroup
                return RadioGroup<String>(
                  groupValue: widget.selectedAddressId,
                  onChanged: (value) {
                    final selected = state.addresses.firstWhere(
                      (a) => a.id == value,
                    );
                    if (widget.onAddressSelected != null) {
                      widget.onAddressSelected!(selected);
                    }
                    Navigator.pop(context, selected);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.addresses.length,
                    itemBuilder: (context, index) {
                      final address = state.addresses[index];
                      final isCorrectType = address.type == widget.addressType;

                      if (!isCorrectType) return const SizedBox.shrink();

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: Radio<String>(value: address.id),
                          title: Text(
                            '${address.firstName} ${address.lastName}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(address.addressLine1),
                              if (address.addressLine2 != null)
                                Text(address.addressLine2!),
                              Text(
                                '${address.city}, ${address.state} ${address.postalCode}',
                              ),
                              Text(address.country),
                              const SizedBox(height: 4),
                              Text(
                                'Phone: ${address.phone}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              if (address.isDefault)
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
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
                          trailing: PopupMenuButton(
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: ListTile(
                                  leading: Icon(Icons.edit),
                                  title: Text('Edit'),
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: ListTile(
                                  leading: Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
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
                              }
                            },
                          ),
                          onTap: () {
                            if (widget.onAddressSelected != null) {
                              widget.onAddressSelected!(address);
                            }
                            Navigator.pop(context, address);
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_on_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No ${widget.addressType} addresses found',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first ${widget.addressType} address to continue',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _navigateToAddAddress,
            icon: const Icon(Icons.add),
            label: const Text('Add Address'),
          ),
        ],
      ),
    );
  }

  void _navigateToAddAddress() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddAddressScreen(
          userData: widget.userData,
          addressType: widget.addressType,
        ),
      ),
    ).then((_) {
      // Refresh addresses after adding
      if (mounted) {
        context.read<CheckoutCubit>().loadAddresses(widget.userData);
      }
    });
  }

  void _navigateToEditAddress(Address address) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddAddressScreen(
          userData: widget.userData,
          addressType: widget.addressType,
          existingAddress: address,
        ),
      ),
    ).then((_) {
      // Refresh addresses after editing
      if (mounted) {
        context.read<CheckoutCubit>().loadAddresses(widget.userData);
      }
    });
  }

  void _showDeleteConfirmation(Address address) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Address'),
        content: Text(
          'Are you sure you want to delete this ${widget.addressType} address?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // To do
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Delete functionality not implemented yet'),
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
