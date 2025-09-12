import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rikhh_app/features/products/models/product_model.dart';
import '../../features/home/screens/search_screen.dart';
import '../navigation/startup_screen.dart';
import '../navigation/main_navigation.dart';
import '../../features/auth/screens/main_auth_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/products/screens/products_screen.dart';
import '../../features/products/screens/product_detail_screen.dart';
import '../../features/checkout/screens/checkout_screen.dart';
import '../../features/orders/screens/order_detail_screen.dart';

class AppRouter {
  static const String startup = '/';
  static const String main = '/main';
  static const String home = '/home';
  static const String login = '/login';
  static const String register = '/register';
  static const String products = '/products';
  static const String productDetail = '/product/:id';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orders = '/orders';
  static const String orderDetail = '/order/:id';
  static const String orderConfirmation = '/order-confirmation';
  static const String profile = '/profile';
  static const String search = '/search';
  static const String categories = '/categories';
  static const String wishlist = '/wishlist';
  static const String imageDebug = '/debug/images';

  static GoRouter get router => GoRouter(
    initialLocation: startup,
    debugLogDiagnostics: true,
    routes: [
      // Startup Screen
      GoRoute(
        path: startup,
        name: 'startup',
        builder: (context, state) => const StartupScreen(),
      ),

      // Main Navigation (with nested routes)
      GoRoute(
        path: main,
        name: 'main',
        builder: (context, state) {
          // Get initial tab from query parameters
          final tabIndex =
              int.tryParse(state.uri.queryParameters['tab'] ?? '0') ?? 0;
          return MainNavigation(initialIndex: tabIndex);
        },
        routes: [
          // Home Screen
          GoRoute(
            path: home,
            name: 'home',
            builder: (context, state) {
              final tabIndex =
                  int.tryParse(state.uri.queryParameters['tab'] ?? '0') ?? 0;
              return MainNavigation(initialIndex: tabIndex);
            },
          ),

          // Search Routes
          GoRoute(
            path: search,
            name: 'search',
            builder: (context, state) => const SearchScreen(),
          ),
        ],
      ),

      // Authentication Routes
      GoRoute(
        path: '/auth-main',
        name: 'auth-main',
        builder: (context, state) => const MainAuthScreen(),
      ),

      GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      GoRoute(
        path: register,
        name: 'register',
        builder: (context, state) => const SignupScreen(),
      ),

      // Product Routes
      GoRoute(
        path: products,
        name: 'products',
        builder: (context, state) => const ProductsScreen(),
      ),

      GoRoute(
        path: productDetail,
        name: 'productDetail',
        builder: (context, state) {
          final product = state.pathParameters['product'] as Product;
          return ProductDetailScreen(product: product);
        },
      ),

      // Cart Routes
      GoRoute(
        path: cart,
        name: 'cart',
        builder: (context, state) =>
            const MainNavigation(initialIndex: 2), // Cart tab
      ),

      GoRoute(
        path: checkout,
        name: 'checkout',
        builder: (context, state) {
          // Get user data from query parameters or use default
          final userData = state.uri.queryParameters['userData'] != null
              ? Map<String, dynamic>.from(
                  Uri.splitQueryString(state.uri.queryParameters['userData']!),
                )
              : <String, dynamic>{};
          return CheckoutScreen(userData: userData);
        },
      ),

      // Order Routes
      GoRoute(
        path: orders,
        name: 'orders',
        builder: (context, state) =>
            const MainNavigation(initialIndex: 3), // Orders tab
      ),

      GoRoute(
        path: orderDetail,
        name: 'orderDetail',
        builder: (context, state) {
          final orderId = state.pathParameters['id'];
          return OrderDetailScreen(orderId: orderId!);
        },
      ),

      // Order Confirmation Route
      GoRoute(
        path: orderConfirmation,
        name: 'orderConfirmation',
        builder: (context, state) {
          // Get order data from query parameters
          final orderData = state.uri.queryParameters['orderData'];
          if (orderData != null) {
            // Parse order data and create OrderConfirmationScreen
            // For now, create a placeholder order
            return const Scaffold(
              body: Center(
                child: Text('Order Confirmation - Order data parsing needed'),
              ),
            );
          }
          return const Scaffold(
            body: Center(child: Text('Order Confirmation - No order data')),
          );
        },
      ),

      // Profile Routes
      GoRoute(
        path: profile,
        name: 'profile',
        builder: (context, state) =>
            const MainNavigation(initialIndex: 4), // Profile tab
      ),

      // Category Routes
      GoRoute(
        path: categories,
        name: 'categories',
        builder: (context, state) =>
            const MainNavigation(initialIndex: 1), // Categories tab
      ),

      // Wishlist Routes
      GoRoute(
        path: wishlist,
        name: 'wishlist',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Wishlist Screen - Coming Soon')),
        ),
      ),
    ],

    // Error handling
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page Not Found',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'The page you are looking for does not exist.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(main + home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}
