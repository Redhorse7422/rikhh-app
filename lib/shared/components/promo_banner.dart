import 'package:flutter/material.dart';

// Promotional banner data model - Updated for image support
class PromoBanner {
  final String title;
  final String topTitle;
  final String subtitle;
  final String buttonText;
  final Color buttonColor;
  final List<Color> gradientColors;
  final String imagePath;
  final Color imageBackgroundColor;

  const PromoBanner({
    required this.title,
    required this.topTitle,
    required this.subtitle,
    required this.buttonText,
    required this.buttonColor,
    required this.gradientColors,
    required this.imagePath,
    required this.imageBackgroundColor,
  });
}

class PromoBannerWidget extends StatelessWidget {
  final PromoBanner banner;
  final VoidCallback? onButtonPressed;
  final double height;
  final double imageSize;
  final EdgeInsets margin;

  const PromoBannerWidget({
    super.key,
    required this.banner,
    this.onButtonPressed,
    this.height = 140,
    this.imageSize = 120,
    this.margin = const EdgeInsets.only(right: 16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: banner.gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    banner.topTitle,
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                  Text(
                    banner.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    banner.subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: onButtonPressed ?? () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: banner.buttonColor,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      minimumSize: const Size(0, 26),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(banner.buttonText),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Image.asset(
                  banner.imagePath,
                  height: double.infinity,
                  fit: BoxFit.contain, // fill available space proportionally
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Icon(
                        Icons.image,
                        color: Colors.grey.shade600,
                        size: height * 0.2, // scale placeholder too
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PromoBannerCarousel extends StatefulWidget {
  final List<PromoBanner> banners;
  final VoidCallback? onButtonPressed;
  final double height;
  final double imageSize;
  final double viewportFraction;
  final bool autoPlay;
  final Duration autoPlayInterval;

  const PromoBannerCarousel({
    super.key,
    required this.banners,
    this.onButtonPressed,
    this.height = 150,
    this.imageSize = 60,
    this.viewportFraction = 1,
    this.autoPlay = false,
    this.autoPlayInterval = const Duration(seconds: 5),
  });

  @override
  State<PromoBannerCarousel> createState() => _PromoBannerCarouselState();
}

class _PromoBannerCarouselState extends State<PromoBannerCarousel> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: widget.viewportFraction);

    if (widget.autoPlay && widget.banners.isNotEmpty) {
      _startAutoPlay();
    }
  }

  void _startAutoPlay() {
    Future.delayed(widget.autoPlayInterval, () {
      if (mounted && widget.autoPlay && _pageController.hasClients) {
        try {
          if (_currentPage < widget.banners.length - 1) {
            _pageController.nextPage(
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
            );
          } else {
            _pageController.animateToPage(
              0,
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
            );
          }
          // Only continue auto-play if still mounted and auto-play is enabled
          if (mounted && widget.autoPlay) {
            _startAutoPlay();
          }
        } catch (e) {
          // Handle any errors gracefully
        }
      }
    });
  }

  @override
  void dispose() {
    try {
      if (_pageController.hasClients) {
        _pageController.dispose();
      }
    } catch (e) {
      // Handle disposal errors gracefully
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Handle empty banners gracefully
    if (widget.banners.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 10),
      child: Column(
        children: [
          SizedBox(
            height: widget.height,
            child: PageView.builder(
              itemCount: widget.banners.length,
              controller: _pageController,
              padEnds: false,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                final banner = widget.banners[index];
                return PromoBannerWidget(
                  banner: banner,
                  onButtonPressed: widget.onButtonPressed,
                  height: widget.height,
                  imageSize: widget.imageSize,
                  margin: EdgeInsets.only(left: 16, right: 16),
                );
              },
            ),
          ),
          if (widget.banners.length > 1) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.banners.length,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
