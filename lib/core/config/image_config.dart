class ImageConfig {
  // Image quality settings - Balanced fast loading
  static const int defaultQuality = 70; // Good balance of speed and quality
  static const int highQuality = 80; // Good quality for detail images
  static const int lowQuality = 60; // Decent quality for thumbnails

  // Image dimensions for different use cases - Balanced performance
  static const int thumbnailWidth = 150; // Good size for thumbnails
  static const int thumbnailHeight = 150; // Good size for thumbnails

  static const int cardWidth = 200; // Good size for product cards
  static const int cardHeight = 200; // Good size for product cards

  static const int detailWidth = 400; // Good size for detail images
  static const int detailHeight = 400; // Good size for detail images

  // Cache settings - Balanced performance
  static const int maxCacheSize = 50 * 1024 * 1024; // 50MB - Good balance
  static const Duration cacheExpiry = Duration(
    days: 3,
  ); // Good balance for fresh content

  // Preload settings
  static const int preloadBufferSize = 3; // Balanced setting
  static const bool enablePreloading =
      true; // Re-enabled with better performance

  // Network optimization - Balanced fast loading
  static const bool enableWebP = true;
  static const bool enableCompression = true;
  static const Duration connectionTimeout = Duration(
    seconds: 5,
  ); // Good balance

  // Placeholder settings
  static const bool enableShimmer = true;
  static const Duration shimmerDuration = Duration(milliseconds: 1500);

  // Error handling
  static const bool showErrorWidgets = true;
  static const bool retryOnError = true;
  static const int maxRetryAttempts = 3;

  // Performance monitoring
  static const bool enablePerformanceLogging = true; // Re-enabled
  static const bool trackImageLoadTimes = true; // Re-enabled

  // CDN and optimization service settings
  static const String imageOptimizationService =
      'auto'; // 'auto', 'cloudinary', 'imgix', 'custom'
  static const Map<String, String> customOptimizationParams = {
    'fit': 'crop',
    'auto': 'format',
    'dpr': '2', // Device pixel ratio
  };

  // Lazy loading settings
  static const bool enableLazyLoading = true;
  static const double lazyLoadingThreshold =
      0.1; // Start loading when 10% visible

  // Memory management - Balanced performance
  static const bool enableMemoryOptimization = true;
  static const int maxMemoryCacheSize = 25 * 1024 * 1024; // 25MB - Good balance

  // Get optimized URL parameters based on size
  static Map<String, String> getOptimizationParams({
    required int width,
    required int height,
    int quality = defaultQuality,
    String fit = 'crop',
    bool autoFormat = true,
  }) {
    final params = <String, String>{
      'w': width.toString(),
      'h': height.toString(),
      'q': quality.toString(),
      'fit': fit,
    };

    if (autoFormat) {
      params['auto'] = 'format';
    }

    if (enableWebP) {
      params['f'] = 'webp';
    }

    // Add custom parameters
    params.addAll(customOptimizationParams);

    return params;
  }

  // Build optimization URL
  static String buildOptimizedUrl(String baseUrl, Map<String, String> params) {
    if (baseUrl.isEmpty) return baseUrl;

    final separator = baseUrl.contains('?') ? '&' : '?';
    final queryString = params.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');

    return '$baseUrl$separator$queryString';
  }
}
