import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../core/app_config.dart';
import '../../../core/network/dio_client.dart';
import '../services/auth_api_service.dart';
import '../models/phone_verification_models.dart';
import '../models/password_reset_models.dart';

class AuthRepository {
  AuthApiService? _api;

  AuthApiService get api {
    _api ??= AuthApiService();
    return _api!;
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    bool rememberMe = true,
  }) async {
    final result = await api.login(email: email, password: password);

    // Save token and user data
    final prefs = await SharedPreferences.getInstance();
    if (rememberMe) {
      await prefs.setString(AppConfig.tokenKey, result.token);
      await prefs.setString(AppConfig.userKey, jsonEncode(result.user));

      // Save refresh token if available
      if (result.refreshToken != null) {
        await prefs.setString(AppConfig.refreshTokenKey, result.refreshToken!);
      }
    }

    DioClient.updateAuthToken(result.token);

    return result.user;
  }

  Future<Map<String, dynamic>> loginWithPhone({
    required String phone,
    required String password,
    bool rememberMe = true,
  }) async {
    final result = await api.loginWithPhone(phone: phone, password: password);

    // Save token and user data
    final prefs = await SharedPreferences.getInstance();
    if (rememberMe) {
      await prefs.setString(AppConfig.tokenKey, result.token);
      await prefs.setString(AppConfig.userKey, jsonEncode(result.user));

      // Save refresh token if available
      if (result.refreshToken != null) {
        await prefs.setString(AppConfig.refreshTokenKey, result.refreshToken!);
      }
    }

    DioClient.updateAuthToken(result.token);

    return result.user;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    // Check if token exists before removing

    await prefs.remove(AppConfig.tokenKey);
    await prefs.remove(AppConfig.refreshTokenKey);
    await prefs.remove(AppConfig.userKey);

    DioClient.updateAuthToken(null);
  }

  Future<bool> hasToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConfig.tokenKey);
    final hasToken = token != null && token.isNotEmpty;

    return hasToken;
  }

  Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString(AppConfig.userKey);
    if (userStr != null) {
      try {
        return jsonDecode(userStr) as Map<String, dynamic>;
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConfig.tokenKey);

    return token;
  }

  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString(AppConfig.refreshTokenKey);

    return refreshToken;
  }

  Future<Map<String, dynamic>> refreshAuthToken() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null) {
      throw Exception('No refresh token available');
    }

    final result = await api.refreshToken(refreshToken: refreshToken);

    // Save new tokens
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConfig.tokenKey, result.token);

    if (result.refreshToken != null) {
      await prefs.setString(AppConfig.refreshTokenKey, result.refreshToken!);
    }

    // Update DioClient with new token
    DioClient.updateAuthToken(result.token);

    return {'token': result.token, 'refreshToken': result.refreshToken};
  }

  Future<PhoneVerificationResponse> sendPhoneVerificationOtp({
    required String phoneNumber,
    String? deviceId,
  }) async {
    return await api.sendPhoneVerificationOtp(
      phoneNumber: phoneNumber,
      deviceId: deviceId,
    );
  }

  Future<VerifyOtpResponse> verifyPhoneOtp({
    required String phoneNumber,
    required String otpCode,
  }) async {
    return await api.verifyPhoneOtp(phoneNumber: phoneNumber, otpCode: otpCode);
  }

  Future<ResendOtpResponse> resendPhoneVerificationOtp({
    required String phoneNumber,
    String? deviceId,
  }) async {
    return await api.resendPhoneVerificationOtp(
      phoneNumber: phoneNumber,
      deviceId: deviceId,
    );
  }

  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String password,
    String? referralCode,
    bool rememberMe = true,
  }) async {
    final result = await api.register(
      firstName: firstName,
      lastName: lastName,
      email: email,
      phoneNumber: phoneNumber,
      password: password,
      referralCode: referralCode,
    );

    final prefs = await SharedPreferences.getInstance();
    if (rememberMe && result.token != 'registration_success_token') {
      await prefs.setString(AppConfig.tokenKey, result.token);
      await prefs.setString(AppConfig.userKey, jsonEncode(result.user));

      // Save refresh token if available
      if (result.refreshToken != null) {
        await prefs.setString(AppConfig.refreshTokenKey, result.refreshToken!);
      }

      DioClient.updateAuthToken(result.token);
    }

    return result.user;
  }

  Future<PasswordResetResponse> requestPasswordReset({
    required String phoneNumber,
    required String userType,
    String? deviceId,
  }) async {
    return await api.requestPasswordReset(
      phoneNumber: phoneNumber,
      userType: userType,
      deviceId: deviceId,
    );
  }

  Future<PasswordResetConfirmResponse> confirmPasswordReset({
    required String phoneNumber,
    required String otpCode,
    required String newPassword,
    required String userType,
  }) async {
    return await api.confirmPasswordReset(
      phoneNumber: phoneNumber,
      otpCode: otpCode,
      newPassword: newPassword,
      userType: userType,
    );
  }
}
