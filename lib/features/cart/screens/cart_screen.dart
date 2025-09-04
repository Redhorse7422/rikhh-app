import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../bloc/cart_cubit.dart';
import '../models/cart_models.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CartCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: BlocBuilder<CartCubit, CartState>(
          builder: (context, state) {
            if (state.status == CartStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.items.isEmpty) {
              return _buildEmptyCart();
            }

            return Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = state.items[index];
                      return _CartItemTile(
                        item: item,
                        onQtyChanged: (qty) => context.read<CartCubit>().updateQuantity(item.id, qty),
                        onRemove: () => context.read<CartCubit>().remove(item.id),
                      );
                    },
                  ),
                ),
                _CartSummaryBar(summary: state.summary),
              ],
            );
          },
        ),
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
}

class _CartItemTile extends StatelessWidget {
  final CartItem item;
  final ValueChanged<int> onQtyChanged;
  final VoidCallback onRemove;

  const _CartItemTile({required this.item, required this.onQtyChanged, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(8),
                image: item.thumbnailUrl != null
                    ? DecorationImage(image: NetworkImage(item.thumbnailUrl!), fit: BoxFit.cover)
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: Theme.of(context).textTheme.titleMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
                  if (item.variants.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: item.variants
                          .map((v) => Chip(label: Text(v.attributeValue ?? ''), visualDensity: VisualDensity.compact))
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text('₹${item.price.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleMedium),
                      const Spacer(),
                      _QtyStepper(qty: item.quantity, onChanged: onQtyChanged),
                      IconButton(onPressed: onRemove, icon: const Icon(Feather.trash))
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _QtyStepper extends StatelessWidget {
  final int qty;
  final ValueChanged<int> onChanged;

  const _QtyStepper({required this.qty, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: qty > 1 ? () => onChanged(qty - 1) : null,
          icon: const Icon(Feather.minus),
        ),
        Text('$qty'),
        IconButton(
          onPressed: () => onChanged(qty + 1),
          icon: const Icon(Feather.plus),
        ),
      ],
    );
  }
}

class _CartSummaryBar extends StatelessWidget {
  final CartSummary? summary;
  const _CartSummaryBar({required this.summary});

  @override
  Widget build(BuildContext context) {
    final subtotal = summary?.subtotal ?? 0;
    final total = summary?.total ?? subtotal;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Subtotal: ₹${subtotal.toStringAsFixed(2)}', style: Theme.of(context).textTheme.bodyMedium),
                Text('Total: ₹${total.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            child: const Text('Checkout'),
          )
        ],
      ),
    );
  }
}
