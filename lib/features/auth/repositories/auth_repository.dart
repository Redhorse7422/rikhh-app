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
      print('🔍 AuthRepository: Saving token to SharedPreferences...');
      await prefs.setString(AppConfig.tokenKey, result.token);
      await prefs.setString(AppConfig.userKey, jsonEncode(result.user));
      print('🔍 AuthRepository: Token saved successfully (${result.token.length} chars)');
      
      // Verify token was saved
      final savedToken = prefs.getString(AppConfig.tokenKey);
      print('🔍 AuthRepository: Token verification - Saved: ${savedToken != null ? 'Yes' : 'No'}');
    } else {
      print('🔍 AuthRepository: Remember me is false, not saving token');
    }

    // Configure client for subsequent requests
    print('🔍 AuthRepository: Configuring DioClient with token...');
    DioClient.updateAuthToken(result.token);
    print('🔍 AuthRepository: DioClient configured successfully');

    return result.user;
  }

  Future<void> logout() async {
    print('🔍 AuthRepository: Starting logout process...');
    final prefs = await SharedPreferences.getInstance();
    
    // Check if token exists before removing
    final existingToken = prefs.getString(AppConfig.tokenKey);
    print('🔍 AuthRepository: Existing token before logout: ${existingToken != null ? 'Yes (${existingToken.length} chars)' : 'No'}');
    
    await prefs.remove(AppConfig.tokenKey);
    await prefs.remove(AppConfig.userKey);
    
    // Verify token was removed
    final tokenAfterRemoval = prefs.getString(AppConfig.tokenKey);
    print('🔍 AuthRepository: Token after removal: ${tokenAfterRemoval != null ? 'Still exists!' : 'Successfully removed'}');
    
    DioClient.updateAuthToken(null);
    print('🔍 AuthRepository: DioClient token cleared');
  }

  Future<bool> hasToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConfig.tokenKey);
    final hasToken = token != null && token.isNotEmpty;
    print('🔍 AuthRepository: hasToken() - Token exists: $hasToken ${token != null ? '(${token.length} chars)' : ''}');
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
    print('🔍 AuthRepository: getToken() - Retrieved token: ${token != null ? 'Yes (${token.length} chars)' : 'No'}');
    return token;
  }
}
