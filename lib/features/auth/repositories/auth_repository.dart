import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../core/app_config.dart';
import '../../../core/network/dio_client.dart';
import '../services/auth_api_service.dart';

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
}
