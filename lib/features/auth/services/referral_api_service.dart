import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/utils/app_logger.dart';
import '../models/referral_models.dart';

class ReferralApiService {
  final Dio _dio = DioClient.instance;

  Future<CreateReferralCodeResponse> createReferralCode({
    required String type,
    required double commissionRate,
    required int maxUsage,
    required String expiresAt,
  }) async {
    try {
      final request = CreateReferralCodeRequest(
        type: type,
        commissionRate: commissionRate,
        maxUsage: maxUsage,
        expiresAt: expiresAt,
      );

      final response = await _dio.post(
        '/v1/referrals/create-code',
        data: request.toJson(),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : Map<String, dynamic>.from(response.data);

        return CreateReferralCodeResponse.fromJson(data);
      }

      throw Exception('Failed to create referral code: ${response.statusCode}');
    } catch (e) {
      if (e is DioException) {
        if (e.response != null) {
          AppLogger.auth(
            'Create referral code response status: ${e.response?.statusCode}',
          );
          AppLogger.auth(
            'Create referral code response data: ${e.response?.data}',
          );

          // Extract error message from response
          final responseData = e.response?.data;
          if (responseData is Map<String, dynamic>) {
            final errorMessage =
                responseData['message'] ?? 'Failed to create referral code';
            throw Exception(errorMessage);
          }
        }
      }
      rethrow;
    }
  }

  Future<GetReferralCodesResponse> getUserReferralCodes({
    required String userId,
  }) async {
    try {
      final response = await _dio.get(
        '/v1/referrals/codes/$userId',
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : Map<String, dynamic>.from(response.data);

        return GetReferralCodesResponse.fromJson(data);
      }

      throw Exception('Failed to get referral codes: ${response.statusCode}');
    } catch (e) {
      if (e is DioException) {
        if (e.response != null) {
          AppLogger.auth(
            'Get referral codes response status: ${e.response?.statusCode}',
          );
          AppLogger.auth(
            'Get referral codes response data: ${e.response?.data}',
          );

          // Extract error message from response
          final responseData = e.response?.data;
          if (responseData is Map<String, dynamic>) {
            final errorMessage =
                responseData['message'] ?? 'Failed to get referral codes';
            throw Exception(errorMessage);
          }
        }
      }
      rethrow;
    }
  }
}
