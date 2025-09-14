import 'package:rikhh_app/features/products/models/media_file_model.dart';
import 'package:rikhh_app/features/products/models/seller_model.dart';

import '../models/product_model.dart';
import '../services/products_api_service.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/app_config.dart';
import '../../../core/utils/app_logger.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

abstract class ProductsRepository {
  Future<ProductsResponse> getProducts({
    ProductFilter? filter,
    int page = 1,
    int limit = 20,
  });

  Future<Product> getProductById(String productId);

  Future<ProductsResponse> searchProducts(
    String query, {
    ProductFilter? filter,
  });

  Future<List<ProductCategory>> getCategories();

  Future<List<Product>> getProductsByCategory(
    String categoryId, {
    int page = 1,
    int limit = 20,
  });

  Future<List<Product>> getFeaturedProducts();

  Future<List<Product>> getNewArrivals();

  Future<List<Product>> getBestSellers();
}

class ProductsRepositoryImpl implements ProductsRepository {
  final ProductsApiService _apiService;

  ProductsRepositoryImpl()
    : _apiService = ProductsApiService(DioClient.instance, baseUrl: AppConfig.baseUrl);

  // Helper functions for parsing
  double _asDouble(dynamic value, {double fallback = 0.0}) {
    if (value == null) return fallback;
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      return parsed ?? fallback;
    }
    return fallback;
  }

  int _asInt(dynamic value, {int fallback = 0}) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value);
      return parsed ?? fallback;
    }
    return fallback;
  }

  @override
  Future<ProductsResponse> getProducts({
    ProductFilter? filter,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      // First, let's try to get the raw response to see what the API is actually returning
      Response? rawResponse;
      try {
        // Build filters object according to backend structure
        final Map<String, dynamic> filters = {};

        if (filter?.search != null && filter!.search!.isNotEmpty) {
          filters['search'] = filter.search;
        }

        if (filter?.categoryIds != null && filter!.categoryIds!.isNotEmpty) {
          filters['categoryIds'] = filter.categoryIds;
        } else if (filter?.categoryId != null) {
          filters['categoryId'] = filter!.categoryId;
        }

        if (filter?.minPrice != null) {
          filters['minPrice'] = filter!.minPrice;
        }

        if (filter?.maxPrice != null) {
          filters['maxPrice'] = filter!.maxPrice;
        }

        if (filter?.featured != null) {
          filters['featured'] = filter!.featured;
        }

        if (filter?.published != null) {
          filters['published'] = filter!.published;
        }

        if (filter?.approved != null) {
          filters['approved'] = filter!.approved;
        }

        if (filter?.isVariant != null) {
          filters['isVariant'] = filter!.isVariant;
        }

        // Convert filters to JSON string
        final filtersJson = filters.isNotEmpty ? jsonEncode(filters) : null;

        final dio = Dio();
        rawResponse = await dio.get(
          '${AppConfig.baseUrl}/v1/products/all',
          queryParameters: {
            'page': page,
            'limit': limit,
            if (filtersJson != null) 'filters': filtersJson,
            if (filter?.sortBy != null) 'sort': filter!.sortBy,
            if (filter?.sortAscending != null)
              'order': filter!.sortAscending! ? 'asc' : 'desc',
          },
        );
      } catch (rawError) {
        // Raw API call failed: $rawError
      }

      // Use the raw response we already got to parse products manually
      if (rawResponse != null &&
          rawResponse.statusCode == 200 &&
          rawResponse.data is Map) {
        final data = rawResponse.data as Map<String, dynamic>;

        // Handle the new backend response structure: { message, requestId, data: { data: [...], meta: {...} }, code }
        if (data.containsKey('data') && data['data'] is Map) {
          final productsData = data['data'] as Map<String, dynamic>;
          if (productsData.containsKey('data') &&
              productsData['data'] is List) {
            final productsList = productsData['data'] as List<dynamic>;

            final List<Product> products = [];
            for (final productJson in productsList) {
              try {
                if (productJson is Map<String, dynamic>) {
                  // Map the API fields to our Product model fields
                  final double salePriceVal = _asDouble(
                    productJson['salePrice'],
                  );
                  final double regularPriceVal = _asDouble(
                    productJson['regularPrice'],
                  );
                  final double resolvedPrice = salePriceVal > 0
                      ? salePriceVal
                      : regularPriceVal;
                  final double? resolvedOriginal =
                      salePriceVal > 0 && regularPriceVal > 0
                      ? regularPriceVal
                      : null;

                  MediaFile? thumbnailMediaFile;

                  // Handle thumbnailImg as MediaFile
                  if (productJson['thumbnailImg'] is Map<String, dynamic>) {
                    try {
                      thumbnailMediaFile = MediaFile.fromJson(
                        productJson['thumbnailImg'],
                      );
                    } catch (e) {
                      //
                    }
                  } else {
                    thumbnailMediaFile = MediaFile(
                      id: '1',
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                      scope: 'scope',
                      uri: 'uri',
                      url:
                          'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400&h=400&fit=crop',
                      fileName: 'fileName',
                      mimetype: 'mimetype',
                      size: 120,
                    );
                  }

                  final product = Product(
                    id: productJson['id']?.toString() ?? '',
                    name: productJson['name']?.toString() ?? 'Unnamed Product',
                    description:
                        productJson['longDescription']?.toString() ??
                        productJson['shortDescription']?.toString() ??
                        'No description available',
                    price: resolvedPrice,
                    originalPrice: resolvedOriginal,
                    rating: _asDouble(productJson['rating'], fallback: 0.0),
                    reviewCount: _asInt(productJson['numOfSales'], fallback: 0),
                    // thumbnailImage: productJson['thumbnailImg'] != null
                    //     ? productJson['thumbnailImg']['url']?.toString() ?? ''
                    //     : '',
                    // images: _extractImageUrls(productJson),
                    thumbnailImg: thumbnailMediaFile!,
                    category:
                        productJson['category']?.toString() ?? 'Uncategorized',
                    tags: productJson['tags'] != null
                        ? List<String>.from(productJson['tags'])
                        : [],
                    inStock: productJson['stock'] != null
                        ? _asInt(productJson['stock']) > 0
                        : true,
                    stockQuantity: _asInt(productJson['stock'], fallback: 0),
                    specifications: null,
                    createdAt: productJson['createdAt'] != null
                        ? DateTime.parse(productJson['createdAt'].toString())
                        : DateTime.now(),
                    updatedAt: productJson['updatedAt'] != null
                        ? DateTime.parse(productJson['updatedAt'].toString())
                        : DateTime.now(),
                  );

                  products.add(product);
                }
              } catch (e) {
                // Error parsing product: $e
                continue;
              }
            }

            if (products.isNotEmpty) {
              // Create response with pagination info from raw response
              final meta = productsData['meta'] as Map<String, dynamic>?;
              if (meta != null) {
                return ProductsResponse(
                  data: products,
                  meta: PaginationMeta(
                    total: _asInt(meta['total']),
                    page: _asInt(meta['page']),
                    limit: _asInt(meta['limit']),
                    totalPages: _asInt(meta['totalPages']),
                  ),
                );
              } else {
                // Fallback if meta is not available
                return ProductsResponse(
                  data: products,
                  meta: PaginationMeta(
                    total: products.length,
                    page: page,
                    limit: limit,
                    totalPages: 1,
                  ),
                );
              }
            }
          }
        }
      }

      // Fallback to the original API service if raw parsing fails
      try {
        // Build filters object for fallback API call
        final Map<String, dynamic> fallbackFilters = {};

        if (filter?.search != null && filter!.search!.isNotEmpty) {
          fallbackFilters['search'] = filter.search;
        }

        if (filter?.categoryIds != null && filter!.categoryIds!.isNotEmpty) {
          fallbackFilters['categoryIds'] = filter.categoryIds;
        } else if (filter?.categoryId != null) {
          fallbackFilters['categoryId'] = filter!.categoryId;
        }

        if (filter?.minPrice != null) {
          fallbackFilters['minPrice'] = filter!.minPrice;
        }

        if (filter?.maxPrice != null) {
          fallbackFilters['maxPrice'] = filter!.maxPrice;
        }

        if (filter?.featured != null) {
          fallbackFilters['featured'] = filter!.featured;
        }

        if (filter?.published != null) {
          fallbackFilters['published'] = filter!.published;
        }

        if (filter?.approved != null) {
          fallbackFilters['approved'] = filter!.approved;
        }

        if (filter?.isVariant != null) {
          fallbackFilters['isVariant'] = filter!.isVariant;
        }

        // Convert filters to JSON string
        final fallbackFiltersJson = fallbackFilters.isNotEmpty
            ? jsonEncode(fallbackFilters)
            : null;

        final response = await _apiService.getProducts(
          page: page,
          limit: limit,
          filters: fallbackFiltersJson,
          sort: filter?.sortBy,
          order: filter?.sortAscending == true ? 'asc' : 'desc',
        );

        // The API service now returns ProductsResponse directly
        return response;
      } catch (apiError) {
        rethrow;
      }
    } catch (e) {
      return ProductsResponse(
        data: [],
        meta: PaginationMeta(total: 0, page: page, limit: limit, totalPages: 1),
      );
    }
  }

  @override
  Future<Product> getProductById(String productId) async {
    try {
      final response = await _apiService.getProductById(productId);

      if (response.success) {
        return response.data;
      } else {
        throw Exception(response.message ?? 'Failed to load product');
      }
    } catch (e) {
      // Fallback to mock data if API fails
      return _generateMockProduct(productId);
    }
  }

  @override
  Future<ProductsResponse> searchProducts(
    String query, {
    ProductFilter? filter,
  }) async {
    // Extract pagination from filter
    final page = filter?.page ?? 1;
    final limit = filter?.limit ?? 20;
    try {
      // Build filters object according to backend structure
      final Map<String, dynamic> filters = {};

      if (query.isNotEmpty) {
        // Try different search parameter names that backend might expect
        filters['search'] = query;
      }

      if (filter?.categoryIds != null && filter!.categoryIds!.isNotEmpty) {
        filters['categoryIds'] = filter.categoryIds;
      } else if (filter?.categoryId != null) {
        filters['categoryId'] = filter!.categoryId;
      }

      if (filter?.minPrice != null) {
        filters['minPrice'] = filter!.minPrice;
      }

      if (filter?.maxPrice != null) {
        filters['maxPrice'] = filter!.maxPrice;
      }

      if (filter?.featured != null) {
        filters['featured'] = filter!.featured;
      }

      if (filter?.published != null) {
        filters['published'] = filter!.published;
      }

      if (filter?.approved != null) {
        filters['approved'] = filter!.approved;
      }

      if (filter?.isVariant != null) {
        filters['isVariant'] = filter!.isVariant;
      }

      // Convert filters to JSON string
      final filtersJson = filters.isNotEmpty ? jsonEncode(filters) : null;

      // Make a direct API call to get the raw response
      final dio = Dio();

      // Try different search parameter approaches
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (filter?.sortBy != null) 'sort': filter!.sortBy,
        if (filter?.sortAscending != null)
          'order': filter!.sortAscending! ? 'asc' : 'desc',
      };

      // Add filters if available
      if (filtersJson != null) {
        queryParams['filters'] = filtersJson;
      }

      final rawResponse = await dio.get(
        '${AppConfig.baseUrl}/v1/products/all',
        queryParameters: queryParams,
      );
      if (rawResponse.statusCode == 200 && rawResponse.data is Map) {
        final data = rawResponse.data as Map<String, dynamic>;

        // Handle the backend response structure: { message, requestId, data: { data: [...], meta: {...} }, code }
        if (data.containsKey('data') && data['data'] is Map) {
          final productsData = data['data'] as Map<String, dynamic>;
          if (productsData.containsKey('data') &&
              productsData['data'] is List) {
            final productsList = productsData['data'] as List<dynamic>;

            final products = await _parseProductsFromRawResponse(productsList);

            if (products.isNotEmpty) {
              // Create response with pagination info from raw response
              final meta = productsData['meta'] as Map<String, dynamic>?;
              if (meta != null) {
                return ProductsResponse(
                  data: products,
                  meta: PaginationMeta(
                    total: _asInt(meta['total']),
                    page: _asInt(meta['page']),
                    limit: _asInt(meta['limit']),
                    totalPages: _asInt(meta['totalPages']),
                  ),
                );
              } else {
                // Fallback if meta is not available
                return ProductsResponse(
                  data: products,
                  meta: PaginationMeta(
                    total: products.length,
                    page: page,
                    limit: limit,
                    totalPages: 1,
                  ),
                );
              }
            }
          }
        }
      }

      return ProductsResponse(
        data: [],
        meta: PaginationMeta(total: 0, page: 1, limit: 20, totalPages: 1),
      );
    } catch (e) {
      return ProductsResponse(
        data: [],
        meta: PaginationMeta(total: 0, page: 1, limit: 20, totalPages: 1),
      );
    }
  }

  @override
  Future<List<ProductCategory>> getCategories() async {
    try {
      final response = await _apiService.getCategories();

      // Parse the categories from the normalized data structure (list)
      final categoriesData = response.data;

      final List<ProductCategory> categories = [];

      for (final categoryJson in categoriesData) {
        try {
          // Handle null values safely and validate data
          final id = categoryJson['id']?.toString() ?? '';
          final name = categoryJson['name']?.toString();
          final description =
              categoryJson['description']?.toString() ?? 'No description';
          
          // Extract image URL from thumbnailImage.url or fallback to image
          String? image;
          if (categoryJson['thumbnailImage'] != null && 
              categoryJson['thumbnailImage']['url'] != null) {
            image = categoryJson['thumbnailImage']['url'].toString();
          } else {
            image = categoryJson['image']?.toString();
          }
          
          final isActive = categoryJson['isActive'] as bool? ?? true;

          // Skip categories with null or empty names
          if (id.isNotEmpty && name != null && name.isNotEmpty) {
            categories.add(
              ProductCategory(
                id: id,
                name: name,
                description: description,
                image: image,
                productCount: 0, // API doesn't provide this yet
                isActive: isActive,
              ),
            );
          }
        } catch (e) {
          continue; // Skip malformed categories
        }
      }

      if (categories.isNotEmpty) {
        return categories;
      } else {
        AppLogger.warning(
          'ProductsRepository: No valid categories found in response',
        );
        // Return test categories for debugging
        return _getTestCategories();
      }
    } catch (e) {
      AppLogger.error('ProductsRepository: Error getting categories - $e');
      // Return test categories for debugging
      return _getTestCategories();
    }
  }

  List<ProductCategory> _getTestCategories() {
    return [
      ProductCategory(
        id: '1',
        name: 'Electronics',
        description: 'Electronic devices and gadgets',
        image:
            'https://images.unsplash.com/photo-1498049794561-7780e7231661?w=100&h=100&fit=crop',
        productCount: 0,
        isActive: true,
      ),
      ProductCategory(
        id: '2',
        name: 'Fashion',
        description: 'Clothing and accessories',
        image:
            'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=100&h=100&fit=crop',
        productCount: 0,
        isActive: true,
      ),
      ProductCategory(
        id: '3',
        name: 'Home & Garden',
        description: 'Home improvement and garden supplies',
        image:
            'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=100&h=100&fit=crop',
        productCount: 0,
        isActive: true,
      ),
      ProductCategory(
        id: '4',
        name: 'Sports',
        description: 'Sports equipment and gear',
        image:
            'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=100&h=100&fit=crop',
        productCount: 0,
        isActive: true,
      ),
      ProductCategory(
        id: '5',
        name: 'Books',
        description: 'Books and educational materials',
        image:
            'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=100&h=100&fit=crop',
        productCount: 0,
        isActive: true,
      ),
      ProductCategory(
        id: '6',
        name: 'Beauty',
        description: 'Beauty and personal care products',
        image:
            'https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=100&h=100&fit=crop',
        productCount: 0,
        isActive: true,
      ),
    ];
  }

  @override
  Future<List<Product>> getProductsByCategory(
    String categoryId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiService.getProductsByCategory(
        categoryId,
        page: page,
        limit: limit,
      );

      // The API service now returns ProductsResponse directly
      return response.data;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<Product>> getFeaturedProducts() async {
    try {
      final response = await _apiService.getFeaturedProducts();

      // Handle the backend response structure: { message, requestId, data: { data: [...], meta: {...} }, code }
      if (response != null && response['data'] != null) {
        final productsData = response['data'] as Map<String, dynamic>;
        if (productsData['data'] is List) {
          final productsList = productsData['data'] as List<dynamic>;
          final products = await _parseProductsFromRawResponse(productsList);
          if (products.isNotEmpty) {
            return products;
          }
        }
      }
      return [];
      // Fallback if parsing fails
      // return await _getFallbackFeaturedProducts();
    } catch (e) {
      return await _getFallbackFeaturedProducts();
    }
  }

  Future<List<Product>> _getFallbackFeaturedProducts() async {
    try {
      // Get products and filter for featured ones
      final allProductsResponse = await getProducts(
        limit: 20,
      ); // Get more products to find featured ones
      final allProducts = allProductsResponse.data;

      if (allProducts.isNotEmpty) {
        // Try to identify which products should be featured based on attributes
        List<Product> featuredProducts = [];

        // Priority 1: Products with high ratings and sales
        final highRatedProducts = allProducts
            .where((p) => p.rating >= 4.0 && p.reviewCount > 10)
            .take(4)
            .toList();
        featuredProducts.addAll(highRatedProducts);

        // Priority 2: Products with discounts (on sale)
        if (featuredProducts.length < 8) {
          final discountedProducts = allProducts
              .where((p) => p.hasDiscount && !featuredProducts.contains(p))
              .take(8 - featuredProducts.length)
              .toList();
          featuredProducts.addAll(discountedProducts);
        }

        // Priority 3: Fill remaining slots with any available products
        if (featuredProducts.length < 8) {
          final remainingProducts = allProducts
              .where((p) => !featuredProducts.contains(p))
              .take(8 - featuredProducts.length)
              .toList();
          featuredProducts.addAll(remainingProducts);
        }

        // Ensure we don't exceed 8 products
        featuredProducts = featuredProducts.take(8).toList();

        return featuredProducts;
      }
    } catch (e) {
      // Fallback products also failed: $e
    }

    return [];
  }

  @override
  Future<List<Product>> getNewArrivals() async {
    try {
      final response = await _apiService.getNewArrivals();

      // Handle the backend response structure: { message, requestId, data: { data: [...], meta: {...} }, code }
      if (response != null && response['data'] != null) {
        final productsData = response['data'] as Map<String, dynamic>;
        if (productsData['data'] is List) {
          final productsList = productsData['data'] as List<dynamic>;
          final products = await _parseProductsFromRawResponse(productsList);
          if (products.isNotEmpty) {
            return products;
          }
        }
      }

      // Fallback if parsing fails
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<Product>> getBestSellers() async {
    try {
      final response = await _apiService.getBestSellers();

      // Handle the backend response structure: { message, requestId, data: { data: [...], meta: {...} }, code }
      if (response != null && response['data'] != null) {
        final productsData = response['data'] as Map<String, dynamic>;
        if (productsData['data'] is List) {
          final productsList = productsData['data'] as List<dynamic>;
          final products = await _parseProductsFromRawResponse(productsList);
          if (products.isNotEmpty) {
            return products;
          }
        }
      }

      // Fallback if parsing fails
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<Product>> _parseProductsFromRawResponse(
    List<dynamic> productsList,
  ) async {
    final List<Product> products = [];
    for (final productJson in productsList) {
      try {
        if (productJson is Map<String, dynamic>) {
          // Map the API fields to our Product model fields
          final double salePriceVal = _asDouble(productJson['salePrice']);
          final double regularPriceVal = _asDouble(productJson['regularPrice']);
          final double resolvedPrice = salePriceVal > 0
              ? salePriceVal
              : regularPriceVal;
          final double? resolvedOriginal =
              salePriceVal > 0 && regularPriceVal > 0 ? regularPriceVal : null;

          MediaFile? thumbnailMediaFile;
          List<MediaFile> photoMediaFiles = [];

          // Handle thumbnailImg as MediaFile
          if (productJson['thumbnailImg'] is Map<String, dynamic>) {
            try {
              thumbnailMediaFile = MediaFile.fromJson(
                productJson['thumbnailImg'],
              );
            } catch (e) {
              //
            }
          }

          final photos = productJson['photos'];
          if (photos is List) {
            for (final photo in photos) {
              if (photo is Map<String, dynamic>) {
                try {
                  final mediaFile = MediaFile.fromJson(photo);
                  photoMediaFiles.add(mediaFile);
                } catch (e) {
                  //
                }
              }
            }
          }

          // Handle category
          String categoryName = 'Uncategorized';
          if (productJson['category'] != null) {
            categoryName = productJson['category'].toString();
          } else if (productJson['categories'] is List &&
              (productJson['categories'] as List).isNotEmpty) {
            final firstCat = (productJson['categories'] as List).first;
            if (firstCat is Map<String, dynamic>) {
              categoryName = firstCat['name']?.toString() ?? 'Uncategorized';
            }
          }

          final seller =
              (productJson['seller'] != null &&
                  productJson['seller'] is Map<String, dynamic>)
              ? Seller.fromJson(productJson['seller'])
              : Seller(id: '', businessName: 'Unknown Seller');

          final product = Product(
            id: productJson['id']?.toString() ?? '',
            name: productJson['name']?.toString() ?? 'Unnamed Product',
            description:
                productJson['longDescription']?.toString() ??
                productJson['shortDescription']?.toString() ??
                'No description available',
            price: resolvedPrice,
            originalPrice: resolvedOriginal,
            rating: _asDouble(productJson['rating'], fallback: 0.0),
            reviewCount: _asInt(productJson['numOfSales'], fallback: 0),
            thumbnailImg: thumbnailMediaFile!,
            photos: photoMediaFiles,
            // images: imageUrls,
            category: categoryName,
            tags: productJson['tags'] != null
                ? List<String>.from(productJson['tags'])
                : [],
            inStock: productJson['stock'] != null
                ? _asInt(productJson['stock']) > 0
                : true,
            stockQuantity: _asInt(productJson['stock'], fallback: 0),
            specifications: null,
            createdAt: productJson['createdAt'] != null
                ? DateTime.parse(productJson['createdAt'].toString())
                : DateTime.now(),
            updatedAt: productJson['updatedAt'] != null
                ? DateTime.parse(productJson['updatedAt'].toString())
                : DateTime.now(),
            seller: seller,
          );

          products.add(product);
        }
      } catch (e) {
        continue;
      }
    }

    return products;
  }

  // Helper method to generate a single mock product
  Product _generateMockProduct(String productId) {
    return Product(
      id: productId,
      name: 'Sample Product - $productId',
      description:
          'This is a comprehensive description for the product with ID: $productId. It includes detailed information about features, specifications, and benefits.',
      price: 79.99,
      originalPrice: 99.99,
      rating: 4.5,
      reviewCount: 25,
      category: 'Electronics',
      tags: ['trending', 'popular', 'featured'],
      inStock: true,
      stockQuantity: 75,
      specifications: {
        'Brand': 'Sample Brand',
        'Model': 'Sample Model',
        'Color': 'Black',
        'Size': 'Medium',
        'Weight': '500g',
        'Dimensions': '10 x 5 x 2 cm',
        'Material': 'Premium Quality',
        'Warranty': '1 Year',
      },
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      // Mock MediaFile objects for testing
      thumbnailImg: MediaFile(
        id: '1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        scope: 'scope',
        uri: 'uri',
        url:
            'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400&h=400&fit=crop',
        fileName: 'fileName',
        mimetype: 'mimetype',
        size: 120,
      ), // Will use thumbnailImage fallback
      photos: [], // Empty for mock data
    );
  }
}
