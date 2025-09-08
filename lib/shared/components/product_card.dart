import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:rikhh_app/core/utils/to_camel_case.dart';
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
    final padding = Responsive.getProductCardPadding(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.2),
              spreadRadius: 1,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              flex: 6,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
                child: thumbnail.startsWith('http')
                    ? OptimizedImage(
                        imageUrl: thumbnail,
                        fit: BoxFit.cover,
                        size: ImageSize.thumbnail,
                        width: double.infinity,
                      )
                    : Image.asset(
                        thumbnail,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Center(
                          child: Icon(
                            Feather.image,
                            color: AppColors.body,
                            size: 30,
                          ),
                        ),
                      ),
              ),
            ),
            // Product Details
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Feather.star,
                          color: const Color(0XFFFB6515),
                          size: 8,
                        ),
                        SizedBox(width: padding * 0.5),
                        Text(
                          rating.toString(),
                          style: TextStyle(
                            color: AppColors.heading,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: padding),
                        Expanded(
                          child: Text(
                            '$sold Sold',
                            style: TextStyle(
                              color: AppColors.body,
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      toCamelCase(name),
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: AppColors.black,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      currentPrice,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
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
