import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:rikhh_app/features/products/data/sample_products.dart';
import 'package:rikhh_app/shared/components/categories_slider.dart';
import 'package:rikhh_app/shared/components/product_card.dart';
import 'package:rikhh_app/shared/components/promo_banner.dart';
import 'package:rikhh_app/shared/components/top_search_bar.dart';
import 'package:rikhh_app/core/utils/responsive.dart';
import '../../../core/theme/app_colors.dart';
import 'dart:async';

import '../../products/bloc/products_bloc.dart';
import '../../products/bloc/categories_bloc.dart';
import '../../products/models/product_model.dart';
import '../../products/screens/product_detail_screen.dart';
import '../bloc/location_bloc.dart';
import 'location_picker_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  // Stream subscription for ProductsBloc state changes
  StreamSubscription? _productsBlocSubscription;

  // Debounced search timer
  Timer? _debounceTimer;
  static const Duration _debounceDelay = Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();

    // Register for app lifecycle changes
    WidgetsBinding.instance.addObserver(this);

    // Load featured products using ProductsBloc
    _loadFeaturedProducts();

    // Load categories using CategoriesBloc
    context.read<CategoriesBloc>().add(LoadCategories());

    // Load saved location
    context.read<LocationBloc>().add(const LocationLoadRequested());

    // Initialize promotional banners
    _promoBanners = [
      PromoBanner(
        topTitle: 'Upto',
        title: '15% OFF',
        subtitle: 'Ending Tomorrow',
        buttonText: 'Order Now',
        buttonColor: AppColors.primary,
        gradientColors: [
          Color(0xFF134A2B),
          AppColors.primary.withValues(alpha: 0.8),
        ],
        imagePath: 'assets/images/image_banner.png',
        imageBackgroundColor: Colors.yellow,
      ),
      PromoBanner(
        topTitle: 'Free ',
        title: 'Delivery',
        subtitle: 'On orders above ₹999',
        buttonText: 'Shop Now',
        buttonColor: Colors.purple,
        gradientColors: [Colors.purple, Colors.purple.withValues(alpha: 0.8)],
        imagePath: 'assets/images/image_banner.png',
        imageBackgroundColor: Colors.blue.shade100,
      ),
      PromoBanner(
        topTitle: 'New ',
        title: 'Arrivals',
        subtitle: 'Check out latest products',
        buttonText: 'Explore',
        buttonColor: Colors.orange,
        gradientColors: [Colors.orange, Colors.orange.withValues(alpha: 0.8)],
        imagePath: 'assets/images/image_banner.png',
        imageBackgroundColor: Colors.red.shade100,
      ),
      PromoBanner(
        topTitle: 'New',
        title: 'Flash Sale',
        subtitle: 'Limited time offer',
        buttonText: 'Buy Now',
        buttonColor: Colors.red,
        gradientColors: [Colors.red, Colors.red.withValues(alpha: 0.8)],
        imagePath: 'assets/images/image_banner.png',
        imageBackgroundColor: Colors.yellow.shade100,
      ),
    ];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Set up stream subscription for ProductsBloc state changes
    _productsBlocSubscription ??= context.read<ProductsBloc>().stream.listen((
      state,
    ) {
      if (mounted && state is ProductsInitial) {
        _loadFeaturedProducts();
      }
    });

    // Check if we need to reload featured products
    // Only reload if we're in initial state
    final currentState = context.read<ProductsBloc>().state;
    if (currentState is ProductsInitial) {
      _loadFeaturedProducts();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // When app becomes active again, ensure featured products are displayed
    if (state == AppLifecycleState.resumed) {
      _ensureFeaturedProductsDisplayed();
    }
  }

  @override
  void dispose() {
    // Remove app lifecycle observer
    WidgetsBinding.instance.removeObserver(this);

    _productsBlocSubscription?.cancel();
    _debounceTimer?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _ensureFeaturedProductsDisplayed() {
    final currentState = context.read<ProductsBloc>().state;

    // If we're not showing featured products, restore them
    if (currentState is! FeaturedProductsLoaded &&
        currentState is! ProductsLoading) {
      context.read<ProductsBloc>().add(const RestoreFeaturedProducts());
    }
  }

  void _loadFeaturedProducts() {
    // Only load featured products if we're not already loading them
    final currentState = context.read<ProductsBloc>().state;
    if (currentState is! ProductsLoading) {
      context.read<ProductsBloc>().add(
        LoadFeaturedProducts(filter: ProductFilter(featured: true)),
      );
    }
  }

  /// Debounced search function that triggers after user stops typing
  void _onSearchTextChanged(String value) {
    // Cancel previous timer
    _debounceTimer?.cancel();

    // Only search if we have at least 3 characters
    if (value.trim().length >= 3) {
      _debounceTimer = Timer(_debounceDelay, () {
        if (mounted) {
          // Navigate to search screen with the search query
          context.go('/main/search', extra: value.trim());
        }
      });
    } else if (value.trim().isEmpty) {
      // Clear search and restore featured products when text is empty
      context.read<ProductsBloc>().add(const RestoreFeaturedProducts());
    }
  }

  /// Clear search and restore featured products
  void _clearSearch() {
    _searchController.clear();
    _debounceTimer?.cancel();
    context.read<ProductsBloc>().add(const RestoreFeaturedProducts());
  }

  /// Open location picker screen
  Future<void> _openLocationPicker() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const LocationPickerScreen()),
    );

    if (result != null && mounted) {
      context.read<LocationBloc>().add(
        LocationUpdateRequested(
          address: result['address'],
          latitude: result['latitude'],
          longitude: result['longitude'],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ensure featured products are displayed when building the screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureFeaturedProductsDisplayed();
    });

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        bottom: false, // We'll handle bottom safe area manually
        child: Column(
          children: [
            // Top Section with Status Bar, Location, and Search
            _buildTopSection(),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Promotional Banner
                    _buildPromoBanner(),

                    // Categories Section
                    _buildCategoriesSection(),

                    // Featured Products
                    _buildFeaturedProducts(),

                    // Sponsored Product
                    _buildSponsoredProduct(),

                    // Recently Viewed
                    _buildRecentlyViewed(),

                    // Top Picks
                    _buildTopPicks(),

                    // Newly Added
                    _buildNewlyAdded(),

                    // Another Sponsored Product
                    _buildSponsoredProduct(),

                    // Min 30% Off Products
                    _buildMin30OffProducts(),

                    // Bottom padding
                    SizedBox(
                      height:
                          MediaQuery.of(context).padding.bottom +
                          Responsive.scaleHeight(context, 100),
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

  Widget _buildTopSection() {
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.fromLTRB(
        Responsive.scaleWidth(context, 16),
        MediaQuery.of(context).padding.top + Responsive.scaleHeight(context, 0),
        Responsive.scaleWidth(context, 16),
        Responsive.scaleHeight(context, 8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Responsive.vSpace(context, 8),

          // Top row with Location, Wallet, and Notification
          Row(
            children: [
              // Location Bar
              Expanded(
                child: BlocBuilder<LocationBloc, LocationState>(
                  builder: (context, state) {
                    String displayLocation = 'Select Location';

                    if (state is LocationLoaded) {
                      displayLocation = state.address;
                    } else if (state is LocationNotSet) {
                      displayLocation = 'Select Location';
                    }

                    return InkWell(
                      onTap: _openLocationPicker,
                      borderRadius: BorderRadius.circular(8),
                      child: Row(
                        children: [
                          Icon(
                            Feather.map_pin,
                            color: AppColors.primary,
                            size: 24,
                          ),
                          Responsive.hSpace(context, 8),
                          Expanded(
                            child: Text(
                              displayLocation,
                              style: TextStyle(
                                color: AppColors.heading,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(
                            Feather.chevron_down,
                            color: AppColors.heading,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              Responsive.hSpace(context, 16),

              // Wallet Icon
              Icon(Feather.credit_card, color: AppColors.heading, size: 24),

              Responsive.hSpace(context, 16),

              // Notification Icon
              Stack(
                children: [
                  Icon(Feather.bell, color: AppColors.heading, size: 24),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '3',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          Responsive.vSpace(context, 16),

          // Search Bar
          TopSearchBar(
            controller: _searchController,
            focusNode: _searchFocusNode,
            onChanged: _onSearchTextChanged,
            onTap: () {
              // Focus the search field to open keyboard
              FocusScope.of(context).requestFocus(_searchFocusNode);
            },
            onSearch: () {
              // Navigate to search screen with current search text
              if (_searchController.text.trim().isNotEmpty) {
                context.go(
                  '/main/search',
                  extra: _searchController.text.trim(),
                );
              }
            },
            onClear: _clearSearch,
            margin: EdgeInsets.zero,
            readOnly: false, // Make it editable
            // hintText: 'Type at least 3 characters to search...',
          ),

          // Typing indicator when user is typing but hasn't reached 3 chars
          if (_searchController.text.isNotEmpty &&
              _searchController.text.length < 3)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.keyboard, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Type ${3 - _searchController.text.length} more character${3 - _searchController.text.length == 1 ? '' : 's'} to search',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPromoBanner() {
    return PromoBannerCarousel(
      banners: _promoBanners,
      onButtonPressed: () {
        // Handle banner button press
      },
      autoPlay: true,
      autoPlayInterval: const Duration(seconds: 4),
    );
  }

  // Promotional banner data
  late final List<PromoBanner> _promoBanners;

  Widget _buildCategoriesSection() {
    final fontSize = Responsive.getProductCardFontSize(context, baseSize: 12.0);
    return BlocBuilder<CategoriesBloc, CategoriesState>(
      builder: (context, state) {
        List<String> categories = ['All'];

        if (state is CategoriesLoaded) {
          categories.addAll(state.categories.map((cat) => cat.name).toList());
        } else if (state is CategoriesLoading) {
          categories.addAll(['Loading...', 'Loading...', 'Loading...']);
        } else {
          categories.addAll([
            'Clothing',
            'Shoes',
            'Bags',
            'Electronics',
            'Kitchen',
            'Beauty',
            'Sports',
            'Home',
            'Books',
            'Toys',
            'Automotive',
            'Health',
            'Garden',
            'Office',
            'Pet Supplies',
          ]);
        }

        return Container(
          margin: EdgeInsets.fromLTRB(
            Responsive.scaleWidth(context, 16),
            0,
            Responsive.scaleWidth(context, 16),
            Responsive.scaleHeight(context, 8),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Categories',
                    style: TextStyle(
                      color: AppColors.heading,
                      fontSize: fontSize + 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to categories screen
                      Navigator.of(context).pushNamed('/categories');
                    },
                    child: Text(
                      'See all',
                      style: TextStyle(
                        fontSize: fontSize + 6,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              Responsive.vSpace(context, 5),
              CategoriesSlider(
                categories: categories,
                onCategorySelected: (category) {
                  // Navigate to search screen with selected category
                  if (category != 'All') {
                    context.go('/main/search', extra: category);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeaturedProducts() {
    return Container(
      margin: EdgeInsets.fromLTRB(
        Responsive.scaleWidth(context, 16),
        Responsive.scaleHeight(context, 8),
        Responsive.scaleWidth(context, 16),
        Responsive.scaleHeight(context, 16),
      ),
      child: Column(
        children: [
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     Text(
          //       'Featured Products',
          //       style: TextStyle(
          //         color: AppColors.heading,
          //         fontSize: fontSize + 11,
          //         fontWeight: FontWeight.bold,
          //       ),
          //     ),
          //     TextButton(
          //       onPressed: () {},
          //       child: Text(
          //         'See all',
          //         style: TextStyle(
          //           fontSize: fontSize + 6,
          //           color: AppColors.primary,
          //           fontWeight: FontWeight.w600,
          //         ),
          //       ),
          //     ),
          //   ],
          // ),
          Responsive.vSpace(context, 10),
          BlocBuilder<ProductsBloc, ProductsState>(
            builder: (context, state) {
              if (state is ProductsLoading &&
                  !context.read<ProductsBloc>().isFeaturedProductsLoaded) {
                return Center(
                  child: Padding(
                    padding: Responsive.padding(context, all: 32.0),
                    child: const CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  ),
                );
              }

              if (state is ProductsError &&
                  !context.read<ProductsBloc>().isFeaturedProductsLoaded) {
                return Center(
                  child: Padding(
                    padding: Responsive.padding(context, all: 32.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: AppColors.body,
                          size: 48,
                        ),
                        Responsive.vSpace(context, 16),
                        Text(
                          'Error loading featured products',
                          style: TextStyle(color: AppColors.body),
                        ),
                        Responsive.vSpace(context, 8),
                        Text(
                          state.message,
                          style: TextStyle(color: AppColors.body, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }

              List<Product> featuredProducts = [];

              // Handle different states for featured products
              if (state is FeaturedProductsLoaded) {
                featuredProducts = state.featuredProducts;
              } else if (state is ProductsLoaded &&
                  state.currentFilter?.featured == true) {
                featuredProducts = state.products;
              } else if (state is SearchProductsLoaded) {
                // If we're in search state, use cached featured products
                featuredProducts = context
                    .read<ProductsBloc>()
                    .getFeaturedProducts();
              } else {
                // Fallback to cached featured products
                featuredProducts = context
                    .read<ProductsBloc>()
                    .getFeaturedProducts();
              }

              if (featuredProducts.isEmpty) {
                return Center(
                  child: Padding(
                    padding: Responsive.padding(context, all: 32.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          color: AppColors.body,
                          size: 48,
                        ),
                        Responsive.vSpace(context, 16),
                        Text(
                          'No featured products available',
                          style: TextStyle(color: AppColors.body),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: _getResponsiveAspectRatio(context),
                  crossAxisSpacing: Responsive.scaleWidth(context, 16),
                  mainAxisSpacing: Responsive.scaleHeight(context, 9),
                ),
                itemCount: featuredProducts.length,
                itemBuilder: (context, index) {
                  final product = featuredProducts[index];
                  return ProductCard(
                    thumbnail: product.thumbnailImg != null
                        ? product.thumbnailImg!.url
                        : 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400&h=400&fit=crop',
                    rating: product.rating,
                    sold:
                        '${(product.reviewCount / 1000).toStringAsFixed(1)}k+',
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
                      // Navigate to product detail screen
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              ProductDetailScreen(product: product),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSponsoredProduct() {
    final sponsoredProduct = SampleProducts.getProducts().firstWhere(
      (product) => product.name.contains('Cherry Blossom'),
      orElse: () => SampleProducts.getProducts().first,
    );

    return Container(
      margin: EdgeInsets.fromLTRB(
        Responsive.scaleWidth(context, 16),
        Responsive.scaleHeight(context, 8),
        Responsive.scaleWidth(context, 16),
        Responsive.scaleHeight(context, 8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sponsored',
            style: TextStyle(
              color: AppColors.body,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Responsive.vSpace(context, 12),
          GestureDetector(
            onTap: () {
              // Navigate to product detail screen
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      ProductDetailScreen(product: sponsoredProduct),
                ),
              );
            },
            child: Container(
              padding: Responsive.padding(context, all: 16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Feather.coffee,
                      size: 40,
                      color: Colors.amber.shade700,
                    ),
                  ),
                  Responsive.hSpace(context, 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Feather.star,
                              color: Color(0XFFFB6514),
                              size: 16,
                            ),
                            Responsive.hSpace(context, 4),
                            Text(
                              '${sponsoredProduct.rating}',
                              style: TextStyle(
                                color: AppColors.heading,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Responsive.hSpace(context, 8),
                            Text(
                              '${(sponsoredProduct.reviewCount / 1000).toStringAsFixed(1)}k+ Sold',
                              style: TextStyle(
                                color: AppColors.body,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        Responsive.vSpace(context, 8),
                        Text(
                          sponsoredProduct.name,
                          style: TextStyle(
                            color: AppColors.heading,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Responsive.vSpace(context, 8),
                        Text(
                          '₹${sponsoredProduct.price.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentlyViewed() {
    return Container(
      margin: EdgeInsets.fromLTRB(
        Responsive.scaleWidth(context, 16),
        Responsive.scaleHeight(context, 8),
        Responsive.scaleWidth(context, 16),
        Responsive.scaleHeight(context, 16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recently Viewed',
                style: TextStyle(
                  color: AppColors.heading,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'See all',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          Responsive.vSpace(context, 16),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              itemBuilder: (context, index) {
                return Container(
                  width: 100,
                  margin: EdgeInsets.only(
                    right: Responsive.scaleWidth(context, 12),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.divider,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Feather.image, color: AppColors.body),
                      ),
                      Responsive.vSpace(context, 8),
                      Text(
                        'Product ${index + 1}',
                        style: TextStyle(
                          color: AppColors.heading,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopPicks() {
    return Container(
      margin: EdgeInsets.fromLTRB(
        Responsive.scaleWidth(context, 16),
        Responsive.scaleHeight(context, 8),
        Responsive.scaleWidth(context, 16),
        Responsive.scaleHeight(context, 16),
      ),
      child: Column(
        children: [
          Text(
            'Top Picks for you',
            style: TextStyle(
              color: AppColors.heading,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Responsive.vSpace(context, 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1,
              crossAxisSpacing: Responsive.scaleWidth(context, 12),
              mainAxisSpacing: Responsive.scaleHeight(context, 12),
            ),
            itemCount: 6,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Feather.image, color: AppColors.body, size: 32),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNewlyAdded() {
    final newlyAddedProducts = SampleProducts.getProducts().take(4).toList();

    return Container(
      margin: EdgeInsets.fromLTRB(
        Responsive.scaleWidth(context, 16),
        Responsive.scaleHeight(context, 8),
        Responsive.scaleWidth(context, 16),
        Responsive.scaleHeight(context, 16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Newly Added',
                style: TextStyle(
                  color: AppColors.heading,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'See all',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          Responsive.vSpace(context, 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: _getResponsiveAspectRatio(context),
              crossAxisSpacing: Responsive.scaleWidth(context, 16),
              mainAxisSpacing: Responsive.scaleHeight(context, 9),
            ),
            itemCount: newlyAddedProducts.length,
            itemBuilder: (context, index) {
              final product = newlyAddedProducts[index];
              return ProductCard(
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
                  // Navigate to product detail screen
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          ProductDetailScreen(product: product),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMin30OffProducts() {
    final discountProducts = SampleProducts.getProducts()
        .where(
          (product) => product.hasDiscount && product.discountPercentage >= 30,
        )
        .take(4)
        .toList();

    return Container(
      margin: EdgeInsets.fromLTRB(
        Responsive.scaleWidth(context, 16),
        Responsive.scaleHeight(context, 8),
        Responsive.scaleWidth(context, 16),
        Responsive.scaleHeight(context, 16),
      ),
      child: Column(
        children: [
          Text(
            'Min 30% Off Products',
            style: TextStyle(
              color: AppColors.heading,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Responsive.vSpace(context, 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: _getResponsiveAspectRatio(context),
              crossAxisSpacing: Responsive.scaleWidth(context, 16),
              mainAxisSpacing: Responsive.scaleHeight(context, 16),
            ),
            itemCount: discountProducts.length,
            itemBuilder: (context, index) {
              final product = discountProducts[index];
              return ProductCard(
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
                  // Navigate to product detail screen
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          ProductDetailScreen(product: product),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  /// Get responsive aspect ratio based on screen size
  double _getResponsiveAspectRatio(BuildContext context) {
    return Responsive.getProductCardAspectRatio(context);
  }
}
