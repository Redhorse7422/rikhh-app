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
          AppLogger.auth('Response status: ${e.response?.statusCode}');
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
          AppLogger.auth('Response status: ${e.response?.statusCode}');
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

      print('🔍 Sending OTP request for phone: $phoneNumber');
      print('🔍 Request data: ${request.toJson()}');

      final response = await _dio.post(
        '/auth/send-phone-verification-otp',
        data: request.toJson(),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      print('🔍 OTP Response status: ${response.statusCode}');
      print('🔍 OTP Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : Map<String, dynamic>.from(response.data);

        print('🔍 Parsed response data: $data');
        return PhoneVerificationResponse.fromJson(data);
      }

      // Handle non-success status codes
      print('🔍 Non-success status code: ${response.statusCode}');
      final data = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : Map<String, dynamic>.from(response.data);
      
      print('🔍 Error response data: $data');
      final message = data['message'] ?? 'Failed to send OTP';
      print('🔍 Extracted error message: $message');
      throw Exception(message);
    } catch (e) {
      print('🔍 OTP Send Error: $e');
      if (e is DioException) {
        if (e.response != null) {
          print('🔍 DioException Response status: ${e.response?.statusCode}');
          print('🔍 DioException Response data: ${e.response?.data}');
          print('🔍 DioException Response headers: ${e.response?.headers}');
          
          // Try to extract error message from response
          final responseData = e.response?.data;
          if (responseData is Map<String, dynamic>) {
            print('🔍 Error response structure: $responseData');
            final message = responseData['message'] ?? responseData['error'] ?? responseData['msg'];
            if (message != null) {
              print('🔍 Extracted error message: $message');
              throw Exception(message.toString());
            }
          }
          
          AppLogger.auth('Send OTP Response status: ${e.response?.statusCode}');
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

  Future<RegistrationResult> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    try {
      print('🔍 Registration request for phone: $phoneNumber');
      print('🔍 Registration data: {firstName: $firstName, lastName: $lastName, email: $email, phone: $phoneNumber}');

      final response = await _dio.post(
        '/v1/users/register',
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'phone': phoneNumber,
          'password': password,
        },
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      print('🔍 Registration Response status: ${response.statusCode}');
      print('🔍 Registration Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : Map<String, dynamic>.from(response.data);

        print('🔍 Parsed registration data: $data');

        // Check if registration was successful
        if (data['code'] == 0 &&
            (data['message'] == 'Success' ||
                data['message'] == 'Registration successful')) {
          final userData = data['data'] as Map<String, dynamic>;
          final token = userData['accessToken'] as String?;
          final refreshToken = userData['refreshToken'] as String?;
          final user = userData;

          // For registration, we might not get tokens immediately
          // Create a dummy token or handle the case where no token is provided
          if (token != null && token.isNotEmpty) {
            return RegistrationResult(
              token: token,
              refreshToken: refreshToken,
              user: user,
            );
          } else {
            // Create a dummy token for successful registration
            return RegistrationResult(
              token: 'registration_success_token',
              refreshToken: null,
              user: user,
            );
          }
        } else {
          print('🔍 Registration failed with message: ${data['message']}');
          throw Exception(data['message'] ?? 'Registration failed');
        }
      }
      print('🔍 Registration failed with status: ${response.statusCode}');
      throw Exception('Registration failed: ${response.statusCode}');
    } catch (e) {
      print('🔍 Registration Error: $e');
      if (e is DioException) {
        if (e.response != null) {
          print('🔍 DioException Response status: ${e.response?.statusCode}');
          print('🔍 DioException Response data: ${e.response?.data}');
          print('🔍 DioException Response headers: ${e.response?.headers}');
          
          // Try to extract error message from response
          final responseData = e.response?.data;
          if (responseData is Map<String, dynamic>) {
            print('🔍 Error response structure: $responseData');
            final message = responseData['message'] ?? responseData['error'] ?? responseData['msg'];
            if (message != null) {
              print('🔍 Extracted error message: $message');
              throw Exception(message.toString());
            }
          }
          
          AppLogger.auth(
            'Registration Response status: ${e.response?.statusCode}',
          );
          AppLogger.auth('Registration Response data: ${e.response?.data}');
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

class RegistrationResult {
  final String token;
  final String? refreshToken;
  final Map<String, dynamic> user;

  RegistrationResult({
    required this.token,
    this.refreshToken,
    required this.user,
  });
}
