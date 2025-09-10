class AppConfig {
  // App Information
  static const String appName = 'Rikhh E-Commerce';
  static const String appVersion = '1.0.0';

  // Environment Configuration
  static const bool isDevelopment = false; // Set to false for production
  // If true, prefer using LAN IP for development (for physical devices)
  static const bool useLanIpInDev = false;
  // Replace with your machine's LAN IP when useLanIpInDev is true
  static const String devLanIp = '172.31.80.1';

  // API Configuration
  static String get baseUrl {
    if (!isDevelopment) {
      // Production URL
      return 'http://13.201.5.235:3001/api';
    }

    // Development URL selection
    return 'http://$devLanIp:3001/api';
  }

  // Test if the server is reachable
  static String get serverTestUrl {
    if (!isDevelopment) {
      return 'http://13.201.5.235:3001';
    }
    return 'http://$devLanIp:3001';
  }

  static const String apiVersion = 'v1';
  static const int connectionTimeout =
      60000; // 60 seconds (increased for network issues)
  static const int receiveTimeout =
      60000; // 60 seconds (increased for network issues)

  // API Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String refreshTokenEndpoint = '/auth/refresh-token';
  static const String productsEndpoint = '/products';
  static const String categoriesEndpoint = '/categories';
  static const String cartEndpoint = '/cart';
  static const String ordersEndpoint = '/orders';
  static const String profileEndpoint = '/profile';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';
  static const String cartKey = 'cart_data';
  static const String themeKey = 'app_theme';

  // Pagination
  static const int pageSize = 20;

  // Image Configuration
  static const String imageBaseUrl = 'https://your-cdn-domain.com/images';
  static const int imageCacheDuration = 7; // days

  // Payment Configuration
  static const String stripePublishableKey = 'your_stripe_key';

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
}
