import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/utils/app_logger.dart';
import '../models/wallet_models.dart';

class WalletApiService {
  final Dio _dio = DioClient.instance;

  Future<WalletBalanceResponse> getWalletBalance({
    required String userId,
  }) async {
    
    try {
      final response = await _dio.get(
        '/v1/wallet/balance/$userId',
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : Map<String, dynamic>.from(response.data);
        
        return WalletBalanceResponse.fromJson(data);
      }
      throw Exception('Failed to get wallet balance: ${response.statusCode}');
    } catch (e) {
      if (e is DioException) {
        if (e.response != null) {
          AppLogger.auth(
            'Get wallet balance response status: ${e.response?.statusCode}',
          );
          AppLogger.auth(
            'Get wallet balance response data: ${e.response?.data}',
          );

          // Extract error message from response
          final responseData = e.response?.data;
          if (responseData is Map<String, dynamic>) {
            final errorMessage =
                responseData['message'] ?? 'Failed to get wallet balance';
            throw Exception(errorMessage);
          }
        }
      }
      rethrow;
    }
  }

  Future<TransactionHistoryResponse> getTransactionHistory({
    required String userId,
    int page = 1,
    int limit = 20,
    String? type,
  }) async {
    
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};

      if (type != null) {
        queryParams['type'] = type;
      }


      final response = await _dio.get(
        '/v1/wallet/transactions/$userId',
        queryParameters: queryParams,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : Map<String, dynamic>.from(response.data);
        
        return TransactionHistoryResponse.fromJson(data);
      }
      throw Exception(
        'Failed to get transaction history: ${response.statusCode}',
      );
    } catch (e) {
      if (e is DioException) {
        if (e.response != null) {
          AppLogger.auth(
            'Get transaction history response status: ${e.response?.statusCode}',
          );
          AppLogger.auth(
            'Get transaction history response data: ${e.response?.data}',
          );

          // Extract error message from response
          final responseData = e.response?.data;
          if (responseData is Map<String, dynamic>) {
            final errorMessage =
                responseData['message'] ?? 'Failed to get transaction history';
            throw Exception(errorMessage);
          }
        }
      }
      rethrow;
    }
  }
}
