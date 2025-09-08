import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../config/image_config.dart';

/// Global image cache configuration service
class ImageCacheService {
  static final ImageCacheService _instance = ImageCacheService._internal();
  factory ImageCacheService() => _instance;
  ImageCacheService._internal();

  /// Initialize global image cache configuration
  static void initialize() {
    // Configure CachedNetworkImage global settings
    CachedNetworkImage.logLevel = CacheManagerLogLevel.warning;

    // Set up custom cache manager with optimized settings
    _setupCacheManager();
  }

  /// Setup custom cache manager with optimized settings
  static void _setupCacheManager() {
    // This will be handled by the global cache configuration
    // The actual cache manager setup is done in main.dart
  }

  /// Get optimized cache manager configuration
  static Map<String, dynamic> getCacheConfig() {
    return {
      'maxCacheSize': ImageConfig.maxCacheSize,
      'cacheExpiry': ImageConfig.cacheExpiry,
      'enableMemoryOptimization': ImageConfig.enableMemoryOptimization,
      'maxMemoryCacheSize': ImageConfig.maxMemoryCacheSize,
    };
  }

  /// Clear all cached images
  static Future<void> clearCache() async {
    try {
      await DefaultCacheManager().emptyCache();
    } catch (e) {
      debugPrint('Error clearing image cache: $e');
    }
  }

  /// Get cache statistics
  static Future<Map<String, dynamic>> getCacheStats() async {
    try {
      // For now, return basic cache configuration info
      // The actual cache size calculation is complex and platform-specific
      return {
        'cacheSize': 0, // Will be calculated by the cache manager internally
        'cacheFilesCount':
            0, // Will be calculated by the cache manager internally
        'maxCacheSize': ImageConfig.maxCacheSize,
        'cacheUtilization':
            0, // Will be calculated when we have actual cache size
        'cacheEnabled': true,
        'cacheExpiry': ImageConfig.cacheExpiry.inDays,
      };
    } catch (e) {
      return {
        'cacheSize': 0,
        'cacheFilesCount': 0,
        'maxCacheSize': ImageConfig.maxCacheSize,
        'cacheUtilization': 0,
        'cacheEnabled': false,
        'cacheExpiry': 0,
      };
    }
  }
}
