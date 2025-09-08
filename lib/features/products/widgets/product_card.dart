import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import '../../../shared/components/optimized_image.dart';
import '../../../core/services/image_optimization_service.dart';
import '../models/product_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/components/skewed_badge.dart';
import '../../../core/utils/responsive.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final bool showBadge;
  final bool showRating;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.showBadge = true,
    this.showRating = true,
  });

  @override
  Widget build(BuildContext context) {
    // Get responsive dimensions using the utility class
    final padding = Responsive.getProductCardPadding(context);
    final fontSize = Responsive.getProductCardFontSize(context, baseSize: 12.0);
    final priceFontSize = Responsive.getProductCardFontSize(
      context,
      baseSize: 16.0,
    );
    final badgeTop = Responsive.isSmallScreen(context) ? 4.0 : 6.0;
    final badgeLeft = Responsive.isSmallScreen(context) ? 4.0 : 6.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section with responsive flex
            Expanded(
              flex: Responsive.isSmallScreen(context) ? 2 : 3,
              child: Stack(
                children: [
                  // Product Image
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      color: AppColors.divider,
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      child: OptimizedImage(
                        imageUrl: product.thumbnailImg != null
                            ? product.thumbnailImg!.url
                            : 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400&h=400&fit=crop',
                        fit: BoxFit.cover,
                        size: ImageSize.thumbnail,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  // Discount Badge
                  if (showBadge && product.hasDiscount)
                    Positioned(
                      top: badgeTop,
                      left: badgeLeft,
                      child: SkewedBadge(
                        text: product.formattedDiscount,
                        color: Colors.red,
                      ),
                    ),

                  // Stock Badge
                  if (!(product.inStock ?? false))
                    Positioned(
                      top: badgeTop,
                      left: badgeLeft,
                      child: SkewedBadge(
                        text: 'Out of Stock',
                        color: Colors.red,
                      ),
                    ),

                  // Wishlist Button with responsive positioning
                  Positioned(
                    top: badgeTop,
                    right: (product.inStock ?? false)
                        ? badgeLeft
                        : (Responsive.isSmallScreen(context) ? 60.0 : 80.0),
                    child: Container(
                      width: Responsive.isSmallScreen(context) ? 28.0 : 32.0,
                      height: Responsive.isSmallScreen(context) ? 28.0 : 32.0,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: () {
                          // Handle wishlist functionality
                        },
                        icon: Icon(
                          Feather.heart,
                          size: Responsive.isSmallScreen(context) ? 14.0 : 16.0,
                          color: AppColors.body,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  ),

                  // Add to Cart Floating Button
                  if ((product.inStock ?? true))
                    Positioned(
                      bottom: badgeTop,
                      right: badgeLeft,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          minimumSize: const Size(0, 0),
                        ),
                        onPressed: () async {
                          try {
                            // await context.read<CartCubit>().add(productId: product.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Added to cart')),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to add to cart: $e'),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Feather.shopping_cart, size: 14),
                        label: const Text('Add'),
                      ),
                    ),
                ],
              ),
            ),

            // Product Info Section with responsive flex
            Expanded(
              flex: Responsive.isSmallScreen(context) ? 3 : 2,
              child: Container(
                padding: EdgeInsets.all(padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Rating and Reviews
                    if (showRating)
                      Row(
                        children: [
                          Icon(
                            Feather.star,
                            size: fontSize,
                            color: Colors.orange,
                          ),
                          SizedBox(width: padding * 0.33),
                          Text(
                            product.rating.toString(),
                            style: TextStyle(
                              fontSize: fontSize,
                              fontWeight: FontWeight.w600,
                              color: AppColors.heading,
                            ),
                          ),
                          SizedBox(width: padding * 0.33),
                          Expanded(
                            child: Text(
                              '(${product.reviewCount})',
                              style: TextStyle(
                                fontSize: fontSize - 1,
                                color: AppColors.body,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                    if (showRating) SizedBox(height: padding * 0.67),

                    // Product Name
                    Text(
                      product.name,
                      style: TextStyle(
                        fontSize: fontSize + 1,
                        fontWeight: FontWeight.w600,
                        color: AppColors.heading,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const Spacer(),

                    // Price Section with responsive layout
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Current Price
                        Text(
                          product.formattedPrice,
                          style: TextStyle(
                            fontSize: priceFontSize,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),

                        // Original Price (if discounted)
                        if (product.hasDiscount &&
                            product.originalPrice != null)
                          Padding(
                            padding: EdgeInsets.only(top: padding * 0.17),
                            child: Text(
                              product.formattedOriginalPrice,
                              style: TextStyle(
                                fontSize: fontSize,
                                color: AppColors.body,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ),
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
