import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';

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
          final user = userData;

          if (token != null && token.isNotEmpty) {
            return LoginResult(token: token, user: user);
          }
          throw Exception('Access token missing in response');
        } else {
          throw Exception(data['message'] ?? 'Login failed');
        }
      }

      throw Exception('Login failed: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }
}

class LoginResult {
  final String token;
  final Map<String, dynamic> user;

  LoginResult({required this.token, required this.user});
}
