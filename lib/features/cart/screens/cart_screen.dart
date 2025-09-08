import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../bloc/cart_cubit.dart';
import '../models/cart_models.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../../shared/components/top_search_bar.dart';
import '../../checkout/screens/checkout_screen.dart';

class CartScreen extends StatefulWidget {
  final VoidCallback? onBackPressed;

  const CartScreen({super.key, this.onBackPressed});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();

    // Get user data from AuthBloc and load cart
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<CartCubit>().load(authState.user);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  List<CartItem> _getFilteredItems(List<CartItem> items) {
    if (_searchQuery.isEmpty) {
      return items;
    }
    return items
        .where((item) => item.name.toLowerCase().contains(_searchQuery))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: BlocBuilder<CartCubit, CartState>(
          builder: (context, state) {
            if (state.status == CartStatus.loading && state.items.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == CartStatus.error && state.items.isEmpty) {
              return _buildErrorState(state.errorMessage);
            }

            if (state.items.isEmpty) {
              return _buildEmptyCart();
            }

            // Check if search has no results
            if (_searchQuery.isNotEmpty &&
                _getFilteredItems(state.items).isEmpty) {
              return _buildNoSearchResults();
            }

            return Column(
              children: [
                // Custom Header
                _buildHeader(context),

                // Search Bar
                TopSearchBar(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  hintText: 'Search in cart...',
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                  onSearch: () {
                    // Search is handled by onChanged
                  },
                  onClear: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),

                // Items Count
                _buildItemsCount(_getFilteredItems(state.items).length),

                // Cart Items
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      final authState = context.read<AuthBloc>().state;
                      if (authState is AuthAuthenticated) {
                        await context.read<CartCubit>().refresh(authState.user);
                      }
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: _getFilteredItems(state.items).length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = _getFilteredItems(state.items)[index];
                        return _CartItemCard(
                          item: item,
                          isLoading: state.actionInProgress,
                          onQtyChanged: (qty) {
                            final authState = context.read<AuthBloc>().state;
                            if (authState is AuthAuthenticated) {
                              context.read<CartCubit>().updateQuantity(
                                authState.user,
                                item.id,
                                qty,
                              );
                            }
                          },
                          onRemove: () {
                            final authState = context.read<AuthBloc>().state;
                            if (authState is AuthAuthenticated) {
                              context.read<CartCubit>().remove(
                                authState.user,
                                item.id,
                              );
                            }
                          },
                        );
                      },
                    ),
                  ),
                ),

                // Checkout Section
                _buildCheckoutSection(state.items, state.summary),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              if (widget.onBackPressed != null) {
                widget.onBackPressed!();
              } else {
                // Default behavior - go to home tab
                context.go('/main');
              }
            },
            icon: const Icon(Feather.arrow_left, color: Colors.black),
          ),
          const SizedBox(width: 8),
          const Text(
            'Cart',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () async {
              final authState = context.read<AuthBloc>().state;
              if (authState is AuthAuthenticated) {
                await context.read<CartCubit>().refresh(authState.user);
              }
            },
            icon: const Icon(Feather.refresh_cw, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsCount(int count) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        '$count Items',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildCheckoutSection(List<CartItem> items, CartSummary? summary) {
    final total =
        summary?.total ??
        items.fold<double>(0.0, (sum, item) => sum + item.lineTotal);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Checkout Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                final authState = context.read<AuthBloc>().state;
                if (authState is AuthAuthenticated) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CheckoutScreen(
                        userData: authState.user,
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 0,
              ),
              child: Text(
                'Checkout (₹${total.toStringAsFixed(2)})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Taxes & Shipping text
          Text(
            summary != null
                ? 'Total includes taxes & shipping'
                : 'Taxes & Shipping calculated at checkout.',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Feather.shopping_cart, size: 72, color: AppColors.primary),
            const SizedBox(height: 16),
            Text(
              'Your cart is empty',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Browse products and add items to your cart.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoSearchResults() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Feather.search, size: 72, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No items found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching with different keywords',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                });
              },
              child: const Text('Clear Search'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String? errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Feather.alert_circle, size: 72, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Failed to load cart',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage ?? 'Something went wrong. Please try again.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                final authState = context.read<AuthBloc>().state;
                if (authState is AuthAuthenticated) {
                  context.read<CartCubit>().refresh(authState.user);
                }
              },
              icon: const Icon(Feather.refresh_cw),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItem item;
  final ValueChanged<int> onQtyChanged;
  final VoidCallback onRemove;
  final bool isLoading;

  const _CartItemCard({
    required this.item,
    required this.onQtyChanged,
    required this.onRemove,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Product Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
                image: item.thumbnailUrl != null
                    ? DecorationImage(
                        image: NetworkImage(item.thumbnailUrl!),
                        fit: BoxFit.cover,
                        onError: (exception, stackTrace) {
                          // Handle image loading error
                        },
                      )
                    : null,
              ),
              child: item.thumbnailUrl == null
                  ? Icon(Feather.image, color: Colors.grey[400], size: 32)
                  : null,
            ),

            const SizedBox(width: 16),

            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // Price
                  Text(
                    '₹${item.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Variants (Size, Color, etc.)
                  if (item.variants.isNotEmpty) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: item.variants.map((variant) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            variant.attributeValue ?? '',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black87,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Quantity and Remove controls
                  Row(
                    children: [
                      // Quantity Stepper
                      _QuantityStepper(
                        qty: item.quantity,
                        onChanged: onQtyChanged,
                        isLoading: isLoading,
                      ),

                      const Spacer(),

                      // Remove Button
                      GestureDetector(
                        onTap: isLoading ? null : onRemove,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Icon(
                                  Feather.trash_2,
                                  color: Colors.red[600],
                                  size: 16,
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  final int qty;
  final ValueChanged<int> onChanged;
  final bool isLoading;

  const _QuantityStepper({
    required this.qty,
    required this.onChanged,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Minus Button
        GestureDetector(
          onTap: isLoading || qty <= 1 ? null : () => onChanged(qty - 1),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: qty <= 1 ? Colors.grey[300] : Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Feather.minus,
              size: 16,
              color: qty <= 1 ? Colors.grey[500] : Colors.black87,
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Quantity Display
        Text(
          '$qty',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),

        const SizedBox(width: 12),

        // Plus Button
        GestureDetector(
          onTap: isLoading ? null : () => onChanged(qty + 1),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Feather.plus, size: 16, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
