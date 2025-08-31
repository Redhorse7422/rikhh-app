import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/product_model.dart';
import '../repositories/products_repository.dart';

// Events
abstract class ProductsEvent extends Equatable {
  const ProductsEvent();

  @override
  List<Object?> get props => [];
}

class LoadProducts extends ProductsEvent {
  final ProductFilter? filter;
  final int page;
  final int limit;

  const LoadProducts({this.filter, this.page = 1, this.limit = 20});

  @override
  List<Object?> get props => [filter, page, limit];
}

class LoadFeaturedProducts extends ProductsEvent {
  final ProductFilter? filter;
  final int page;
  final int limit;
  const LoadFeaturedProducts({this.filter, this.page = 1, this.limit = 20});

  @override
  List<Object?> get props => [filter, page, limit];
}

class LoadProductById extends ProductsEvent {
  final String productId;

  const LoadProductById(this.productId);

  @override
  List<Object> get props => [productId];
}

class SearchProducts extends ProductsEvent {
  final String query;
  final ProductFilter? filter;

  const SearchProducts(this.query, {this.filter});

  @override
  List<Object?> get props => [query, filter];
}

class RefreshProducts extends ProductsEvent {
  final ProductFilter? filter;

  const RefreshProducts({this.filter});

  @override
  List<Object?> get props => [filter];
}

class LoadMoreProducts extends ProductsEvent {
  final ProductFilter? filter;

  const LoadMoreProducts({this.filter});

  @override
  List<Object?> get props => [filter];
}

class LoadMoreSearchProducts extends ProductsEvent {
  final ProductFilter? filter;

  const LoadMoreSearchProducts({this.filter});

  @override
  List<Object?> get props => [filter];
}

class RestoreFeaturedProducts extends ProductsEvent {
  const RestoreFeaturedProducts();

  @override
  List<Object> get props => [];
}



// States
abstract class ProductsState extends Equatable {
  const ProductsState();

  @override
  List<Object?> get props => [];
}

class ProductsInitial extends ProductsState {}

class ProductsLoading extends ProductsState {}

class ProductsLoaded extends ProductsState {
  final List<Product> products;
  final bool hasReachedMax;
  final int currentPage;
  final ProductFilter? currentFilter;
  final String? searchQuery;

  const ProductsLoaded({
    required this.products,
    required this.hasReachedMax,
    required this.currentPage,
    this.currentFilter,
    this.searchQuery,
  });

  ProductsLoaded copyWith({
    List<Product>? products,
    bool? hasReachedMax,
    int? currentPage,
    ProductFilter? currentFilter,
    String? searchQuery,
  }) {
    return ProductsLoaded(
      products: products ?? this.products,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      currentFilter: currentFilter ?? this.currentFilter,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
    products,
    hasReachedMax,
    currentPage,
    currentFilter,
    searchQuery,
  ];
}

// New state for featured products
class FeaturedProductsLoaded extends ProductsState {
  final List<Product> featuredProducts;
  final bool hasReachedMax;
  final int currentPage;

  const FeaturedProductsLoaded({
    required this.featuredProducts,
    this.hasReachedMax = true,
    this.currentPage = 1,
  });

  @override
  List<Object?> get props => [featuredProducts, hasReachedMax, currentPage];
}

// New state for search results
class SearchProductsLoaded extends ProductsState {
  final List<Product> searchProducts;
  final bool hasReachedMax;
  final int currentPage;
  final ProductFilter? currentFilter;
  final String searchQuery;

  const SearchProductsLoaded({
    required this.searchProducts,
    required this.hasReachedMax,
    required this.currentPage,
    this.currentFilter,
    required this.searchQuery,
  });

  SearchProductsLoaded copyWith({
    List<Product>? searchProducts,
    bool? hasReachedMax,
    int? currentPage,
    ProductFilter? currentFilter,
    String? searchQuery,
  }) {
    return SearchProductsLoaded(
      searchProducts: searchProducts ?? this.searchProducts,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      currentFilter: currentFilter ?? this.currentFilter,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
    searchProducts,
    hasReachedMax,
    currentPage,
    currentFilter,
    searchQuery,
  ];
}

class ProductDetailLoaded extends ProductsState {
  final Product product;

  const ProductDetailLoaded(this.product);

  @override
  List<Object> get props => [product];
}

class ProductsError extends ProductsState {
  final String message;

  const ProductsError(this.message);

  @override
  List<Object> get props => [message];
}

// BLoC
class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  final ProductsRepository _productsRepository;
  
  // Separate state for featured products
  List<Product> _featuredProducts = [];
  bool _featuredProductsLoaded = false;

  ProductsBloc({required ProductsRepository productsRepository})
    : _productsRepository = productsRepository,
      super(ProductsInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<LoadFeaturedProducts>(_onLoadFeaturedProducts);
    on<LoadProductById>(_onLoadProductById);
    on<SearchProducts>(_onSearchProducts);
    on<RefreshProducts>(_onRefreshProducts);
    on<LoadMoreProducts>(_onLoadMoreProducts);
    on<LoadMoreSearchProducts>(_onLoadMoreSearchProducts);
    on<RestoreFeaturedProducts>(_onRestoreFeaturedProducts);
  }

  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<ProductsState> emit,
  ) async {
    try {
      emit(ProductsLoading());

      final response = await _productsRepository.getProducts(
        filter: event.filter,
        page: event.page,
        limit: event.limit,
      );
      final hasReachedMax = response.meta.page >= response.meta.totalPages;

      emit(
        ProductsLoaded(
          products: response.data,
          hasReachedMax: hasReachedMax,
          currentPage: response.meta.page,
          currentFilter: event.filter,
        ),
      );
    } catch (e) {
      emit(ProductsError(e.toString()));
    }
  }

  Future<void> _onLoadFeaturedProducts(
    LoadFeaturedProducts event,
    Emitter<ProductsState> emit,
  ) async {
    try {
      // Only emit loading if we haven't loaded featured products yet
      if (!_featuredProductsLoaded) {
        emit(ProductsLoading());
      }

      final products = await _productsRepository.getFeaturedProducts();
      
      _featuredProducts = products;
      _featuredProductsLoaded = true;

      emit(
        FeaturedProductsLoaded(
          featuredProducts: products,
          hasReachedMax: true, // Featured products are typically limited
          currentPage: 1,
        ),
      );
    } catch (e) {
      emit(ProductsError(e.toString()));
    }
  }

  Future<void> _onLoadProductById(
    LoadProductById event,
    Emitter<ProductsState> emit,
  ) async {
    try {
      emit(ProductsLoading());

      final product = await _productsRepository.getProductById(event.productId);

      emit(ProductDetailLoaded(product));
    } catch (e) {
      emit(ProductsError(e.toString()));
    }
  }

  Future<void> _onSearchProducts(
    SearchProducts event,
    Emitter<ProductsState> emit,
  ) async {
    try {
      // Always show loading for new searches
      emit(ProductsLoading());

      final response = await _productsRepository.searchProducts(
        event.query,
        filter: event.filter,
      );

      final hasReachedMax = response.meta.page >= response.meta.totalPages;
      
      emit(
        SearchProductsLoaded(
          searchProducts: response.data,
          hasReachedMax: hasReachedMax,
          currentPage: response.meta.page,
          currentFilter: event.filter,
          searchQuery: event.query,
        ),
      );
    } catch (e) {
      emit(ProductsError(e.toString()));
    }
  }

  Future<void> _onRefreshProducts(
    RefreshProducts event,
    Emitter<ProductsState> emit,
  ) async {
    try {
      final response = await _productsRepository.getProducts(
        filter: event.filter,
        page: 1,
        limit: 20,
      );

      emit(
        ProductsLoaded(
          products: response.data,
          currentPage: response.meta.page,
          currentFilter: event.filter,
          hasReachedMax: response.meta.page >= response.meta.totalPages,
        ),
      );
    } catch (e) {
      emit(ProductsError(e.toString()));
    }
  }

  Future<void> _onLoadMoreProducts(
    LoadMoreProducts event,
    Emitter<ProductsState> emit,
  ) async {
    try {
      final currentState = state;
      
      // Handle ProductsLoaded state
      if (currentState is ProductsLoaded && !currentState.hasReachedMax) {
        final nextPage = currentState.currentPage + 1;
        
        final response = await _productsRepository.getProducts(
          filter: event.filter ?? currentState.currentFilter,
          page: nextPage,
          limit: 20,
        );

        final hasReachedMax = response.meta.page >= response.meta.totalPages;
        final allProducts = [...currentState.products, ...response.data];

        emit(
          currentState.copyWith(
            products: allProducts,
            hasReachedMax: hasReachedMax,
            currentPage: response.meta.page,
          ),
        );
      }
      
      // Handle SearchProductsLoaded state
      else if (currentState is SearchProductsLoaded && !currentState.hasReachedMax) {
        final nextPage = currentState.currentPage + 1;
        
        // Create a new filter with the next page
        final nextPageFilter = currentState.currentFilter?.copyWith(page: nextPage) ?? 
            ProductFilter(page: nextPage, limit: 20);
        
        final response = await _productsRepository.searchProducts(
          currentState.searchQuery,
          filter: nextPageFilter,
        );

        final hasReachedMax = response.meta.page >= response.meta.totalPages;
        final allProducts = [...currentState.searchProducts, ...response.data];

        emit(
          currentState.copyWith(
            searchProducts: allProducts,
            hasReachedMax: hasReachedMax,
            currentPage: response.meta.page,
          ),
        );
      }
    } catch (e) {
      emit(ProductsError(e.toString()));
    }
  }

  Future<void> _onLoadMoreSearchProducts(
    LoadMoreSearchProducts event,
    Emitter<ProductsState> emit,
  ) async {
    try {
      final currentState = state;
      
      if (currentState is SearchProductsLoaded && !currentState.hasReachedMax) {
        final nextPage = currentState.currentPage + 1;
        
        // Create a new filter with the next page
        final nextPageFilter = currentState.currentFilter?.copyWith(page: nextPage) ?? 
            ProductFilter(page: nextPage, limit: 20);
        
        final response = await _productsRepository.searchProducts(
          currentState.searchQuery,
          filter: nextPageFilter,
        );

        final hasReachedMax = response.meta.page >= response.meta.totalPages;
        final allProducts = [...currentState.searchProducts, ...response.data];

        emit(
          currentState.copyWith(
            searchProducts: allProducts,
            hasReachedMax: hasReachedMax,
            currentPage: response.meta.page,
          ),
        );
      }
    } catch (e) {
      emit(ProductsError(e.toString()));
    }
  }

  Future<void> _onRestoreFeaturedProducts(
    RestoreFeaturedProducts event,
    Emitter<ProductsState> emit,
  ) async {
    try {
      // If we already have featured products loaded, use them
      if (_featuredProductsLoaded && _featuredProducts.isNotEmpty) {
        emit(
          FeaturedProductsLoaded(
            featuredProducts: _featuredProducts,
            hasReachedMax: true,
            currentPage: 1,
          ),
        );
      } else {
        // Load featured products if not already loaded
        final products = await _productsRepository.getFeaturedProducts();
        _featuredProducts = products;
        _featuredProductsLoaded = true;

        emit(
          FeaturedProductsLoaded(
            featuredProducts: products,
            hasReachedMax: true,
            currentPage: 1,
          ),
        );
      }
    } catch (e) {
      emit(ProductsError(e.toString()));
    }
  }

  // Helper method to get current featured products
  List<Product> getFeaturedProducts() {
    return _featuredProducts;
  }

  // Helper method to check if featured products are loaded
  bool get isFeaturedProductsLoaded => _featuredProductsLoaded;
}
