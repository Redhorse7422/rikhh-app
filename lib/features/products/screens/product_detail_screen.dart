import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/product_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/components/optimized_image.dart';
import '../../../core/services/image_optimization_service.dart';
import '../../cart/bloc/cart_cubit.dart';
import '../../auth/bloc/auth_bloc.dart';

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
  void initState() {
    super.initState();
    _preloadImages();
  }

  Future<void> _preloadImages() async {
    // Preload all product images for faster carousel navigation
    final imageService = ImageOptimizationService();
    final imageUrls = widget.product.photos.map((photo) => photo.url).toList();
    
    // Preload images in the background
    WidgetsBinding.instance.addPostFrameCallback((_) {
      imageService.preloadImages(
        context,
        imageUrls,
        size: ImageSize.large,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CartCubit, CartState>(
      listener: (context, state) {
        // Show success notification when cart operation completes successfully
        if (state.status == CartStatus.loaded && !state.actionInProgress) {
          // Check if this is after an add operation by checking if we have items
          if (state.items.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Added to cart'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
        // Show error notification if cart operation fails
        if (state.status == CartStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to add to cart: ${state.errorMessage ?? "Unknown error"}',
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          bottom: false, // We'll handle bottom safe area manually
          child: Column(
            children: [
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
      ),
    );
  }

  Widget _buildProductImageSection() {
    return Column(
      children: [
        SizedBox(
          height: 280,
          width: double.infinity,
          child: Stack(
            children: [
              // Image carousel
              PageView.builder(
                onPageChanged: (index) =>
                    setState(() => _currentImageIndex = index),
                itemCount: widget.product.photos.length,
                itemBuilder: (context, index) {
                  final imageUrl = widget.product.photos[index];
                  return SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: OptimizedImage(
                      imageUrl: imageUrl.url,
                      fit: BoxFit.cover,
                      size: ImageSize.large, // Use large size for detail images
                      width: double.infinity,
                      height: double.infinity,
                      errorWidget: Container(
                        color: AppColors.divider,
                        child: const Icon(
                          Icons.image_not_supported,
                          size: 64,
                          color: AppColors.body,
                        ),
                      ),
                      placeholder: Container(
                        color: AppColors.divider,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              // Back button overlay
              Positioned(
                top: MediaQuery.of(context).padding.top - 2,
                left: 0,
                child: SizedBox(
                  // decoration: BoxDecoration(
                  //   color: Colors.black.withValues(alpha: 0.3),
                  //   borderRadius: BorderRadius.circular(20),
                  // ),
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Feather.arrow_left,
                      color: Colors.white,
                      size: 30,
                    ),
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                  ),
                ),
              ),
            ],
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
                      '₹${widget.product.price.toStringAsFixed(0)}',
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
                        'Typical Price: ₹${widget.product.originalPrice!.toStringAsFixed(0)}',
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
            child: BlocBuilder<CartCubit, CartState>(
              builder: (context, cartState) {
                final isLoading = cartState.actionInProgress;

                return ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (!(widget.product.inStock ?? true)) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'This product is out of stock.',
                                  ),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                            }
                            return;
                          }

                          final scaffoldMessenger = ScaffoldMessenger.of(context);
                          try {
                            final authState = context.read<AuthBloc>().state;
                            if (authState is AuthAuthenticated) {
                              await context.read<CartCubit>().add(
                                userData: authState.user,
                                productId: widget.product.id,
                                quantity: _quantity,
                              );
                              // Success notification will be handled by BlocListener
                            } else {
                              throw Exception('User not authenticated');
                            }
                          } catch (e) {
                            if (mounted) {
                              scaffoldMessenger.showSnackBar(
                                SnackBar(
                                  content: Text('Failed to add to cart: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isLoading
                        ? AppColors.primary.withValues(alpha: 0.6)
                        : AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: isLoading
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text('Adding...'),
                          ],
                        )
                      : const Text('Add to Cart'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
