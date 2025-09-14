import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/order_model.dart';
import '../models/order_detail_model.dart';
import '../models/order_status_update_model.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/app_config.dart';

part 'orders_api_service.g.dart';

@RestApi(baseUrl: "")
abstract class OrdersApiService {
  factory OrdersApiService(Dio dio, {String? baseUrl}) = _OrdersApiService;

  @GET('/v1/checkout/orders')
  Future<OrdersResponse> getOrders(
    @Query('page') int page,
    @Query('limit') int limit,
  );

  @GET('/v1/checkout/orders/{id}')
  Future<OrderDetailResponse> getOrderDetail(@Path('id') String orderId);

  @PUT('/v1/orders/{id}/cancel')
  Future<OrderStatusUpdateResponse> cancelOrder(
    @Path('id') String orderId,
    @Body() OrderStatusUpdateRequest request,
  );
}

class OrdersService {
  static final OrdersApiService _apiService = OrdersApiService(
    DioClient.instance,
    baseUrl: AppConfig.baseUrl,
  );

  static Future<OrdersResponse> getOrders({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _apiService.getOrders(page, limit);

      return response;
    } catch (e) {
      rethrow;
    }
  }

  static Future<OrderDetailResponse> getOrderDetail(String orderId) async {
    try {
      return await _apiService.getOrderDetail(orderId);
    } catch (e) {
      rethrow;
    }
  }

  static Future<OrderStatusUpdateResponse> cancelOrder(
    String orderId,
    OrderStatusUpdateRequest request,
  ) async {
    try {
      return await _apiService.cancelOrder(orderId, request);
    } catch (e) {
      rethrow;
    }
  }
}
