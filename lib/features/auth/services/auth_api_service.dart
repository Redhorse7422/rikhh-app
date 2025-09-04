import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';

class AuthApiService {
  final Dio _dio = DioClient.instance;

  Future<LoginResult> login({
    required String email,
    required String password,
  }) async {
    try {
      print('🔍 AuthApiService: Attempting login for email: $email');
      print('🔍 AuthApiService: Request URL: ${_dio.options.baseUrl}/auth/login');
      print('🔍 AuthApiService: Request headers: ${_dio.options.headers}');
      
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password, 'userType': 'buyer'},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      
      print('🔍 AuthApiService: Login response received: ${response.statusCode}');
      print('🔍 AuthApiService: Response data: ${response.data}');

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
      print('🔍 AuthApiService: Login error: $e');
      if (e is DioException) {
        print('🔍 AuthApiService: DioException type: ${e.type}');
        print('🔍 AuthApiService: DioException message: ${e.message}');
        print('🔍 AuthApiService: Request URL: ${e.requestOptions.uri}');
        if (e.response != null) {
          print('🔍 AuthApiService: Response status: ${e.response?.statusCode}');
          print('🔍 AuthApiService: Response data: ${e.response?.data}');
        }
      }
      rethrow;
    }
  }
}

class LoginResult {
  final String token;
  final Map<String, dynamic> user;

  LoginResult({required this.token, required this.user});
}
