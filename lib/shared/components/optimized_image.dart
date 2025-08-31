import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/image_optimization_service.dart';

class OptimizedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final ImageSize size;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool showShimmer;
  final VoidCallback? onTap;

  const OptimizedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.size = ImageSize.thumbnail,
    this.placeholder,
    this.errorWidget,
    this.showShimmer = true,
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

    // Compute cache size based on logical size and device pixel ratio
    final dpr = MediaQuery.of(context).devicePixelRatio;
    final logicalWidth = width ?? size.dimensions.width;
    final logicalHeight = height ?? size.dimensions.height;
    final physical = service.computePhysicalSize(
      logicalWidth: logicalWidth,
      logicalHeight: logicalHeight,
      devicePixelRatio: dpr,
    );

    // Round to ints; guard against zero
    final cacheW = physical.width.isFinite && physical.width > 0
        ? physical.width.clamp(1, 4096).toInt()
        : null;
    final cacheH = physical.height.isFinite && physical.height > 0
        ? physical.height.clamp(1, 4096).toInt()
        : null;

    Widget imageWidget = CachedNetworkImage(
      imageUrl: optimizedUrl,
      width: width,
      height: height,
      fit: fit,
      // Use either placeholder or progressIndicatorBuilder, not both
      placeholder: placeholder != null ? (context, url) => placeholder! : null,
      progressIndicatorBuilder: placeholder == null
          ? (context, url, progress) {
              return Container(
                color: AppColors.divider,
                child: Center(
                  child: CircularProgressIndicator(
                    value: progress.progress,
                    color: AppColors.primary,
                    strokeWidth: 2,
                  ),
                ),
              );
            }
          : null,
      errorWidget: (context, url, error) => errorWidget ?? _buildErrorWidget(),
      memCacheWidth: cacheW,
      memCacheHeight: cacheH,
      httpHeaders: service.getOptimizedHeaders(),
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
        child: Icon(Icons.image, color: AppColors.body, size: 32),
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
        child: Icon(Icons.broken_image, color: AppColors.body, size: 32),
      ),
    );
  }
}

/// Optimized image with lazy loading for lists
class LazyOptimizedImage extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final ImageSize size;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool showShimmer;
  final VoidCallback? onTap;
  final bool isVisible;

  const LazyOptimizedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.size = ImageSize.thumbnail,
    this.placeholder,
    this.errorWidget,
    this.showShimmer = true,
    this.onTap,
    this.isVisible = true,
  });

  @override
  State<LazyOptimizedImage> createState() => _LazyOptimizedImageState();
}

class _LazyOptimizedImageState extends State<LazyOptimizedImage> {
  bool _shouldLoad = false;

  @override
  void initState() {
    super.initState();
    _shouldLoad = widget.isVisible;
  }

  @override
  void didUpdateWidget(LazyOptimizedImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible && !oldWidget.isVisible) {
      setState(() {
        _shouldLoad = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_shouldLoad) {
      return _buildPlaceholder();
    }

    return OptimizedImage(
      imageUrl: widget.imageUrl,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      borderRadius: widget.borderRadius,
      size: widget.size,
      placeholder: widget.placeholder,
      errorWidget: widget.errorWidget,
      showShimmer: widget.showShimmer,
      onTap: widget.onTap,
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: AppColors.divider,
        borderRadius: widget.borderRadius,
      ),
    );
  }
}
