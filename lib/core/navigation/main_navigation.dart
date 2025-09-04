import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/products/screens/categories_screen.dart';
import '../../features/cart/screens/cart_screen.dart';
import '../../features/cart/bloc/cart_cubit.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/orders/screens/orders_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../theme/app_colors.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const CategoriesScreen(),
    const CartScreen(),
    const OrdersScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Load cart data when navigation initializes (only if user is authenticated)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Check if user is authenticated before loading cart
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        print('🔍 MainNavigation: User is authenticated, loading cart...');
        context.read<CartCubit>().load();
      } else {
        print('🔍 MainNavigation: User is not authenticated, skipping cart load');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        print('🔍 MainNavigation: Auth state changed to: ${state.runtimeType}');
        // Load cart when user becomes authenticated
        if (state is AuthAuthenticated) {
          print('🔍 MainNavigation: User authenticated, loading cart...');
          context.read<CartCubit>().load();
        } else if (state is AuthUnauthenticated) {
          print('🔍 MainNavigation: User unauthenticated, clearing cart...');
          // Clear cart when user logs out
          context.read<CartCubit>().clear();
        }
      },
      child: Scaffold(
        body: IndexedStack(index: _currentIndex, children: _screens),
        bottomNavigationBar: _buildBottomNavigation(),
      ),
    );
  }

  Widget _buildBottomNavigation() {
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
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
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
            icon: BlocBuilder<CartCubit, CartState>(
              builder: (context, state) {
                final itemCount = state.summary?.itemsCount ?? 0;
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
}
