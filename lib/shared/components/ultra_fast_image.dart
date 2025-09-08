import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/image_optimization_service.dart';

/// Ultra-fast image loading widget with blur placeholders and aggressive optimizations
class UltraFastImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final ImageSize size;
  final Widget? placeholder;
  final Widget? errorWidget;
  final VoidCallback? onTap;

  const UltraFastImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.size = ImageSize.thumbnail,
    this.placeholder,
    this.errorWidget,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return _buildPlaceholder();
    }

    if (!imageUrl.startsWith('http')) {
      return _buildAssetImage();
    }

    return _buildNetworkImage(context);
  }

  Widget _buildNetworkImage(BuildContext context) {
    final service = ImageOptimizationService();
    final optimizedUrl = service.getOptimizedImageUrl(imageUrl, size: size);

    // Ultra-aggressive memory cache sizing
    final dpr = MediaQuery.of(context).devicePixelRatio;
    final logicalWidth = width ?? size.dimensions.width;
    final logicalHeight = height ?? size.dimensions.height;
    final physical = service.computePhysicalSize(
      logicalWidth: logicalWidth,
      logicalHeight: logicalHeight,
      devicePixelRatio: dpr,
    );

    // Very small cache dimensions for ultra-fast loading
    final cacheW = physical.width.isFinite && physical.width > 0
        ? (physical.width * 0.5).clamp(50, 1024).toInt() // 50% of calculated size
        : null;
    final cacheH = physical.height.isFinite && physical.height > 0
        ? (physical.height * 0.5).clamp(50, 1024).toInt() // 50% of calculated size
        : null;

    Widget imageWidget = CachedNetworkImage(
      imageUrl: optimizedUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: placeholder != null ? (context, url) => placeholder! : null,
      progressIndicatorBuilder: placeholder == null
          ? (context, url, progress) => _buildBlurPlaceholder()
          : null,
      errorWidget: (context, url, error) => errorWidget ?? _buildErrorWidget(),
      memCacheWidth: cacheW,
      memCacheHeight: cacheH,
      httpHeaders: _getUltraFastHeaders(),
      cacheManager: DefaultCacheManager(),
      fadeInDuration: const Duration(milliseconds: 100), // Very fast fade
      fadeOutDuration: const Duration(milliseconds: 50), // Very fast fade
    );

    // Apply border radius if specified
    if (borderRadius != null) {
      imageWidget = ClipRRect(borderRadius: borderRadius!, child: imageWidget);
    }

    // Wrap with GestureDetector if onTap is provided
    if (onTap != null) {
      imageWidget = GestureDetector(onTap: onTap, child: imageWidget);
    }

    return imageWidget;
  }

  Widget _buildBlurPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.divider,
        borderRadius: borderRadius,
      ),
      child: Stack(
        children: [
          // Blur effect background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.divider.withValues(alpha: 0.3),
                  AppColors.divider.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: borderRadius,
            ),
          ),
          // Loading indicator
          Center(
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetImage() {
    Widget imageWidget = Image.asset(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) =>
          errorWidget ?? _buildErrorWidget(),
    );

    if (borderRadius != null) {
      imageWidget = ClipRRect(borderRadius: borderRadius!, child: imageWidget);
    }

    if (onTap != null) {
      imageWidget = GestureDetector(onTap: onTap, child: imageWidget);
    }

    return imageWidget;
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.divider,
        borderRadius: borderRadius,
      ),
      child: const Center(
        child: Icon(Icons.image, color: AppColors.body, size: 20),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.divider,
        borderRadius: borderRadius,
      ),
      child: const Center(
        child: Icon(Icons.broken_image, color: AppColors.body, size: 20),
      ),
    );
  }

  /// Ultra-optimized headers for fastest loading
  Map<String, String> _getUltraFastHeaders() {
    return {
      'Accept': 'image/webp,image/avif,image/*,*/*;q=0.8',
      'Accept-Encoding': 'gzip, deflate, br',
      'Cache-Control': 'max-age=31536000', // 1 year cache
      'Connection': 'keep-alive',
    };
  }
}
