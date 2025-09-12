import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:json_annotation/json_annotation.dart';
import '../models/product_model.dart';

part 'products_api_service.g.dart';

@RestApi(baseUrl: "")
abstract class ProductsApiService {
  factory ProductsApiService(
    Dio dio, {
    String? baseUrl,
    ParseErrorLogger? errorLogger,
  }) = _ProductsApiService;

  @GET('/v1/products/all')
  Future<ProductsResponse> getProducts({
    @Query('page') int page = 1,
    @Query('limit') int limit = 20,
    @Query('filters') String? filters, // Send filters as JSON string
    @Query('sort') String? sort,
    @Query('order') String? order,
  });

  @GET('/v1/products/{id}')
  Future<ProductResponse> getProductById(@Path('id') String id);

  @GET('/v1/products/featured')
  Future<dynamic> getFeaturedProducts({
    @Query('page') int page = 1,
    @Query('limit') int limit = 20,
    @Query('sortBy') String? sortBy,
    @Query('sortOrder') String? sortOrder,
    @Query('featured') bool? featured,
  });

  @GET('/v1/products/new-arrivals')
  Future<dynamic> getNewArrivals();

  @GET('/v1/products/best-sellers')
  Future<dynamic> getBestSellers();

  @GET('/v1/categories/all/unrestricted')
  Future<CategoriesResponse> getCategories();

  @GET('/v1/categories/{id}/products')
  Future<ProductsResponse> getProductsByCategory(
    @Path('id') String categoryId, {
    @Query('page') int page = 1,
    @Query('limit') int limit = 20,
  });
}

// Response Models - Updated to match backend PaginatedResponseDto structure
@JsonSerializable()
class ProductsResponse {
  final List<Product> data;
  final PaginationMeta meta;

  ProductsResponse({required this.data, required this.meta});

  factory ProductsResponse.fromJson(Map<String, dynamic> json) =>
      _$ProductsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ProductsResponseToJson(this);
}

@JsonSerializable()
class PaginationMeta {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  PaginationMeta({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) =>
      _$PaginationMetaFromJson(json);
  Map<String, dynamic> toJson() => _$PaginationMetaToJson(this);
}

@JsonSerializable()
class ProductResponse {
  final bool success;
  final Product data;
  final String? message;

  ProductResponse({required this.success, required this.data, this.message});

  factory ProductResponse.fromJson(Map<String, dynamic> json) =>
      _$ProductResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ProductResponseToJson(this);
}

@JsonSerializable()
class CategoriesResponse {
  final String message;
  final String requestId;
  @JsonKey(fromJson: _parseCategoriesData)
  final List<Map<String, dynamic>> data;

  CategoriesResponse({
    required this.message,
    required this.requestId,
    required this.data,
  });

  factory CategoriesResponse.fromJson(Map<String, dynamic> json) =>
      _$CategoriesResponseFromJson(json);
  Map<String, dynamic> toJson() => _$CategoriesResponseToJson(this);
}

List<Map<String, dynamic>> _parseCategoriesData(Object? json) {
  if (json is List) {
    return json.cast<Map<String, dynamic>>();
  }
  if (json is Map<String, dynamic>) {
    final inner = json['data'];
    if (inner is List) {
      return inner.cast<Map<String, dynamic>>();
    }
  }
  return <Map<String, dynamic>>[];
}
