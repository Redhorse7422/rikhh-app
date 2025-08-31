import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import '../models/product_model.dart';
import '../../../core/theme/app_colors.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _currentImageIndex = 0;
  int _quantity = 1;
  bool _isProductInfoExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        bottom: false, // We'll handle bottom safe area manually
        child: Column(
          children: [
            // Top Navigation Bar
            _buildTopNavigationBar(),

            // Product Image Section
            _buildProductImageSection(),

            // Product Details Section
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildProductDetails(),
                    _buildProductInformation(),
                    _buildSellerInformation(),
                    SizedBox(
                      height: MediaQuery.of(context).padding.bottom + 100,
                    ), // Bottom padding for action bar
                  ],
                ),
              ),
            ),

            // Bottom Action Bar
            _buildBottomActionBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopNavigationBar() {
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 8,
        16,
        12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            child: const Icon(Feather.arrow_left, color: AppColors.heading),
          ),
          const Text(
            'Product Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.heading,
            ),
          ),
          const SizedBox(width: 24),
        ],
      ),
    );
  }

  Widget _buildProductImageSection() {
    return Column(
      children: [
        SizedBox(
          height: 280,
          width: double.infinity,
          child: PageView.builder(
            onPageChanged: (index) =>
                setState(() => _currentImageIndex = index),
            itemCount: widget.product.photos.length,
            itemBuilder: (context, index) {
              final imageUrl = widget.product.photos[index];
              return SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Image.network(
                  imageUrl.url,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.divider,
                      child: const Icon(
                        Icons.image_not_supported,
                        size: 64,
                        color: AppColors.body,
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: AppColors.divider,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
        // Carousel Indicators below the image
        if (widget.product.photos.length > 1)
          Container(
            margin: const EdgeInsets.only(top: 16, bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.product.photos.length,
                (index) => Container(
                  width: _currentImageIndex == index ? 20 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10), // rounded pill
                    color: _currentImageIndex == index
                        ? AppColors.primary
                        : AppColors.body.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProductDetails() {
    final bool hasSale =
        widget.product.originalPrice != null &&
        widget.product.originalPrice! > widget.product.price;

    return Container(
      padding: EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Title
          Text(
            widget.product.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.heading,
              height: 1.3,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 16),

          // Price and Stock Row
          Row(
            children: [
              // Price Information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Current Price (sale or regular)
                    Text(
                      'Rs. ${widget.product.price.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Discount percentage
                    if (hasSale)
                      Text(
                        '-${widget.product.discountPercentage.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),

                    const SizedBox(height: 4),

                    // Original Price (strike-through) when on sale
                    if (hasSale && widget.product.originalPrice != null)
                      Text(
                        'Typical Price: Rs. ${widget.product.originalPrice!.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.body,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                  ],
                ),
              ),

              // Stock and Quantity
              Column(
                children: [
                  Text(
                    (widget.product.inStock ?? true)
                        ? 'In Stock'
                        : 'Out of Stock',
                    style: TextStyle(
                      color: (widget.product.inStock ?? true)
                          ? Colors.green
                          : Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _qtyButton(
                        icon: Feather.minus,
                        onTap: () => setState(
                          () => _quantity = (_quantity - 1).clamp(1, 999),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          '$_quantity',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      _qtyButton(
                        icon: Feather.plus,
                        onTap: () => setState(() => _quantity++),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _qtyButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.divider,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: AppColors.heading),
      ),
    );
  }

  Widget _buildProductInformation() {
    return ExpansionTile(
      title: const Text('Product Information'),
      initiallyExpanded: _isProductInfoExpanded,
      onExpansionChanged: (v) => setState(() => _isProductInfoExpanded = v),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            widget.product.description,
            style: TextStyle(color: AppColors.body),
          ),
        ),
      ],
    );
  }

  Widget _buildSellerInformation() {
    // Only show seller information if seller exists
    if (widget.product.seller == null) {
      return const SizedBox.shrink();
    }

    final seller = widget.product.seller!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child: Icon(Feather.briefcase, color: AppColors.primary, size: 20),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                seller.businessName ?? '',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.heading,
                ),
              ),
            ),
            // Verification badge
            if (seller.isVerified)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Feather.check_circle, size: 12, color: Colors.green),
                    const SizedBox(width: 4),
                    Text(
                      'Verified',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        // subtitle: Column(
        //   crossAxisAlignment: CrossAxisAlignment.start,
        //   children: [
        //     const SizedBox(height: 4),
        //     // Rating and review count
        //     Row(
        //       children: [
        //         Icon(Feather.star, size: 14, color: Colors.amber),
        //         const SizedBox(width: 4),
        //         Text(
        //           seller.formattedRating,
        //           style: const TextStyle(
        //             fontSize: 12,
        //             fontWeight: FontWeight.w600,
        //             color: AppColors.heading,
        //           ),
        //         ),
        //         const SizedBox(width: 8),
        //         Text(
        //           '(${seller.formattedReviewCount} reviews)',
        //           style: TextStyle(fontSize: 12, color: AppColors.body),
        //         ),
        //       ],
        //     ),
        //     if (seller.businessDescription != null) ...[
        //       const SizedBox(height: 4),
        //       Text(
        //         seller.businessDescription!,
        //         style: TextStyle(fontSize: 12, color: AppColors.body),
        //         maxLines: 2,
        //         overflow: TextOverflow.ellipsis,
        //       ),
        //     ],
        //   ],
        // ),
        trailing: const Icon(Feather.chevron_right, color: AppColors.body),
        onTap: () {
          // TODO: Navigate to seller profile page
          // This could show seller details, other products, etc.
        },
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('Add to Cart'),
            ),
          ),
        ],
      ),
    );
  }
}
