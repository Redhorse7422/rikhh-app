import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../core/app_config.dart';
import '../../../core/network/dio_client.dart';
import '../services/auth_api_service.dart';

class AuthRepository {
  final AuthApiService _api;

  AuthRepository() : _api = AuthApiService();

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    bool rememberMe = true,
  }) async {
    final result = await _api.login(email: email, password: password);

    // Save token and user data
    final prefs = await SharedPreferences.getInstance();
    if (rememberMe) {
      await prefs.setString(AppConfig.tokenKey, result.token);
      await prefs.setString(AppConfig.userKey, jsonEncode(result.user));
    }

    // Configure client for subsequent requests
    DioClient.updateAuthToken(result.token);

    return result.user;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConfig.tokenKey);
    await prefs.remove(AppConfig.userKey);
    DioClient.updateAuthToken(null);
  }

  Future<bool> hasToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConfig.tokenKey);
    return token != null && token.isNotEmpty;
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
}
