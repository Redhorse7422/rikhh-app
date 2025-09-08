import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rikhh_app/core/theme/app_colors.dart';
import 'package:rikhh_app/core/utils/responsive.dart';
import 'package:rikhh_app/features/products/bloc/products_bloc.dart';
import 'package:rikhh_app/features/products/models/product_model.dart';
import 'package:rikhh_app/features/products/screens/product_detail_screen.dart';
import 'package:rikhh_app/shared/components/product_card.dart';
import 'package:shimmer/shimmer.dart';

class FeaturedProductsSection extends StatelessWidget {
  const FeaturedProductsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final EdgeInsets outerMargin = EdgeInsets.fromLTRB(
      Responsive.scaleWidth(context, 16),
      Responsive.scaleHeight(context, 0),
      Responsive.scaleWidth(context, 16),
      Responsive.scaleHeight(context, 16),
    );
    final fontSize = Responsive.getProductCardFontSize(context, baseSize: 12.0);
    return Container(
      margin: outerMargin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Featured Products',
                style: TextStyle(
                  color: AppColors.heading,
                  fontSize: fontSize + 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // TextButton(
              //   onPressed: () {
              //     // Navigate to categories screen
              //     Navigator.of(context).pushNamed('/categories');
              //   },
              //   child: Text(
              //     'See all',
              //     style: TextStyle(
              //       fontSize: fontSize + 6,
              //       color: AppColors.primary,
              //       fontWeight: FontWeight.w600,
              //     ),
              //   ),
              // ),
            ],
          ),

          Responsive.vSpace(context, 8),
          BlocBuilder<ProductsBloc, ProductsState>(
            builder: (context, state) {
              final bool isInitialLoading =
                  state is ProductsLoading &&
                  !context.read<ProductsBloc>().isFeaturedProductsLoaded;

              if (isInitialLoading) {
                return _ShimmerGrid();
              }

              if (state is ProductsError &&
                  !context.read<ProductsBloc>().isFeaturedProductsLoaded) {
                return _ErrorState(message: state.message);
              }

              final List<Product> products = _selectFeatured(state, context);

              if (products.isEmpty) {
                return _EmptyState();
              }

              return _AnimatedProductsGrid(products: products);
            },
          ),
        ],
      ),
    );
  }

  List<Product> _selectFeatured(ProductsState state, BuildContext context) {
    if (state is FeaturedProductsLoaded) return state.featuredProducts;
    if (state is ProductsLoaded && state.currentFilter?.featured == true) {
      return state.products;
    }
    if (state is SearchProductsLoaded) {
      return context.read<ProductsBloc>().getFeaturedProducts();
    }
    return context.read<ProductsBloc>().getFeaturedProducts();
  }
}

class _AnimatedProductsGrid extends StatelessWidget {
  final List<Product> products;

  const _AnimatedProductsGrid({required this.products});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: GridView.builder(
        key: ValueKey(products.length),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // 3 products per row
          crossAxisSpacing: 12, // Horizontal spacing between items
          mainAxisSpacing: 12, // Vertical spacing between items
          childAspectRatio: 0.68, // Width/Height ratio for each item
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return _AnimatedTile(
            index: index,
            child: Semantics(
              label: 'Product ${product.name}',
              button: true,
              child: ProductCard(
                thumbnail: product.thumbnailImg != null
                    ? product.thumbnailImg!.url
                    : 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400&h=400&fit=crop',
                rating: product.rating,
                sold: '${(product.reviewCount / 1000).toStringAsFixed(1)}k+',
                name: product.name,
                currentPrice: '₹${product.price.toStringAsFixed(0)}',
                originalPrice: product.originalPrice != null
                    ? '₹${product.originalPrice!.toStringAsFixed(0)}'
                    : '',
                badge: product.hasDiscount
                    ? '${product.discountPercentage.toStringAsFixed(0)}% Off'
                    : null,
                badgeColor: product.hasDiscount ? Colors.red : null,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          ProductDetailScreen(product: product),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AnimatedTile extends StatefulWidget {
  final int index;
  final Widget child;

  const _AnimatedTile({required this.index, required this.child});

  @override
  State<_AnimatedTile> createState() => _AnimatedTileState();
}

class _AnimatedTileState extends State<_AnimatedTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _scale = Tween<double>(
      begin: 0.96,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _fadeIn = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // Staggered start for items
    Future.delayed(Duration(milliseconds: 40 * widget.index), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeIn,
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}

class _ShimmerGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final double crossAxisSpacing = Responsive.scaleWidth(context, 12);
    final double mainAxisSpacing = Responsive.scaleHeight(context, 10);
    final double minItemWidth = MediaQuery.of(context).size.width / 3.2;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: minItemWidth,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        childAspectRatio: 0.8,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: AppColors.divider,
          highlightColor: AppColors.divider.withValues(alpha: 0.6),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: Responsive.padding(context, all: 32.0),
        child: Column(
          children: [
            Icon(Icons.inventory_2_outlined, color: AppColors.body, size: 48),
            Responsive.vSpace(context, 8),
            Text(
              'No featured products available',
              style: TextStyle(color: AppColors.body),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: Responsive.padding(context, all: 32.0),
        child: Column(
          children: [
            Icon(Icons.error_outline, color: AppColors.body, size: 48),
            Responsive.vSpace(context, 8),
            Text(
              'Error loading featured products',
              style: TextStyle(color: AppColors.body),
            ),
            Responsive.vSpace(context, 6),
            Text(
              message,
              style: TextStyle(color: AppColors.body, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
