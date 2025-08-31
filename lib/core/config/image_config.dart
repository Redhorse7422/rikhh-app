class ImageConfig {
  // Image quality settings
  static const int defaultQuality = 95;
  static const int highQuality = 98;
  static const int lowQuality = 80;

  // Image dimensions for different use cases
  static const int thumbnailWidth = 300;
  static const int thumbnailHeight = 300;

  static const int cardWidth = 400;
  static const int cardHeight = 400;

  static const int detailWidth = 900;
  static const int detailHeight = 900;

  // Cache settings
  static const int maxCacheSize = 100 * 1024 * 1024; // 100MB
  static const Duration cacheExpiry = Duration(days: 7);

  // Preload settings
  static const int preloadBufferSize = 5; // Number of images to preload ahead
  static const bool enablePreloading = true;

  // Network optimization
  static const bool enableWebP = true;
  static const bool enableCompression = true;
  static const Duration connectionTimeout = Duration(seconds: 10);

  // Placeholder settings
  static const bool enableShimmer = true;
  static const Duration shimmerDuration = Duration(milliseconds: 1500);

  // Error handling
  static const bool showErrorWidgets = true;
  static const bool retryOnError = true;
  static const int maxRetryAttempts = 3;

  // Performance monitoring
  static const bool enablePerformanceLogging = true;
  static const bool trackImageLoadTimes = true;

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

  // Memory management
  static const bool enableMemoryOptimization = true;
  static const int maxMemoryCacheSize = 50 * 1024 * 1024; // 50MB

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
