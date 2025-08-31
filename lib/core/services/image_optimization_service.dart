import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../config/image_config.dart';

class ImageOptimizationService {
  // Singleton pattern
  static final ImageOptimizationService _instance =
      ImageOptimizationService._internal();
  factory ImageOptimizationService() => _instance;
  ImageOptimizationService._internal();

  // Cache for preloaded images
  final Map<String, bool> _preloadedImages = {};

  // Performance tracking
  final Map<String, DateTime> _loadStartTimes = {};
  final Map<String, Duration> _loadTimes = {};

  bool _isS3Url(String url) {
    return url.contains('amazonaws.com');
  }

  /// Optimize image URL for different sizes
  String getOptimizedImageUrl(
    String originalUrl, {
    ImageSize size = ImageSize.thumbnail,
  }) {
    if (!originalUrl.startsWith('http')) return originalUrl;

    // Skip param manipulation for S3 URLs; many buckets don't support resizing via query
    if (_isS3Url(originalUrl)) {
      if (ImageConfig.enablePerformanceLogging) {}
      return originalUrl;
    }

    // If the URL already has size parameters, return as is
    if (originalUrl.contains('?') || originalUrl.contains('&')) {
      return originalUrl;
    }

    final dimensions = _getDimensionsForSize(size);
    final params = ImageConfig.getOptimizationParams(
      width: dimensions.width.toInt(),
      height: dimensions.height.toInt(),
      quality: ImageConfig.defaultQuality,
    );

    final optimizedUrl = ImageConfig.buildOptimizedUrl(originalUrl, params);

    return optimizedUrl;
  }

  /// Compute cache size from logical dimensions and device pixel ratio
  Size computePhysicalSize({
    required double? logicalWidth,
    required double? logicalHeight,
    required double devicePixelRatio,
  }) {
    final w =
        (logicalWidth ?? ImageConfig.thumbnailWidth.toDouble()) *
        devicePixelRatio;
    final h =
        (logicalHeight ?? ImageConfig.thumbnailHeight.toDouble()) *
        devicePixelRatio;
    return Size(w, h);
  }

  /// Get dimensions for different image sizes
  Size _getDimensionsForSize(ImageSize size) {
    switch (size) {
      case ImageSize.thumbnail:
        return Size(
          ImageConfig.thumbnailWidth.toDouble(),
          ImageConfig.thumbnailHeight.toDouble(),
        );
      case ImageSize.medium:
        return Size(
          ImageConfig.cardWidth.toDouble(),
          ImageConfig.cardHeight.toDouble(),
        );
      case ImageSize.large:
        return Size(
          ImageConfig.detailWidth.toDouble(),
          ImageConfig.detailHeight.toDouble(),
        );
    }
  }

  /// Preload images for better performance
  Future<void> preloadImages(
    BuildContext context,
    List<String> imageUrls, {
    ImageSize size = ImageSize.thumbnail,
  }) async {
    if (!ImageConfig.enablePreloading) return;

    for (final url in imageUrls) {
      if (url.isNotEmpty && !_preloadedImages.containsKey(url)) {
        try {
          final optimizedUrl = getOptimizedImageUrl(url, size: size);
          await precacheImage(
            CachedNetworkImageProvider(optimizedUrl),
            context,
          );
          _preloadedImages[url] = true;
        } catch (e) {
          // Silently handle preload errors
          _preloadedImages[url] = false;
        }
      }
    }
  }

  /// Preload images for visible items in a list
  Future<void> preloadVisibleImages(
    BuildContext context,
    List<String> imageUrls,
    int startIndex,
    int endIndex, {
    ImageSize size = ImageSize.thumbnail,
  }) async {
    if (!ImageConfig.enablePreloading) return;

    final visibleUrls = imageUrls.sublist(
      startIndex.clamp(0, imageUrls.length),
      endIndex.clamp(0, imageUrls.length),
    );

    // Also preload buffer images ahead
    final bufferEndIndex = (endIndex + ImageConfig.preloadBufferSize).clamp(
      0,
      imageUrls.length,
    );
    final bufferUrls = imageUrls.sublist(
      endIndex.clamp(0, imageUrls.length),
      bufferEndIndex,
    );

    await Future.wait([
      preloadImages(context, visibleUrls, size: size),
      preloadImages(context, bufferUrls, size: size),
    ]);
  }

  /// Start tracking image load time
  void startLoadTracking(String imageUrl) {
    if (ImageConfig.trackImageLoadTimes) {
      _loadStartTimes[imageUrl] = DateTime.now();
    }
  }

  /// End tracking image load time
  void endLoadTracking(String imageUrl) {
    if (ImageConfig.trackImageLoadTimes &&
        _loadStartTimes.containsKey(imageUrl)) {
      final startTime = _loadStartTimes[imageUrl]!;
      final loadTime = DateTime.now().difference(startTime);
      _loadTimes[imageUrl] = loadTime;
      _loadStartTimes.remove(imageUrl);
    }
  }

  /// Get average load time for performance monitoring
  Duration getAverageLoadTime() {
    if (_loadTimes.isEmpty) return Duration.zero;

    final totalMilliseconds = _loadTimes.values
        .map((duration) => duration.inMilliseconds)
        .reduce((a, b) => a + b);

    return Duration(milliseconds: totalMilliseconds ~/ _loadTimes.length);
  }

  /// Clear preloaded images cache
  void clearPreloadedCache() {
    _preloadedImages.clear();
  }

  /// Get memory cache dimensions for CachedNetworkImage
  int getMemoryCacheWidth(ImageSize size) {
    if (!ImageConfig.enableMemoryOptimization) return 0;

    switch (size) {
      case ImageSize.thumbnail:
        return ImageConfig.thumbnailWidth;
      case ImageSize.medium:
        return ImageConfig.cardWidth;
      case ImageSize.large:
        return ImageConfig.detailWidth;
    }
  }

  /// Get memory cache height for CachedNetworkImage
  int getMemoryCacheHeight(ImageSize size) {
    return getMemoryCacheWidth(size);
  }

  /// Get HTTP headers for better image loading
  Map<String, String> getOptimizedHeaders() {
    final headers = <String, String>{'Accept': 'image/webp,image/*,*/*;q=0.8'};

    if (ImageConfig.enableCompression) {
      headers['Accept-Encoding'] = 'gzip, deflate';
    }

    return headers;
  }

  /// Check if image should be lazy loaded
  bool shouldLazyLoad(double visibilityPercentage) {
    return ImageConfig.enableLazyLoading &&
        visibilityPercentage >= ImageConfig.lazyLoadingThreshold;
  }

  /// Get performance statistics
  Map<String, dynamic> getPerformanceStats() {
    return {
      'preloadedImagesCount': _preloadedImages.length,
      'averageLoadTime': getAverageLoadTime().inMilliseconds,
      'totalLoadTimes': _loadTimes.length,
      'cacheHitRate': _getCacheHitRate(),
    };
  }

  /// Calculate cache hit rate
  double _getCacheHitRate() {
    if (_preloadedImages.isEmpty) return 0.0;
    final hits = _preloadedImages.values.where((loaded) => loaded).length;
    return hits / _preloadedImages.length;
  }
}

/// Enum for different image sizes
enum ImageSize { thumbnail, medium, large }

/// Extension to get size from enum
extension ImageSizeExtension on ImageSize {
  Size get dimensions {
    switch (this) {
      case ImageSize.thumbnail:
        return Size(
          ImageConfig.thumbnailWidth.toDouble(),
          ImageConfig.thumbnailHeight.toDouble(),
        );
      case ImageSize.medium:
        return Size(
          ImageConfig.cardWidth.toDouble(),
          ImageConfig.cardHeight.toDouble(),
        );
      case ImageSize.large:
        return Size(
          ImageConfig.detailWidth.toDouble(),
          ImageConfig.detailHeight.toDouble(),
        );
    }
  }
}
