import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/image_optimization_service.dart';

/// Fast image loading widget with optimized performance
class FastImage extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final ImageSize size;
  final Widget? placeholder;
  final Widget? errorWidget;
  final VoidCallback? onTap;

  const FastImage({
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
  State<FastImage> createState() => _FastImageState();
}

class _FastImageState extends State<FastImage> {

  @override
  void initState() {
    super.initState();
    // Let CachedNetworkImage handle loading directly
  }


  @override
  Widget build(BuildContext context) {
    if (widget.imageUrl.isEmpty) {
      return _buildPlaceholder();
    }

    if (!widget.imageUrl.startsWith('http')) {
      return _buildAssetImage();
    }

    return _buildNetworkImage(context);
  }

  Widget _buildNetworkImage(BuildContext context) {
    final service = ImageOptimizationService();
    final optimizedUrl = service.getOptimizedImageUrl(widget.imageUrl, size: widget.size);

    // Compute cache size based on logical size and device pixel ratio
    final dpr = MediaQuery.of(context).devicePixelRatio;
    final logicalWidth = widget.width ?? widget.size.dimensions.width;
    final logicalHeight = widget.height ?? widget.size.dimensions.height;
    final physical = service.computePhysicalSize(
      logicalWidth: logicalWidth,
      logicalHeight: logicalHeight,
      devicePixelRatio: dpr,
    );

    // Round to ints; guard against zero
    final cacheW = physical.width.isFinite && physical.width > 0
        ? physical.width.clamp(1, 2048).toInt() // Reduced max size for better performance
        : null;
    final cacheH = physical.height.isFinite && physical.height > 0
        ? physical.height.clamp(1, 2048).toInt() // Reduced max size for better performance
        : null;

    Widget imageWidget = CachedNetworkImage(
      imageUrl: optimizedUrl,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      placeholder: widget.placeholder != null ? (context, url) => widget.placeholder! : null,
      progressIndicatorBuilder: widget.placeholder == null
          ? (context, url, progress) {
              return Container(
                color: AppColors.divider,
                child: Center(
                  child: CircularProgressIndicator(
                    value: progress.progress,
                    color: AppColors.primary,
                    strokeWidth: 1.5,
                  ),
                ),
              );
            }
          : null,
      errorWidget: (context, url, error) => _buildErrorWidget(),
      memCacheWidth: cacheW,
      memCacheHeight: cacheH,
      httpHeaders: service.getOptimizedHeaders(),
      cacheManager: DefaultCacheManager(),
      fadeInDuration: const Duration(milliseconds: 150), // Faster fade in
      fadeOutDuration: const Duration(milliseconds: 50), // Faster fade out
    );

    // Apply border radius if specified
    if (widget.borderRadius != null) {
      imageWidget = ClipRRect(borderRadius: widget.borderRadius!, child: imageWidget);
    }

    // Wrap with GestureDetector if onTap is provided
    if (widget.onTap != null) {
      imageWidget = GestureDetector(onTap: widget.onTap, child: imageWidget);
    }

    return imageWidget;
  }

  Widget _buildAssetImage() {
    Widget imageWidget = Image.asset(
      widget.imageUrl,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
    );

    if (widget.borderRadius != null) {
      imageWidget = ClipRRect(borderRadius: widget.borderRadius!, child: imageWidget);
    }

    if (widget.onTap != null) {
      imageWidget = GestureDetector(onTap: widget.onTap, child: imageWidget);
    }

    return imageWidget;
  }


  Widget _buildPlaceholder() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: AppColors.divider,
        borderRadius: widget.borderRadius,
      ),
      child: const Center(
        child: Icon(Icons.image, color: AppColors.body, size: 24),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: AppColors.divider,
        borderRadius: widget.borderRadius,
      ),
      child: const Center(
        child: Icon(Icons.broken_image, color: AppColors.body, size: 24),
      ),
    );
  }
}
