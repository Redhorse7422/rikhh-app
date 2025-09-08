import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'ultra_fast_image.dart';
import '../../core/services/image_optimization_service.dart';
import '../../core/theme/app_colors.dart';

/// Ultra-fast image with aggressive preloading
class UltraFastImageWithPreload extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final ImageSize size;
  final Widget? placeholder;
  final Widget? errorWidget;
  final VoidCallback? onTap;

  const UltraFastImageWithPreload({
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
  State<UltraFastImageWithPreload> createState() => _UltraFastImageWithPreloadState();
}

class _UltraFastImageWithPreloadState extends State<UltraFastImageWithPreload> {
  bool _isPreloaded = false;

  @override
  void initState() {
    super.initState();
    _preloadImage();
  }

  Future<void> _preloadImage() async {
    if (widget.imageUrl.isEmpty || !widget.imageUrl.startsWith('http')) {
      setState(() {
        _isPreloaded = true;
      });
      return;
    }

    try {
      final service = ImageOptimizationService();
      final optimizedUrl = service.getOptimizedImageUrl(widget.imageUrl, size: widget.size);
      
      // Preload with very small cache size for instant loading
      await precacheImage(
        CachedNetworkImageProvider(optimizedUrl),
        context,
      );
      
      if (mounted) {
        setState(() {
          _isPreloaded = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isPreloaded = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isPreloaded) {
      return _buildLoadingPlaceholder();
    }

    return UltraFastImage(
      imageUrl: widget.imageUrl,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      borderRadius: widget.borderRadius,
      size: widget.size,
      placeholder: widget.placeholder,
      errorWidget: widget.errorWidget,
      onTap: widget.onTap,
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: AppColors.divider,
        borderRadius: widget.borderRadius,
      ),
      child: const Center(
        child: SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 1,
          ),
        ),
      ),
    );
  }
}
