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
    this.autoPlayInterval = const Duration(seconds: 10),
  });

  @override
  State<PromoBannerCarousel> createState() => _PromoBannerCarouselState();
}

class _PromoBannerCarouselState extends State<PromoBannerCarousel>
    with TickerProviderStateMixin {
  late PageController _pageController;
  int _currentPage = 0;
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: widget.viewportFraction);

    // Initialize progress animation controller
    _progressController = AnimationController(
      duration: widget.autoPlayInterval,
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.linear),
    );

    // Listen to progress animation completion
    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed && widget.autoPlay) {
        _nextPage();
      }
    });

    if (widget.autoPlay && widget.banners.isNotEmpty) {
      _startAutoPlay();
    }
  }

  void _startAutoPlay() {
    if (widget.autoPlay && widget.banners.isNotEmpty) {
      _progressController.forward();
    }
  }

  void _nextPage() {
    if (_pageController.hasClients) {
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
      } catch (e) {
        // Handle any errors gracefully
      }
    }
  }

  @override
  void dispose() {
    try {
      if (_pageController.hasClients) {
        _pageController.dispose();
      }
      _progressController.dispose();
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
                // Reset and restart progress animation for new page
                _progressController.reset();
                if (widget.autoPlay) {
                  _progressController.forward();
                }
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
                  width: 28,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.grey.shade300,
                  ),
                  child: _currentPage == index
                      ? AnimatedBuilder(
                          animation: _progressAnimation,
                          builder: (context, child) {
                            return Stack(
                              children: [
                                // Background
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                // Progress fill
                                FractionallySizedBox(
                                  widthFactor: _progressAnimation.value,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      color: Colors.black87,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.2,
                                          ),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        )
                      : Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: Colors.grey.shade300,
                          ),
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
