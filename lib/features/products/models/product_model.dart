import 'package:equatable/equatable.dart';
import 'media_file_model.dart';
import 'seller_model.dart';

class Product extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? originalPrice;
  final double rating;
  final int reviewCount;
  final String category;
  final List<String> tags;
  final bool? inStock; // Made nullable
  final int stockQuantity;
  final Map<String, dynamic>? specifications;
  final DateTime createdAt;
  final DateTime updatedAt;
  // New fields to match backend structure
  final MediaFile? thumbnailImg;
  final List<MediaFile> photos;

  // Seller information
  final Seller? seller;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.rating,
    required this.reviewCount,
    required this.category,
    required this.tags,
    this.inStock, // Made nullable
    required this.stockQuantity,
    this.specifications,
    required this.createdAt,
    required this.updatedAt,
    this.thumbnailImg, // Made nullable
    this.photos = const [],
    this.seller,
  });

  // Discount percentage calculation
  double get discountPercentage {
    if (originalPrice == null || originalPrice == 0) return 0;
    return ((originalPrice! - price) / originalPrice! * 100).roundToDouble();
  }

  // Check if product has discount
  bool get hasDiscount => originalPrice != null && originalPrice! > price;

  // Get all image URLs including thumbnail and photos
  List<MediaFile> get allImageUrls {
    final List<MediaFile> allUrls = [];

    // Add thumbnail image first
    if (thumbnailImg != null) {
      allUrls.add(thumbnailImg!);
    } else {
      allUrls.add(
        MediaFile(
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
        ),
      );
    }

    // Add photos
    for (final photo in photos) {
      if (photo.url.isNotEmpty) {
        allUrls.add(photo);
      }
    }

    // Add fallback images if no MediaFile images
    if (allUrls.isEmpty && photos.isNotEmpty) {
      allUrls.addAll(photos);
    }

    return allUrls;
  }

  // Check if product is on sale
  bool get isOnSale => hasDiscount;

  // Get formatted price
  String get formattedPrice => '₹${price.toStringAsFixed(0)}';

  // Get formatted original price
  String get formattedOriginalPrice {
    if (originalPrice == null) return '';
    return '₹${originalPrice!.toStringAsFixed(0)}';
  }

  // Get formatted discount
  String get formattedDiscount {
    if (!hasDiscount) return '';
    return '-${discountPercentage.toStringAsFixed(0)}%';
  }

  // Copy with method
  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    double? originalPrice,
    double? rating,
    int? reviewCount,
    List<String>? images,
    String? thumbnailImage,
    String? category,
    List<String>? tags,
    bool? inStock, // Made nullable
    int? stockQuantity,
    Map<String, dynamic>? specifications,
    DateTime? createdAt,
    DateTime? updatedAt,
    MediaFile? thumbnailImg,
    List<MediaFile>? photos,
    Seller? seller,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      inStock: inStock ?? this.inStock, // Made nullable
      stockQuantity: stockQuantity ?? this.stockQuantity,
      specifications: specifications ?? this.specifications,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      thumbnailImg: thumbnailImg ?? this.thumbnailImg,
      photos: photos ?? this.photos,
      seller: seller ?? this.seller,
    );
  }

  // JSON serialization aligned to backend ProductResponseDto
  factory Product.fromJson(Map<String, dynamic> json) {
    // Helpers to normalize backend numeric/date/image structures
    double asDouble(dynamic value, {double fallback = 0.0}) {
      if (value == null) return fallback;
      if (value is num) return value.toDouble();
      if (value is String) {
        final parsed = double.tryParse(value);
        return parsed ?? fallback;
      }
      return fallback;
    }

    int asInt(dynamic value, {int fallback = 0}) {
      if (value == null) return fallback;
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) {
        final parsed = int.tryParse(value);
        return parsed ?? fallback;
      }
      return fallback;
    }

    DateTime asDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      return DateTime.tryParse(value.toString()) ?? DateTime.now();
    }

    // Parse MediaFile objects
    MediaFile? thumbnailMediaFile;
    List<MediaFile> photoMediaFiles = [];

    if (json['thumbnailImg'] is Map<String, dynamic>) {
      try {
        thumbnailMediaFile = MediaFile.fromJson(json['thumbnailImg']);
      } catch (e) {
        //
      }
    }

    // Handle photos array as MediaFile objects
    final photos = json['photos'];
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

    // Build image URLs from photos[] and thumbnailImg for backward compatibility
    final List<MediaFile> imageUrls = [];

    // Add photos URLs to images list
    for (final photo in photoMediaFiles) {
      if (photo.url.isNotEmpty) {
        imageUrls.add(photo);
      }
    }

    // Category name from categories[] or direct category field
    String categoryName = '';
    final categories = json['categories'];
    if (categories is List && categories.isNotEmpty) {
      final firstCat = categories.first;
      if (firstCat is Map<String, dynamic>) {
        categoryName = firstCat['name']?.toString() ?? '';
      }
    } else if (json['category'] != null) {
      categoryName = json['category'].toString();
    }

    // Parse seller information
    Seller? seller;
    if (json['seller'] is Map<String, dynamic>) {
      try {
        seller = Seller.fromJson(json['seller']);
      } catch (e) {
        // Handle parsing error silently
      }
    }

    final product = Product(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description:
          (json['longDescription']?.toString() ??
              json['shortDescription']?.toString() ??
              json['description']?.toString()) ??
          '',
      price: asDouble(
        json['salePrice'],
        fallback: asDouble(json['regularPrice']),
      ),
      originalPrice: json['regularPrice'] != null
          ? asDouble(json['regularPrice'])
          : null,
      rating: asDouble(json['rating'], fallback: 0.0),
      reviewCount: asInt(json['numOfSales'], fallback: 0),
      // thumbnailImage: thumbnailUrl,
      // images: imageUrls,
      category: categoryName,
      tags: json['tags'] is List
          ? List<String>.from((json['tags'] as List).map((e) => e.toString()))
          : <String>[],
      inStock: json['stock'] != null ? asInt(json['stock']) > 0 : null,
      stockQuantity: asInt(json['stock'], fallback: 0),
      specifications: null,
      createdAt: asDate(json['createdAt']),
      updatedAt: asDate(json['updatedAt']),
      thumbnailImg: thumbnailMediaFile,
      photos: photoMediaFiles,
      seller: seller,
    );
    return product;
  }

  // Helper method to safely parse boolean values
  static bool? _parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true';
    }
    if (value is int) {
      return value != 0;
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'originalPrice': originalPrice,
      'rating': rating,
      'reviewCount': reviewCount,
      // 'thumbnailImage': thumbnailImage,
      // 'images': images,
      'category': category,
      'tags': tags,
      'inStock': inStock,
      'stockQuantity': stockQuantity,
      'specifications': specifications,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'thumbnailImg': thumbnailImg?.toJson(),
      'photos': photos.map((photo) => photo.toJson()).toList(),
      'seller': seller?.toJson(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    price,
    originalPrice,
    rating,
    reviewCount,
    // thumbnailImage,
    // images,
    category,
    tags,
    inStock,
    stockQuantity,
    specifications,
    createdAt,
    updatedAt,
    thumbnailImg,
    photos,
    seller,
  ];

  @override
  String toString() {
    return 'Product(id: $id, name: $name, price: $price, category: $category)';
  }
}

// Product category model
class ProductCategory extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? image;
  final int productCount;
  final bool isActive;

  const ProductCategory({
    required this.id,
    required this.name,
    this.description,
    this.image,
    required this.productCount,
    required this.isActive,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      image:
          json['thumbnailImage'] != null &&
              json['thumbnailImage']['url'] != null
          ? json['thumbnailImage']['url'].toString()
          : json['image']?.toString(),
      productCount: json['productCount'] ?? 0,
      isActive:
          Product._parseBool(json['isActive']) ??
          true, // Use the same helper method
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image': image,
      'productCount': productCount,
      'isActive': isActive,
    };
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    image,
    productCount,
    isActive,
  ];
}

// Product filter model - matches backend ProductFilters structure
class ProductFilter extends Equatable {
  final String? search;
  final String? categoryId; // Keep for backward compatibility
  final List<String>? categoryIds; // New field for multiple categories
  final bool? isVariant;
  final bool? published;
  final bool? featured;
  final bool? approved;
  final double? minPrice;
  final double? maxPrice;
  // Additional fields for enhanced filtering
  final double? minRating;
  final bool? inStock;
  final List<String>? tags;
  final String? sortBy;
  final bool? sortAscending;
  // Pagination parameters
  final int? page;
  final int? limit;

  const ProductFilter({
    this.search,
    this.categoryId,
    this.categoryIds,
    this.isVariant,
    this.published,
    this.featured,
    this.approved,
    this.minPrice,
    this.maxPrice,
    this.minRating,
    this.inStock,
    this.tags,
    this.sortBy,
    this.sortAscending,
    this.page,
    this.limit,
  });

  ProductFilter copyWith({
    String? search,
    String? categoryId,
    List<String>? categoryIds,
    bool? isVariant,
    bool? published,
    bool? featured,
    bool? approved,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    bool? inStock,
    List<String>? tags,
    String? sortBy,
    bool? sortAscending,
    int? page,
    int? limit,
  }) {
    return ProductFilter(
      search: search ?? this.search,
      categoryId: categoryId ?? this.categoryId,
      categoryIds: categoryIds ?? this.categoryIds,
      isVariant: isVariant ?? this.isVariant,
      published: published ?? this.published,
      featured: featured ?? this.featured,
      approved: approved ?? this.approved,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minRating: minRating ?? this.minRating,
      inStock: inStock ?? this.inStock,
      tags: tags ?? this.tags,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
      page: page ?? this.page,
      limit: limit ?? this.limit,
    );
  }

  @override
  List<Object?> get props => [
    search,
    categoryId,
    categoryIds,
    isVariant,
    published,
    featured,
    approved,
    minPrice,
    maxPrice,
    minRating,
    inStock,
    tags,
    sortBy,
    sortAscending,
    page,
    limit,
  ];
}
