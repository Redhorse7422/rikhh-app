import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:go_router/go_router.dart';
import '../bloc/orders_bloc.dart';
import '../widgets/order_card.dart';
import '../widgets/order_filter_tabs.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/bloc/auth_bloc.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with WidgetsBindingObserver {
  bool _hasLoadedOrders = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Check if user is already authenticated and load orders if so
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final authState = context.read<AuthBloc>().state;
        if (authState is AuthAuthenticated && !_hasLoadedOrders) {
          _loadOrdersWithRetry();
        }
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Refresh orders when app becomes active (user returns from order confirmation)
    if (state == AppLifecycleState.resumed && mounted) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        _refreshOrders();
      }
    }
  }

  void _loadOrdersWithRetry() {
    if (!_hasLoadedOrders) {
      _hasLoadedOrders = true;
      context.read<OrdersBloc>().add(const LoadOrders(page: 1, limit: 10));
    }
  }

  void _refreshOrders() {
    // Always refresh orders when called (e.g., when returning from order confirmation)
    context.read<OrdersBloc>().add(const RefreshOrders(page: 1, limit: 10));
  }

  Future<void> _waitForRefreshComplete() async {
    final completer = Completer<void>();
    late StreamSubscription subscription;

    subscription = context.read<OrdersBloc>().stream.listen((state) {
      if (state is OrdersLoaded || state is OrdersError) {
        subscription.cancel();
        if (!completer.isCompleted) {
          completer.complete();
        }
      }
    });

    // Timeout after 10 seconds
    Timer(const Duration(seconds: 10), () {
      if (!completer.isCompleted) {
        subscription.cancel();
        completer.complete();
      }
    });

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, authState) {
        // Load orders when user is authenticated and we haven't loaded them yet
        if (authState is AuthAuthenticated && !_hasLoadedOrders) {
          _loadOrdersWithRetry();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: const Icon(
                        Feather.arrow_left,
                        size: 24,
                        color: AppColors.heading,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Orders',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.heading,
                      ),
                    ),
                    const Spacer(),
                    // Debug button
                    IconButton(
                      onPressed: () {
                        _loadOrdersWithRetry();
                      },
                      icon: const Icon(
                        Feather.refresh_cw,
                        color: AppColors.primary,
                      ),
                    ),
                    // Test button to force refresh
                    IconButton(
                      onPressed: () {
                        context.read<OrdersBloc>().add(
                          const RefreshOrders(page: 1, limit: 10),
                        );
                      },
                      icon: const Icon(Feather.rotate_cw, color: Colors.orange),
                    ),
                    // Test button to check all pages
                    IconButton(
                      onPressed: () async {
                        // Try to load more pages to see if the new order is there
                        for (int page = 1; page <= 3; page++) {
                          context.read<OrdersBloc>().add(
                            RefreshOrders(page: page, limit: 10),
                          );
                          await Future.delayed(const Duration(seconds: 1));
                        }
                      },
                      icon: const Icon(Feather.search, color: Colors.blue),
                    ),
                  ],
                ),
              ),

              // Filter Tabs
              BlocBuilder<OrdersBloc, OrdersState>(
                builder: (context, state) {
                  if (state is OrdersLoaded) {
                    return OrderFilterTabs(
                      currentFilter: state.currentFilter,
                      onFilterChanged: (filter) {
                        context.read<OrdersBloc>().add(FilterOrders(filter));
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              const SizedBox(height: 8),

              // Orders List
              Expanded(
                child: BlocConsumer<OrdersBloc, OrdersState>(
                  listener: (context, state) {
                    // Handle any state changes that need UI updates
                    if (state is OrdersError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: AppColors.error,
                          action: SnackBarAction(
                            label: 'Retry',
                            textColor: AppColors.white,
                            onPressed: _loadOrdersWithRetry,
                          ),
                        ),
                      );
                    } else if (state is OrdersLoaded) {}
                  },
                  builder: (context, state) {
                    if (state is OrdersLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
                    }

                    if (state is OrdersError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Feather.alert_circle,
                              size: 64,
                              color: AppColors.error,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Error',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.heading,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              state.message,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.body,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _loadOrdersWithRetry,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.white,
                              ),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }

                    if (state is OrdersLoaded) {
                      final filteredOrders = state.filteredOrders;

                      if (filteredOrders.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Feather.file_text,
                                size: 64,
                                color: AppColors.body,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No Orders Found',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.heading,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'You haven\'t placed any orders yet.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.body,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: () async {
                          context.read<OrdersBloc>().add(RefreshOrders());
                          // Wait for the refresh to complete by listening to state changes
                          await _waitForRefreshComplete();
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredOrders.length,
                          itemBuilder: (context, index) {
                            final order = filteredOrders[index];
                            return OrderCard(
                              order: order,
                              onViewDetails: () {
                                // Navigate to order detail screen
                                context.push('/order/${order.id}');
                              },
                            );
                          },
                        ),
                      );
                    }

                    // Fallback for initial state - show loading
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
