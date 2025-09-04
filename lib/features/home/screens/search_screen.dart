import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:rikhh_app/features/products/screens/product_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:rikhh_app/core/theme/app_colors.dart';
import 'package:rikhh_app/core/utils/responsive.dart';

import 'package:rikhh_app/shared/components/product_card.dart';
import 'package:rikhh_app/features/products/bloc/products_bloc.dart';
import 'package:rikhh_app/features/products/bloc/categories_bloc.dart';
import 'package:rikhh_app/features/products/models/product_model.dart';
import 'package:rikhh_app/shared/components/categories_slider.dart';

class SearchScreen extends StatefulWidget {
  final String? initialQuery;

  const SearchScreen({super.key, this.initialQuery});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _currentQuery = '';
  List<String> _searchHistory = [];
  // String _selectedFilter = 'All';
  String? _selectedCategory; // Track selected category
  String? _selectedCategoryId; // Track selected category ID

  // Pagination state
  int _currentPage = 1;
  final int _itemsPerPage = 20;
  bool _hasMoreItems = true;
  bool _isLoadingMore = false;

  // Search input controller and focus node
  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;
  late ScrollController _scrollController;

  // Stream subscription for ProductsBloc
  StreamSubscription? _productsBlocSubscription;

  // Stream subscription for CategoriesBloc
  StreamSubscription? _categoriesBlocSubscription;

  // Debounced search timer
  Timer? _debounceTimer;
  static const Duration _debounceDelay = Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();

    // Initialize search controller and focus node
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
    _scrollController = ScrollController();

    // Add scroll listener for pagination
    _scrollController.addListener(_onScroll);

    // Set initial search text from widget or route extra
    String initialText = widget.initialQuery ?? '';
    _currentQuery = initialText;
    _searchController.text = initialText;

    // Load search history
    _loadSearchHistory();

    // Load categories using CategoriesBloc
    context.read<CategoriesBloc>().add(LoadCategories());

    // If we have initial text, perform search automatically
    if (initialText.isNotEmpty) {
      _performSearch();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Check if we have search text or category from route extra
    final routeExtra = GoRouterState.of(context).extra;
    if (routeExtra is String &&
        routeExtra.isNotEmpty &&
        _currentQuery.isEmpty &&
        _selectedCategory == null) {
      // Check if this is a category name by looking at the categories
      final categoriesState = context.read<CategoriesBloc>().state;
      if (categoriesState is CategoriesLoaded) {
        final categoryData = categoriesState.categories.firstWhere(
          (cat) => cat.name.toLowerCase() == routeExtra.toLowerCase(),
          orElse: () => ProductCategory(
            id: '',
            name: '',
            productCount: 0,
            isActive: true,
          ),
        );

        if (categoryData.name.isNotEmpty) {
          // This is a category selection
          setState(() {
            _selectedCategory = categoryData.name;
            _selectedCategoryId = categoryData.id;
            _currentQuery = '';
            _searchController.clear();
          });
          _performSearch();
        } else {
          // This is a search query
          _currentQuery = routeExtra;
          _searchController.text = routeExtra;
          _performSearch();
        }
      } else {
        // Fallback: treat as search query
        _currentQuery = routeExtra;
        _searchController.text = routeExtra;
        _performSearch();
      }
    }

    // Listen to ProductsBloc state changes for pagination
    _productsBlocSubscription = context.read<ProductsBloc>().stream.listen((
      state,
    ) {
      if (mounted && state is SearchProductsLoaded) {
        _handleSearchResults(state.searchProducts);
      }
    });

    // Listen to CategoriesBloc state changes to handle route extra when categories are loaded
    _categoriesBlocSubscription = context.read<CategoriesBloc>().stream.listen((
      state,
    ) {
      if (mounted && state is CategoriesLoaded) {
        // Check if we have a pending route extra that needs to be processed
        final routeExtra = GoRouterState.of(context).extra;
        if (routeExtra is String &&
            routeExtra.isNotEmpty &&
            _currentQuery.isEmpty &&
            _selectedCategory == null) {
          // Now that categories are loaded, process the route extra
          final categoryData = state.categories.firstWhere(
            (cat) => cat.name.toLowerCase() == routeExtra.toLowerCase(),
            orElse: () => ProductCategory(
              id: '',
              name: '',
              productCount: 0,
              isActive: true,
            ),
          );

          if (categoryData.name.isNotEmpty) {
            // This is a category selection
            setState(() {
              _selectedCategory = categoryData.name;
              _selectedCategoryId = categoryData.id;
              _currentQuery = '';
              _searchController.clear();
            });
            _performSearch();
          } else {
            // This is a search query
            _currentQuery = routeExtra;
            _searchController.text = routeExtra;
            _performSearch();
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _productsBlocSubscription?.cancel();
    _categoriesBlocSubscription?.cancel();
    _debounceTimer?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Debounced search function that triggers after user stops typing
  void _onSearchTextChanged(String value) {
    // Cancel previous timer
    _debounceTimer?.cancel();

    // Don't clear category selection when user types
    // Category should remain selected until user explicitly changes it

    // Only search if we have at least 3 characters OR if category is selected
    if (value.trim().length >= 3 || _selectedCategoryId != null) {
      _debounceTimer = Timer(_debounceDelay, () {
        if (mounted) {
          setState(() {
            _currentQuery = value.trim();
          });
          _performSearch();
        }
      });
    } else if (value.trim().isEmpty) {
      // Clear search results when text is empty
      setState(() {
        _currentQuery = '';
      });
      // Clear search results
      context.read<ProductsBloc>().add(const RestoreFeaturedProducts());
    }
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    // Allow search if query has at least 3 characters OR if category is selected
    if (query.length < 3 && _selectedCategoryId == null) return;

    // Reset pagination for new search
    if (mounted) {
      setState(() {
        _currentPage = 1;
        _hasMoreItems = true;
        _currentQuery = query;

        // Add to search history only if query has at least 3 characters
        if (query.length >= 3 && !_searchHistory.contains(query)) {
          _searchHistory.insert(0, query);
          // Keep only last 10 searches
          if (_searchHistory.length > 10) {
            _searchHistory = _searchHistory.take(10).toList();
          }
          // Save search history
          _saveSearchHistory();
        }
      });
    }

    // Create filter based on selected options
    ProductFilter filter = ProductFilter(
      search: query.length >= 3
          ? query
          : null, // Only send search if query has 3+ chars
      // Apply category filter if not "All"
      categoryIds: _selectedCategoryId != null ? [_selectedCategoryId!] : null,
      // Add pagination parameters
      page: _currentPage,
      limit: _itemsPerPage,
    );

    context.read<ProductsBloc>().add(SearchProducts(query, filter: filter));
  }

  void _clearSearch() {
    _searchController.clear();
    _debounceTimer?.cancel();
    if (mounted) {
      setState(() {
        _currentQuery = '';
        // Don't automatically clear category when clearing search text
        // Category should remain selected until user explicitly changes it
      });
      // Clear search results and restore featured products
      context.read<ProductsBloc>().add(const RestoreFeaturedProducts());
    }
  }

  /// Clear category selection explicitly
  void _clearCategory() {
    if (mounted) {
      setState(() {
        _selectedCategory = null;
        _selectedCategoryId = null;
      });
      // Perform search without category filter
      _performSearch();
    }
  }

  Future<void> _saveSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('search_history', _searchHistory);
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _loadSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList('search_history') ?? [];
      if (mounted) {
        setState(() {
          _searchHistory = history;
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  void _loadMoreItems() {
    if (!_isLoadingMore && _hasMoreItems) {
      // Use the specific search pagination event
      final currentState = context.read<ProductsBloc>().state;
      if (currentState is SearchProductsLoaded) {
        setState(() {
          _isLoadingMore = true;
        });
        context.read<ProductsBloc>().add(
          LoadMoreSearchProducts(
            filter: currentState.currentFilter?.copyWith(
              page: _currentPage + 1,
            ),
          ),
        );
      }
    }
  }

  void _handleSearchResults(List<Product> products) {
    if (!mounted) return;

    // Get the current state from the BLoC to sync pagination
    final currentState = context.read<ProductsBloc>().state;
    if (currentState is SearchProductsLoaded) {
      setState(() {
        _currentPage = currentState.currentPage;
        _hasMoreItems = !currentState.hasReachedMax;
        _isLoadingMore = false;
      });
    } else {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreItems();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Search Header
            _buildSearchHeader(),

            // Results Summary and Filter Button
            _buildResultsSummary(),

            // Search Results or Empty State
            Expanded(
              child:
                  (_currentQuery.isEmpty && _selectedCategory == null) ||
                      (_searchController.text.isNotEmpty &&
                          _searchController.text.length < 3 &&
                          _selectedCategory == null)
                  ? _buildEmptyState()
                  : _buildSearchResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search Row
          Row(
            children: [
              // Back Button
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Feather.arrow_left, size: 24),
                color: AppColors.heading,
              ),

              const SizedBox(width: 16),

              // Search Input Field
              Expanded(
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  decoration: InputDecoration(
                    // hintText: _selectedCategory != null
                    //     ? 'Search in $_selectedCategory...'
                    //     : 'Type at least 3 characters to search...',
                    hintStyle: TextStyle(color: AppColors.body),
                    prefixIcon: Icon(Feather.search, color: AppColors.body),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Character count indicator when typing
                              if (_searchController.text.length < 3)
                                Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _searchController.text.length == 2
                                        ? AppColors.primary.withValues(
                                            alpha: 0.2,
                                          )
                                        : AppColors.body.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${_searchController.text.length}/3',
                                    style: TextStyle(
                                      color: _searchController.text.length == 2
                                          ? AppColors.primary
                                          : AppColors.body,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              IconButton(
                                onPressed: _clearSearch,
                                icon: Icon(Feather.x, color: AppColors.body),
                              ),
                            ],
                          )
                        : null,
                    filled: true,
                    fillColor: const Color(0XFFF2F4F7),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                  textInputAction: TextInputAction.search,
                  onSubmitted: (query) {
                    // Allow search if query has at least 3 characters OR if category is selected
                    if (query.trim().length >= 3 ||
                        _selectedCategoryId != null) {
                      _performSearch();
                    }
                  },
                  onChanged: _onSearchTextChanged,
                  onTap: () {
                    // Focus the search field when tapped
                    _searchFocusNode.requestFocus();
                  },
                ),
              ),
            ],
          ),

          // Category Slider below search bar
          const SizedBox(height: 16),
          // Show selected category indicator
          if (_selectedCategory != null)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Feather.tag, size: 16, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    'Category: $_selectedCategory',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _clearCategory,
                    child: Icon(Feather.x, size: 16, color: AppColors.primary),
                  ),
                ],
              ),
            ),
          BlocBuilder<CategoriesBloc, CategoriesState>(
            builder: (context, state) {
              List<String> categories = ['All'];

              if (state is CategoriesLoaded) {
                categories.addAll(
                  state.categories.map((cat) => cat.name).toList(),
                );
              } else if (state is CategoriesLoading) {
                categories.addAll(['Loading...', 'Loading...', 'Loading...']);
              } else {
                categories.addAll([
                  'Clothing',
                  'Electronics',
                  'Home & Garden',
                  'Beauty',
                  'Sports',
                  'Books',
                  'Toys',
                  'Automotive',
                ]);
              }

              return CategoriesSlider(
                categories: categories,
                selectedIndex: _selectedCategory != null
                    ? categories.indexOf(_selectedCategory!)
                    : 0,
                onCategorySelected: (category) {
                  if (mounted) {
                    setState(() {
                      if (category == 'All') {
                        _selectedCategory = null;
                        _selectedCategoryId = null;
                        // Don't clear search text when clearing category
                      } else {
                        _selectedCategory = category;
                        // Find the category ID from the loaded categories
                        if (state is CategoriesLoaded) {
                          final categoryData = state.categories.firstWhere(
                            (cat) => cat.name == category,
                            orElse: () => ProductCategory(
                              id: '',
                              name: category,
                              productCount: 0,
                              isActive: true,
                            ),
                          );
                          _selectedCategoryId = categoryData.id;
                        }
                        // Don't change the search query text when selecting category
                        // Keep the current search text and just apply category filter
                      }
                    });
                  }

                  // Perform search when category changes (either selected or cleared)
                  _performSearch();
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildResultsSummary() {
    // Show results summary if there's a search query OR a category is selected
    if (_currentQuery.isEmpty && _selectedCategory == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Results Count and Category Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BlocBuilder<ProductsBloc, ProductsState>(
                  builder: (context, state) {
                    int itemCount = 0;
                    if (state is SearchProductsLoaded) {
                      itemCount = state.searchProducts.length;
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Show typing indicator when user is typing but hasn't reached 3 chars
                        if (_searchController.text.isNotEmpty &&
                            _searchController.text.length < 3)
                          Text(
                            'Type ${3 - _searchController.text.length} more character${3 - _searchController.text.length == 1 ? '' : 's'} to search...',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.italic,
                            ),
                          )
                        else if (state is SearchProductsLoaded)
                          Text(
                            '$itemCount Items found',
                            style: TextStyle(
                              color: AppColors.body,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        if (_currentQuery.isNotEmpty &&
                            _currentQuery.length >= 3)
                          Text(
                            'for "$_currentQuery"',
                            style: TextStyle(
                              color: AppColors.body,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        if (_selectedCategory != null)
                          Text(
                            _currentQuery.isNotEmpty &&
                                    _currentQuery.length >= 3
                                ? 'in $_selectedCategory'
                                : 'Category: $_selectedCategory',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return BlocBuilder<ProductsBloc, ProductsState>(
      builder: (context, state) {
        if (state is ProductsLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (state is ProductsError) {
          return _buildErrorState(state.message);
        }

        if (state is SearchProductsLoaded) {
          if (state.searchProducts.isEmpty) {
            return _buildNoResultsState();
          }

          return _buildProductGrid(state.searchProducts);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildProductGrid(List<Product> products) {
    return Column(
      children: [
        Expanded(
          child: GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: _getResponsiveAspectRatio(context),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: products.length + (_isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              // Show loading indicator at the end when loading more
              if (index >= products.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                );
              }

              final product = products[index];

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
                    ? '-${product.discountPercentage.toStringAsFixed(0)}%'
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
        ),

        // Load More Button or Loading Indicator
        if (_hasMoreItems && products.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: _isLoadingMore
                  ? const Column(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Loading more products...',
                          style: TextStyle(color: AppColors.body, fontSize: 14),
                        ),
                      ],
                    )
                  : ElevatedButton(
                      onPressed: _loadMoreItems,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('Load More'),
                    ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Show typing indicator when user is typing but hasn't reached 3 chars
          if (_searchController.text.isNotEmpty &&
              _searchController.text.length < 3)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.keyboard,
                    size: 48,
                    color: AppColors.primary.withValues(alpha: 0.6),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Keep typing to search',
                    style: TextStyle(
                      color: AppColors.heading,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Type at least 3 characters to see search results',
                    style: TextStyle(color: AppColors.body, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      '${_searchController.text.length}/3 characters',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            // Recent Searches
            _buildRecentSearches(),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildRecentSearches() {
    if (_searchHistory.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Searches',
              style: TextStyle(
                color: AppColors.heading,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                if (mounted) {
                  setState(() {
                    _searchHistory.clear();
                  });
                }
                _saveSearchHistory();
              },
              child: Text(
                'Clear All',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _searchHistory.take(6).map((search) {
            return GestureDetector(
              onTap: () {
                if (mounted) {
                  setState(() {
                    _currentQuery = search;
                    _searchController.text = search;
                    // Don't automatically clear category selection
                    // Let user decide if they want to keep category filter
                  });
                }
                _performSearch();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  search,
                  style: TextStyle(
                    color: AppColors.body,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: AppColors.body),
            const SizedBox(height: 16),
            Text(
              'No products found',
              style: TextStyle(
                color: AppColors.heading,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search terms or browse our categories',
              style: TextStyle(
                color: AppColors.body,
                fontSize: 14,

                // textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Search failed',
              style: TextStyle(
                color: AppColors.heading,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                color: AppColors.body,
                fontSize: 14,
                // textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _performSearch,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  /// Get responsive aspect ratio based on screen size
  double _getResponsiveAspectRatio(BuildContext context) {
    return Responsive.getProductCardAspectRatio(context);
  }
}
