import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/app_logger.dart';
import '../../core/theme/app_colors.dart';
import '../../features/cart/bloc/cart_cubit.dart';

class CheckoutScaffold extends StatelessWidget {
  final Widget body;
  final String title;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const CheckoutScaffold({
    super.key,
    required this.body,
    required this.title,
    this.showBackButton = true,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
              )
            : null,
        automaticallyImplyLeading: showBackButton,
      ),
      body: body,
      bottomNavigationBar: _buildBottomNavigation(context),
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    return Container(
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
      child: BottomNavigationBar(
        currentIndex: 2, // Cart is at index 2
        onTap: (index) => _handleNavigation(context, index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.body,
        elevation: 0,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Feather.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Feather.grid),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: BlocConsumer<CartCubit, CartState>(
              listener: (context, state) {
                AppLogger.checkout(
                  '🛒 CheckoutScaffold: Cart state changed - status: ${state.status}, itemCount: ${state.summary?.itemsCount ?? state.items.fold<int>(0, (sum, item) => sum + item.quantity)}',
                );
              },
              builder: (context, state) {
                final itemCount =
                    state.summary?.itemsCount ??
                    state.items.fold<int>(
                      0,
                      (sum, item) => sum + item.quantity,
                    );
                AppLogger.checkout(
                  '🛒 CheckoutScaffold: BlocBuilder rebuilding - itemCount: $itemCount, status: ${state.status}',
                );
                return Stack(
                  children: [
                    const Icon(Feather.shopping_bag),
                    if (itemCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            itemCount > 99 ? '99+' : itemCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            label: 'Cart',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Feather.package),
            label: 'Orders',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Feather.user),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  void _handleNavigation(BuildContext context, int index) {
    switch (index) {
      case 0: // Home
        context.go('/main?tab=0');
        break;
      case 1: // Categories
        context.go('/categories');
        break;
      case 2: // Cart
        context.go('/cart');
        break;
      case 3: // Orders
        context.go('/orders');
        break;
      case 4: // Profile
        context.go('/profile');
        break;
    }
  }
}
