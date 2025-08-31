import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/services/image_optimization_service.dart';

/// Simple test widget to verify image optimization
class ImageTestWidget extends StatelessWidget {
  final String imageUrl;

  const ImageTestWidget({
    super.key,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final service = ImageOptimizationService();
    final optimizedUrl = service.getOptimizedImageUrl(imageUrl, size: ImageSize.thumbnail);
    
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Original URL
          Container(
            padding: const EdgeInsets.all(8),
            child: Text(
              'Original: ${imageUrl.length > 30 ? '${imageUrl.substring(0, 30)}...' : imageUrl}',
              style: const TextStyle(fontSize: 10),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          // Optimized URL
          Container(
            padding: const EdgeInsets.all(8),
            child: Text(
              'Optimized: ${optimizedUrl.length > 30 ? '${optimizedUrl.substring(0, 30)}...' : optimizedUrl}',
              style: const TextStyle(fontSize: 10),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          // Image display
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: optimizedUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.red.shade100,
                  child: const Center(
                    child: Icon(Icons.error, color: Colors.red),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
