import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:rikhh_app/core/utils/to_camel_case.dart';
import 'package:rikhh_app/shared/components/skewed_badge.dart';
import 'package:rikhh_app/shared/components/optimized_image.dart';
import 'package:rikhh_app/core/services/image_optimization_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';

class ProductCard extends StatelessWidget {
  final String thumbnail;
  final double rating;
  final String sold;
  final String name;
  final String currentPrice;
  final String originalPrice;
  final String? badge;
  final Color? badgeColor;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.thumbnail,
    required this.rating,
    required this.sold,
    required this.name,
    required this.currentPrice,
    required this.originalPrice,
    this.badge,
    this.badgeColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Get responsive dimensions using the utility class
    final imageHeight = Responsive.getProductCardImageHeight(context);
    final padding = Responsive.getProductCardPadding(context);
    final fontSize = Responsive.getProductCardFontSize(context, baseSize: 12.0);
    // final priceFontSize = Responsive.getProductCardFontSize(
    //   context,
    //   baseSize: 16.0,
    // );

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        // decoration: BoxDecoration(
        //   color: AppColors.white,
        //   borderRadius: BorderRadius.circular(12),
        //   border: Border.all(color: AppColors.divider),
        //   boxShadow: [
        //     BoxShadow(
        //       color: Colors.black.withValues(alpha: 0.05),
        //       blurRadius: 8,
        //       offset: const Offset(0, 4),
        //     ),
        //   ],
        // ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Product Image Container with responsive height and badge overlay
            Stack(
              children: [
                Container(
                  height: imageHeight,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                    child: thumbnail.startsWith('http')
                        ? OptimizedImage(
                            imageUrl: thumbnail,
                            fit: BoxFit.cover,
                            size: ImageSize.thumbnail,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                          )
                        : Image.asset(
                            thumbnail,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Center(
                                  child: Icon(
                                    Feather.image,
                                    color: AppColors.body,
                                    size: 40,
                                  ),
                                ),
                          ),
                  ),
                ),

                // Badge positioned over image
                if (badge != null)
                  Positioned(
                    top: 0,
                    left: 0,
                    child: SkewedBadge(
                      text: badge!,
                      color: badgeColor ?? Colors.red,
                    ),
                  ),
              ],
            ),

            // Product Details with responsive padding and spacing
            Expanded(
              child: Container(
                padding: EdgeInsets.all(padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Rating and Sold Count Row
                    Row(
                      children: [
                        Icon(
                          Feather.star,
                          color: const Color(0XFFFB6515),
                          size: fontSize + 4,
                        ),
                        SizedBox(width: padding * 0.5),
                        Text(
                          rating.toString(),
                          style: TextStyle(
                            color: AppColors.heading,
                            fontSize: fontSize,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: padding),
                        Expanded(
                          child: Text(
                            '$sold Sold',
                            style: TextStyle(
                              color: AppColors.body,
                              fontSize: fontSize,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    // SizedBox(height: padding * 0.75),

                    // Product Name
                    Text(
                      toCamelCase(name),
                      style: TextStyle(
                        color: AppColors.black,
                        fontSize: fontSize + 6,
                        fontWeight: FontWeight.w600,
                        // height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const Spacer(),

                    // Price Row with responsive layout
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentPrice,
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: fontSize + 6,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (originalPrice.isNotEmpty) ...[
                          SizedBox(height: 2),
                          Text(
                            originalPrice,
                            style: TextStyle(
                              color: AppColors.body,
                              fontSize: fontSize,
                              decoration: TextDecoration.lineThrough,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
