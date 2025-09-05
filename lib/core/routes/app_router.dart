import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/home/screens/search_screen.dart';
import '../navigation/startup_screen.dart';
import '../navigation/main_navigation.dart';
import '../../features/auth/screens/main_auth_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/cart/screens/cart_screen.dart';

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
  static const String profile = '/profile';
  static const String search = '/search';
  static const String categories = '/categories';
  static const String wishlist = '/wishlist';

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
        builder: (context, state) => const MainNavigation(),
        routes: [
          // Home Screen
          GoRoute(
            path: home,
            name: 'home',
            builder: (context, state) => const HomeScreen(),
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
        builder: (context, state) => const Scaffold(
          body: Center(
            child: Text('Products Screen - Coming Soon'),
          ),
        ),
      ),
      
      GoRoute(
        path: productDetail,
        name: 'productDetail',
        builder: (context, state) {
          final productId = state.pathParameters['id'];
          return Scaffold(
            body: Center(
              child: Text('Product Detail Screen - ID: $productId'),
            ),
          );
        },
      ),
      
      // Cart Routes
      GoRoute(
        path: cart,
        name: 'cart',
        builder: (context, state) => CartScreen(
          onBackPressed: () => context.go('/main'),
        ),
      ),
      
      GoRoute(
        path: checkout,
        name: 'checkout',
        builder: (context, state) => const Scaffold(
          body: Center(
            child: Text('Checkout Screen - Coming Soon'),
          ),
        ),
      ),
      
      // Order Routes
      GoRoute(
        path: orders,
        name: 'orders',
        builder: (context, state) => const Scaffold(
          body: Center(
            child: Text('Orders Screen - Coming Soon'),
          ),
        ),
      ),
      
      GoRoute(
        path: orderDetail,
        name: 'orderDetail',
        builder: (context, state) {
          final orderId = state.pathParameters['id'];
          return Scaffold(
            body: Center(
              child: Text('Order Detail Screen - ID: $orderId'),
            ),
          );
        },
      ),
      
      // Profile Routes
      GoRoute(
        path: profile,
        name: 'profile',
        builder: (context, state) => const Scaffold(
          body: Center(
            child: Text('Profile Screen - Coming Soon'),
          ),
        ),
      ),
      
      // Category Routes
      GoRoute(
        path: categories,
        name: 'categories',
        builder: (context, state) => const Scaffold(
          body: Center(
            child: Text('Categories Screen - Coming Soon'),
          ),
        ),
      ),
      
      // Wishlist Routes
      GoRoute(
        path: wishlist,
        name: 'wishlist',
        builder: (context, state) => const Scaffold(
          body: Center(
            child: Text('Wishlist Screen - Coming Soon'),
          ),
        ),
      ),
    ],
    
    // Error handling
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
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
