import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/order_model.dart';
import '../models/order_detail_model.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/app_config.dart';

part 'orders_api_service.g.dart';

@RestApi(baseUrl: "")
abstract class OrdersApiService {
  factory OrdersApiService(Dio dio, {String? baseUrl}) = _OrdersApiService;

  @GET('/v1/checkout/orders')
  Future<OrdersResponse> getOrders();

  @GET('/v1/checkout/orders/{id}')
  Future<OrderDetailResponse> getOrderDetail(@Path('id') String orderId);
}

class OrdersService {
  static final OrdersApiService _apiService = OrdersApiService(
    DioClient.instance,
    baseUrl: AppConfig.baseUrl,
  );

  static Future<OrdersResponse> getOrders() async {
    try {
      return await _apiService.getOrders();
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
}
