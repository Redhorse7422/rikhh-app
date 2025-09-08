import 'package:flutter/material.dart';
import '../../core/services/image_optimization_service.dart';
import '../../core/services/image_cache_service.dart';

/// Widget to monitor and display image loading performance
class ImagePerformanceMonitor extends StatefulWidget {
  final Widget child;
  final bool showStats;

  const ImagePerformanceMonitor({
    super.key,
    required this.child,
    this.showStats = false,
  });

  @override
  State<ImagePerformanceMonitor> createState() => _ImagePerformanceMonitorState();
}

class _ImagePerformanceMonitorState extends State<ImagePerformanceMonitor> {
  Map<String, dynamic> _performanceStats = {};
  Map<String, dynamic> _cacheStats = {};

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final imageService = ImageOptimizationService();
    final performanceStats = imageService.getPerformanceStats();
    final cacheStats = await ImageCacheService.getCacheStats();

    if (mounted) {
      setState(() {
        _performanceStats = performanceStats;
        _cacheStats = cacheStats;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.showStats) _buildStatsOverlay(),
      ],
    );
  }

  Widget _buildStatsOverlay() {
    return Positioned(
      top: 50,
      right: 10,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Image Performance',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Avg Load Time: ${_performanceStats['averageLoadTime'] ?? 0}ms',
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
            Text(
              'Cache Hit Rate: ${((_performanceStats['cacheHitRate'] ?? 0) * 100).toStringAsFixed(1)}%',
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
            Text(
              'Cache Size: ${(_cacheStats['cacheSize'] ?? 0) ~/ 1024}KB',
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
            Text(
              'Cache Usage: ${(_cacheStats['cacheUtilization'] ?? 0).toStringAsFixed(1)}%',
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () async {
                await ImageCacheService.clearCache();
                _loadStats();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cache cleared')),
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Clear Cache',
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
