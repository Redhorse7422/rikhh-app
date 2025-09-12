import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/products/screens/categories_screen.dart';
import '../../features/cart/screens/cart_screen.dart';
import '../../features/cart/bloc/cart_cubit.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/orders/screens/orders_screen.dart';
import '../../features/orders/bloc/orders_bloc.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../theme/app_colors.dart';

class MainNavigation extends StatefulWidget {
  final int initialIndex;
  
  const MainNavigation({super.key, this.initialIndex = 0});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late int _currentIndex;
  
  // Cache screens to prevent recreation
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    
    // Initialize all screens once to prevent recreation
    _screens = [
      const HomeScreen(),
      const CategoriesScreen(),
      CartScreen(
        onBackPressed: () {
          setState(() {
            _currentIndex = 0; // Go back to home
          });
        },
      ),
      BlocProvider(
        create: (context) => OrdersBloc(),
        child: const OrdersScreen(),
      ),
      const ProfileScreen(),
    ];

    // Defer cart loading to avoid blocking main thread
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          final authState = context.read<AuthBloc>().state;
          if (authState is AuthAuthenticated) {
            context.read<CartCubit>().load(authState.user);
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.read<CartCubit>().load(state.user);
        } else if (state is AuthUnauthenticated) {
          context.read<CartCubit>().reset();
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: _buildBottomNavigation(), // Show bottom nav on all screens including cart
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
                // Use summary itemsCount if available, otherwise calculate from items
                final itemCount =
                    state.summary?.itemsCount ??
                    state.items.fold<int>(
                      0,
                      (sum, item) => sum + item.quantity,
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
}
