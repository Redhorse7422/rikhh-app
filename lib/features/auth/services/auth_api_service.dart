import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/utils/app_logger.dart';
import '../models/phone_verification_models.dart';

class AuthApiService {
  final Dio _dio = DioClient.instance;

  Future<LoginResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password, 'userType': 'buyer'},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : Map<String, dynamic>.from(response.data);

        // Check if login was successful
        if (data['code'] == 0 && data['message'] == 'Login successful') {
          final userData = data['data'] as Map<String, dynamic>;
          final token = userData['accessToken'] as String?;
          final refreshToken = userData['refreshToken'] as String?;
          final user = userData;

          if (token != null && token.isNotEmpty) {
            return LoginResult(
              token: token,
              refreshToken: refreshToken,
              user: user,
            );
          }
          throw Exception('Access token missing in response');
        } else {
          throw Exception(data['message'] ?? 'Login failed');
        }
      }

      throw Exception('Login failed: ${response.statusCode}');
    } catch (e) {
      if (e is DioException) {
        if (e.response != null) {
          AppLogger.auth(
            'Response status: ${e.response?.statusCode}',
          );
          AppLogger.auth('Response data: ${e.response?.data}');
        }
      }
      rethrow;
    }
  }

  Future<RefreshTokenResult> refreshToken({
    required String refreshToken,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/refresh-token',
        data: {'refreshToken': refreshToken},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : Map<String, dynamic>.from(response.data);

        // Check if refresh was successful
        if (data['code'] == 0 &&
            data['message'] == 'Token refreshed successfully') {
          final tokenData = data['data'] as Map<String, dynamic>;
          final newToken = tokenData['accessToken'] as String?;
          final newRefreshToken = tokenData['refreshToken'] as String?;

          if (newToken != null && newToken.isNotEmpty) {
            return RefreshTokenResult(
              token: newToken,
              refreshToken: newRefreshToken,
            );
          }
          throw Exception('New access token missing in response');
        } else {
          throw Exception(data['message'] ?? 'Token refresh failed');
        }
      }

      throw Exception('Token refresh failed: ${response.statusCode}');
    } catch (e) {
      if (e is DioException) {
        if (e.response != null) {
          AppLogger.auth(
            'Response status: ${e.response?.statusCode}',
          );
          AppLogger.auth('Response data: ${e.response?.data}');
        }
      }
      rethrow;
    }
  }

  Future<PhoneVerificationResponse> sendPhoneVerificationOtp({
    required String phoneNumber,
    String? deviceId,
  }) async {
    try {
      final request = PhoneVerificationRequest(
        phoneNumber: phoneNumber,
        deviceId: deviceId,
      );

      final response = await _dio.post(
        '/auth/send-phone-verification-otp',
        data: request.toJson(),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : Map<String, dynamic>.from(response.data);

        return PhoneVerificationResponse.fromJson(data);
      }

      throw Exception('Failed to send OTP: ${response.statusCode}');
    } catch (e) {
      if (e is DioException) {
        if (e.response != null) {
          AppLogger.auth(
            'Send OTP Response status: ${e.response?.statusCode}',
          );
          AppLogger.auth('Send OTP Response data: ${e.response?.data}');
        }
      }
      rethrow;
    }
  }

  Future<VerifyOtpResponse> verifyPhoneOtp({
    required String phoneNumber,
    required String otpCode,
  }) async {
    try {
      final request = VerifyOtpRequest(
        phoneNumber: phoneNumber,
        otpCode: otpCode,
      );

      final response = await _dio.post(
        '/auth/verify-phone-otp',
        data: request.toJson(),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : Map<String, dynamic>.from(response.data);

        return VerifyOtpResponse.fromJson(data);
      }

      throw Exception('Failed to verify OTP: ${response.statusCode}');
    } catch (e) {
      if (e is DioException) {
        if (e.response != null) {
          AppLogger.auth(
            'Verify OTP Response status: ${e.response?.statusCode}',
          );
          AppLogger.auth('Verify OTP Response data: ${e.response?.data}');
        }
      }
      rethrow;
    }
  }

  Future<ResendOtpResponse> resendPhoneVerificationOtp({
    required String phoneNumber,
    String? deviceId,
  }) async {
    try {
      final request = ResendOtpRequest(
        phoneNumber: phoneNumber,
        deviceId: deviceId,
      );

      final response = await _dio.post(
        '/auth/resend-phone-verification-otp',
        data: request.toJson(),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : Map<String, dynamic>.from(response.data);

        return ResendOtpResponse.fromJson(data);
      }

      throw Exception('Failed to resend OTP: ${response.statusCode}');
    } catch (e) {
      if (e is DioException) {
        if (e.response != null) {
          AppLogger.auth(
            'Resend OTP Response status: ${e.response?.statusCode}',
          );
          AppLogger.auth('Resend OTP Response data: ${e.response?.data}');
        }
      }
      rethrow;
    }
  }
}

class LoginResult {
  final String token;
  final String? refreshToken;
  final Map<String, dynamic> user;

  LoginResult({required this.token, this.refreshToken, required this.user});
}

class RefreshTokenResult {
  final String token;
  final String? refreshToken;

  RefreshTokenResult({required this.token, this.refreshToken});
}
