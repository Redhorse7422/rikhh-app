part of 'products_api_service.dart';

ProductsResponse _$ProductsResponseFromJson(Map<String, dynamic> json) =>
    ProductsResponse(
      data: (json['data'] as List<dynamic>)
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ProductsResponseToJson(ProductsResponse instance) =>
    <String, dynamic>{'data': instance.data, 'meta': instance.meta};

PaginationMeta _$PaginationMetaFromJson(Map<String, dynamic> json) =>
    PaginationMeta(
      total: (json['total'] as num).toInt(),
      page: (json['page'] as num).toInt(),
      limit: (json['limit'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
    );

Map<String, dynamic> _$PaginationMetaToJson(PaginationMeta instance) =>
    <String, dynamic>{
      'total': instance.total,
      'page': instance.page,
      'limit': instance.limit,
      'totalPages': instance.totalPages,
    };

ProductResponse _$ProductResponseFromJson(Map<String, dynamic> json) =>
    ProductResponse(
      success: json['success'] as bool,
      data: Product.fromJson(json['data'] as Map<String, dynamic>),
      message: json['message'] as String?,
    );

Map<String, dynamic> _$ProductResponseToJson(ProductResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'data': instance.data,
      'message': instance.message,
    };

CategoriesResponse _$CategoriesResponseFromJson(Map<String, dynamic> json) =>
    CategoriesResponse(
      message: json['message'] as String,
      requestId: json['requestId'] as String,
      data: _parseCategoriesData(json['data']),
    );

Map<String, dynamic> _$CategoriesResponseToJson(CategoriesResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'requestId': instance.requestId,
      'data': instance.data,
    };

class _ProductsApiService implements ProductsApiService {
  _ProductsApiService(this._dio, {this.baseUrl, this.errorLogger});

  final Dio _dio;

  String? baseUrl;

  final ParseErrorLogger? errorLogger;

  @override
  Future<ProductsResponse> getProducts({
    int page = 1,
    int limit = 20,
    String? filters,
    String? sort,
    String? order,
  }) async {
    final extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'page': page,
      r'limit': limit,
      r'filters': filters,
      r'sort': sort,
      r'order': order,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final headers = <String, dynamic>{};
    const Map<String, dynamic>? data = null;
    final options = _setStreamType<ProductsResponse>(
      Options(method: 'GET', headers: headers, extra: extra)
          .compose(
            _dio.options,
            '/v1/products/all',
            queryParameters: queryParameters,
            data: data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final result = await _dio.fetch<Map<String, dynamic>>(options);
    late ProductsResponse value;
    try {
      value = ProductsResponse.fromJson(result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, options);
      rethrow;
    }
    return value;
  }

  @override
  Future<ProductResponse> getProductById(String id) async {
    final extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final headers = <String, dynamic>{};
    const Map<String, dynamic>? data = null;
    final options = _setStreamType<ProductResponse>(
      Options(method: 'GET', headers: headers, extra: extra)
          .compose(
            _dio.options,
            '/v1/products/$id',
            queryParameters: queryParameters,
            data: data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final result = await _dio.fetch<Map<String, dynamic>>(options);
    late ProductResponse value;
    try {
      value = ProductResponse.fromJson(result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, options);
      rethrow;
    }
    return value;
  }

  @override
  Future<dynamic> getFeaturedProducts({
    int page = 1,
    int limit = 20,
    String? sortBy,
    String? sortOrder,
    bool? featured,
  }) async {
    final extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'page': page,
      r'limit': limit,
      r'sortBy': sortBy,
      r'sortOrder': sortOrder,
      r'featured': featured,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final headers = <String, dynamic>{};
    const Map<String, dynamic>? data = null;
    final options = _setStreamType<dynamic>(
      Options(method: 'GET', headers: headers, extra: extra)
          .compose(
            _dio.options,
            '/v1/products/featured',
            queryParameters: queryParameters,
            data: data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final result = await _dio.fetch(options);
    final value = result.data;
    return value;
  }

  @override
  Future<dynamic> getNewArrivals() async {
    final extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final headers = <String, dynamic>{};
    const Map<String, dynamic>? data = null;
    final options = _setStreamType<dynamic>(
      Options(method: 'GET', headers: headers, extra: extra)
          .compose(
            _dio.options,
            '/v1/products/new-arrivals',
            queryParameters: queryParameters,
            data: data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final result = await _dio.fetch(options);
    final value = result.data;
    return value;
  }

  @override
  Future<dynamic> getBestSellers() async {
    final extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final headers = <String, dynamic>{};
    const Map<String, dynamic>? data = null;
    final options = _setStreamType<dynamic>(
      Options(method: 'GET', headers: headers, extra: extra)
          .compose(
            _dio.options,
            '/v1/products/best-sellers',
            queryParameters: queryParameters,
            data: data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final result = await _dio.fetch(options);
    final value = result.data;
    return value;
  }

  @override
  Future<CategoriesResponse> getCategories() async {
    final extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final headers = <String, dynamic>{};
    const Map<String, dynamic>? data = null;
    final options = _setStreamType<CategoriesResponse>(
      Options(method: 'GET', headers: headers, extra: extra)
          .compose(
            _dio.options,
            '/v1/categories/all/unrestricted',
            queryParameters: queryParameters,
            data: data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final result = await _dio.fetch<Map<String, dynamic>>(options);
    late CategoriesResponse value;
    try {
      value = CategoriesResponse.fromJson(result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, options);
      rethrow;
    }
    return value;
  }

  @override
  Future<ProductsResponse> getProductsByCategory(
    String categoryId, {
    int page = 1,
    int limit = 20,
  }) async {
    final extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'page': page, r'limit': limit};
    final headers = <String, dynamic>{};
    const Map<String, dynamic>? data = null;
    final options = _setStreamType<ProductsResponse>(
      Options(method: 'GET', headers: headers, extra: extra)
          .compose(
            _dio.options,
            '/v1/categories/$categoryId/products',
            queryParameters: queryParameters,
            data: data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final result = await _dio.fetch<Map<String, dynamic>>(options);
    late ProductsResponse value;
    try {
      value = ProductsResponse.fromJson(result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, options);
      rethrow;
    }
    return value;
  }

  RequestOptions _setStreamType<T>(RequestOptions requestOptions) {
    if (T != dynamic &&
        !(requestOptions.responseType == ResponseType.bytes ||
            requestOptions.responseType == ResponseType.stream)) {
      if (T == String) {
        requestOptions.responseType = ResponseType.plain;
      } else {
        requestOptions.responseType = ResponseType.json;
      }
    }
    return requestOptions;
  }

  String _combineBaseUrls(String dioBaseUrl, String? baseUrl) {
    if (baseUrl == null || baseUrl.trim().isEmpty) {
      return dioBaseUrl;
    }

    final url = Uri.parse(baseUrl);

    if (url.isAbsolute) {
      return url.toString();
    }

    return Uri.parse(dioBaseUrl).resolveUri(url).toString();
  }
}
