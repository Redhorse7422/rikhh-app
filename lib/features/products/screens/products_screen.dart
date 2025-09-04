import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import '../bloc/products_bloc.dart';
import '../models/product_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import 'product_detail_screen.dart';
import '../widgets/product_card.dart';

class ProductsScreen extends StatefulWidget {
  final String? category;
  final String? searchQuery;

  const ProductsScreen({super.key, this.category, this.searchQuery});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  ProductFilter? _currentFilter;

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.searchQuery ?? '';

    // Load products based on initial parameters
    if (widget.category != null) {
      _currentFilter = ProductFilter(categoryId: widget.category);
    }

    if (widget.searchQuery != null && widget.searchQuery!.isNotEmpty) {
      context.read<ProductsBloc>().add(SearchProducts(widget.searchQuery!));
    } else {
      context.read<ProductsBloc>().add(LoadProducts(filter: _currentFilter));
    }

    // Add scroll listener for pagination
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = context.read<ProductsBloc>().state;
      if (state is ProductsLoaded && !state.hasReachedMax) {
        context.read<ProductsBloc>().add(
          LoadMoreProducts(filter: _currentFilter),
        );
      }
    }
  }

  void _onSearch(String query) {
    if (query.isEmpty) {
      context.read<ProductsBloc>().add(LoadProducts(filter: _currentFilter));
    } else {
      context.read<ProductsBloc>().add(
        SearchProducts(query, filter: _currentFilter),
      );
    }
  }

  void _onFilterChanged(ProductFilter filter) {
    setState(() {
      _currentFilter = filter;
    });
    context.read<ProductsBloc>().add(LoadProducts(filter: filter));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          widget.category ?? 'Products',
          style: TextStyle(
            color: AppColors.heading,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Feather.arrow_left, color: AppColors.heading),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Feather.filter, color: AppColors.heading),
            onPressed: () => _showFilterDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Feather.search, color: AppColors.body),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Feather.x, color: AppColors.body),
                        onPressed: () {
                          _searchController.clear();
                          _onSearch('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.divider),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.divider),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
              onChanged: _onSearch,
            ),
          ),

          // Products Grid
          Expanded(
            child: BlocBuilder<ProductsBloc, ProductsState>(
              builder: (context, state) {
                if (state is ProductsLoading && state is! ProductsLoaded) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                if (state is ProductsError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Feather.alert_circle,
                          size: 64,
                          color: AppColors.body,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading products',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.heading,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.message,
                          style: TextStyle(color: AppColors.body),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<ProductsBloc>().add(
                              LoadProducts(filter: _currentFilter),
                            );
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is ProductsLoaded) {
                  if (state.products.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Feather.package,
                            size: 64,
                            color: AppColors.body,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No products found',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.heading,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try adjusting your search or filters',
                            style: TextStyle(color: AppColors.body),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<ProductsBloc>().add(
                        RefreshProducts(filter: _currentFilter),
                      );
                    },
                    child: GridView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: _getResponsiveAspectRatio(context),
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount:
                          state.products.length + (state.hasReachedMax ? 0 : 1),
                      itemBuilder: (context, index) {
                        if (index >= state.products.length) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          );
                        }

                        final product = state.products[index];
                        return ProductCard(
                          product: product,
                          onTap: () {
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
                  );
                }

                return const Center(child: Text('No products available'));
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FilterBottomSheet(
        currentFilter: _currentFilter,
        onFilterChanged: _onFilterChanged,
      ),
    );
  }

  /// Get responsive aspect ratio based on screen size
  double _getResponsiveAspectRatio(BuildContext context) {
    return Responsive.getProductCardAspectRatio(context);
  }
}

class _FilterBottomSheet extends StatefulWidget {
  final ProductFilter? currentFilter;
  final Function(ProductFilter) onFilterChanged;

  const _FilterBottomSheet({this.currentFilter, required this.onFilterChanged});

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late ProductFilter _filter;
  RangeValues _priceRange = const RangeValues(0, 10000);
  double _minRating = 0;

  @override
  void initState() {
    super.initState();
    _filter = widget.currentFilter ?? const ProductFilter();
    _priceRange = RangeValues(_filter.minPrice ?? 0, _filter.maxPrice ?? 10000);
    _minRating = _filter.minRating ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.divider)),
            ),
            child: Row(
              children: [
                Text(
                  'Filters',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.heading,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _filter = const ProductFilter();
                      _priceRange = const RangeValues(0, 10000);
                      _minRating = 0;
                    });
                  },
                  child: Text(
                    'Clear All',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Filter Options
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price Range
                  Text(
                    'Price Range',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.heading,
                    ),
                  ),
                  const SizedBox(height: 16),
                  RangeSlider(
                    values: _priceRange,
                    min: 0,
                    max: 10000,
                    divisions: 100,
                    labels: RangeLabels(
                      '₹${_priceRange.start.round()}',
                      '₹${_priceRange.end.round()}',
                    ),
                    onChanged: (values) {
                      setState(() {
                        _priceRange = values;
                      });
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('₹${_priceRange.start.round()}'),
                      Text('₹${_priceRange.end.round()}'),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Rating Filter
                  Text(
                    'Minimum Rating',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.heading,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Slider(
                    value: _minRating,
                    min: 0,
                    max: 5,
                    divisions: 10,
                    label: _minRating.toStringAsFixed(1),
                    onChanged: (value) {
                      setState(() {
                        _minRating = value;
                      });
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [Text('0'), Text('5')],
                  ),

                  const SizedBox(height: 24),

                  // Sort Options
                  Text(
                    'Sort By',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.heading,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildSortChip('Name', 'name'),
                      _buildSortChip('Price', 'price'),
                      _buildSortChip('Rating', 'rating'),
                      _buildSortChip('Newest', 'createdAt'),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Stock Filter
                  Row(
                    children: [
                      Checkbox(
                        value: _filter.inStock ?? false,
                        onChanged: (value) {
                          setState(() {
                            _filter = _filter.copyWith(inStock: value);
                          });
                        },
                        activeColor: AppColors.primary,
                      ),
                      const Text('In Stock Only'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Apply Button
          Container(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  final newFilter = _filter.copyWith(
                    minPrice: _priceRange.start,
                    maxPrice: _priceRange.end,
                    minRating: _minRating,
                  );
                  widget.onFilterChanged(newFilter);
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip(String label, String value) {
    final isSelected = _filter.sortBy == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _filter = _filter.copyWith(
              sortBy: value,
              sortAscending: value == 'price' ? false : true,
            );
          } else {
            _filter = _filter.copyWith(sortBy: null);
          }
        });
      },
      selectedColor: AppColors.primary.withValues(alpha: 0.2),
      checkmarkColor: AppColors.primary,
    );
  }
}
