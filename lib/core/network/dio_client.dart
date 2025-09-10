import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_config.dart';
import '../utils/app_logger.dart';

class DioClient {
  static Dio? _instance;
  static bool _isInitializing = false;

  static Dio get instance {
    if (_instance == null && !_isInitializing) {
      _isInitializing = true;
      _instance = _createDio();
      _isInitializing = false;
    }
    return _instance!;
  }

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: Duration(milliseconds: AppConfig.connectionTimeout),
        receiveTimeout: Duration(milliseconds: AppConfig.receiveTimeout),
        sendTimeout: Duration(milliseconds: AppConfig.connectionTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        responseType: ResponseType.json,
        contentType: Headers.jsonContentType,
        validateStatus: (status) {
          return status != null && status < 500;
        },
        followRedirects: true,
        maxRedirects: 5,
        persistentConnection: true,
        extra: {'withCredentials': false},
      ),
    );

    dio.interceptors.addAll([
      _LoggingInterceptor(),
      _AuthInterceptor(dio),
      _TokenRefreshInterceptor(
        dio,
      ), // Place before ErrorInterceptor to handle 401 errors first
      _ErrorInterceptor(),
      _RetryInterceptor(dio),
    ]);
    return dio;
  }

  static void updateAuthToken(String? token) {
    if (token != null) {
      _instance?.options.headers['Authorization'] = 'Bearer $token';
    } else {
      _instance?.options.headers.remove('Authorization');
    }
  }

  static String? getCurrentToken() {
    final authHeader = _instance?.options.headers['Authorization'] as String?;
    if (authHeader != null && authHeader.startsWith('Bearer ')) {
      return authHeader.substring(7); // Remove 'Bearer ' prefix
    }
    return null;
  }

  static Future<bool> refreshTokenIfNeeded() async {
    try {
      // Get refresh token from SharedPreferences directly
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString(AppConfig.refreshTokenKey);

      if (refreshToken == null) {
        return false;
      }

      // Create a separate Dio instance for refresh to avoid circular dependency
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: AppConfig.baseUrl,
          connectTimeout: Duration(milliseconds: AppConfig.connectionTimeout),
          receiveTimeout: Duration(milliseconds: AppConfig.receiveTimeout),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      final response = await refreshDio.post(
        '/auth/refresh-token',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : Map<String, dynamic>.from(response.data);

        // Check for success - be more flexible with response format
        bool isSuccess = false;
        Map<String, dynamic>? tokenData;

        if (data['code'] == 0 &&
            data['message'] == 'Token refreshed successfully') {
          // Original format
          tokenData = data['data'] as Map<String, dynamic>?;
          isSuccess = true;
        } else if (data['success'] == true || data['status'] == 'success') {
          // Alternative format
          tokenData = data['data'] as Map<String, dynamic>? ?? data;
          isSuccess = true;
        } else if (data['accessToken'] != null) {
          // Direct token format
          tokenData = data;
          isSuccess = true;
        }

        if (isSuccess && tokenData != null) {
          final newToken = tokenData['accessToken'] as String?;
          final newRefreshToken = tokenData['refreshToken'] as String?;

          if (newToken != null && newToken.isNotEmpty) {
            // Save new tokens
            await prefs.setString(AppConfig.tokenKey, newToken);

            if (newRefreshToken != null) {
              await prefs.setString(AppConfig.refreshTokenKey, newRefreshToken);
            }

            // Update DioClient with new token
            DioClient.updateAuthToken(newToken);
            return true;
          }
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}

class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('🌐 NETWORK REQUEST:');
    print('🌐 URL: ${options.uri}');
    print('🌐 Method: ${options.method}');
    print('🌐 Headers: ${options.headers}');
    print('🌐 Data: ${options.data}');
    print('🌐 Timeout: ${options.connectTimeout}');
    
    AppLogger.network('Request to ${options.path}');
    AppLogger.network('Request data: ${options.data}');
    AppLogger.network('Request headers: ${options.headers}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('🌐 NETWORK RESPONSE:');
    print('🌐 Status: ${response.statusCode}');
    print('🌐 Headers: ${response.headers}');
    print('🌐 Data: ${response.data}');
    
    AppLogger.network('Response status: ${response.statusCode}');
    AppLogger.network('Response data: ${response.data}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('🌐 NETWORK ERROR:');
    print('🌐 Type: ${err.type}');
    print('🌐 Message: ${err.message}');
    print('🌐 URL: ${err.requestOptions.uri}');
    print('🌐 Status Code: ${err.response?.statusCode}');
    print('🌐 Response Data: ${err.response?.data}');
    
    AppLogger.network('Network error: ${err.type} - ${err.message}');
    handler.next(err);
  }
}

class _AuthInterceptor extends Interceptor {
  final Dio _dio;

  _AuthInterceptor(this._dio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Ensure Authorization header is set from the instance headers
    final authHeader = _dio.options.headers['Authorization'];
    if (authHeader != null && !options.headers.containsKey('Authorization')) {
      options.headers['Authorization'] = authHeader;
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      AppLogger.auth('401 Unauthorized for ${err.requestOptions.path}');
    }
    handler.next(err);
  }
}

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Handle common errors
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
        AppLogger.network('Connection timeout - Server took too long to respond');
        AppLogger.network('Try increasing timeout or check server performance');
        break;
      case DioExceptionType.sendTimeout:
        AppLogger.network('Send timeout - Request took too long to send');
        AppLogger.network('Check network upload speed or increase timeout');
        break;
      case DioExceptionType.receiveTimeout:
        AppLogger.network('Receive timeout - Server response took too long');
        AppLogger.network('Check server processing time or increase timeout');
        break;
      case DioExceptionType.badResponse:
        AppLogger.network('Bad response: ${err.response?.statusCode}');
        AppLogger.network('Check server logs for errors');
        break;
      case DioExceptionType.cancel:
        AppLogger.network('Request cancelled');
        break;
      case DioExceptionType.connectionError:
        AppLogger.network('Connection error - Cannot establish connection');
        AppLogger.network('Check if server is running and accessible');
        break;
      case DioExceptionType.unknown:
        AppLogger.network(
          'Unknown error - This usually indicates a network or parsing issue',
        );
        AppLogger.network('Request URL: ${err.requestOptions.uri}');
        AppLogger.network('Request method: ${err.requestOptions.method}');
        AppLogger.network('Request headers: ${err.requestOptions.headers}');
        break;
      case DioExceptionType.badCertificate:
        AppLogger.network('Bad certificate');
        break;
    }

    if (err.response != null) {
      AppLogger.network('Response status: ${err.response?.statusCode}');
      AppLogger.network('Response data: ${err.response?.data}');
    } else {
      AppLogger.network('No response received');
    }

    handler.next(err);
  }
}

class _RetryInterceptor extends Interceptor {
  final Dio _dio;
  static const int _maxRetries = 2;
  static const Duration _retryDelay = Duration(seconds: 1);

  _RetryInterceptor(this._dio);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Only retry on connection errors and timeouts, NOT on 401 errors
    if (_shouldRetry(err) &&
        _getRetryCount(err.requestOptions) < _maxRetries &&
        err.response?.statusCode != 401) {
      final retryCount = _getRetryCount(err.requestOptions);

      // Wait before retrying
      await Future.delayed(_retryDelay * (retryCount + 1));

      try {
        // Create a new request with updated retry count
        final retryOptions = err.requestOptions.copyWith(
          extra: {...err.requestOptions.extra, 'retryCount': retryCount + 1},
        );

        // Retry the request using the same Dio instance (with all interceptors)
        final response = await _dio.fetch(retryOptions);
        handler.resolve(response);
        return;
      } catch (retryError) {
        AppLogger.network('Retry failed: $retryError');
        // Continue with the original error if retry fails
      }
    }

    handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.unknown; // Retry on unknown errors too
  }

  int _getRetryCount(RequestOptions options) {
    return options.extra['retryCount'] ?? 0;
  }
}

/// TokenRefreshInterceptor automatically handles token refresh when a 401 error occurs.
///
/// How it works:
/// 1. Intercepts 401 Unauthorized responses
/// 2. Attempts to refresh the access token using the stored refresh token
/// 3. Retries the original request with the new access token
/// 4. If refresh fails, logs out the user and redirects to login
///
/// This ensures users don't experience interruptions when their access token expires.
class _TokenRefreshInterceptor extends Interceptor {
  final Dio _dio;
  bool _isRefreshing = false;

  _TokenRefreshInterceptor(this._dio);

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Check for 401 responses and handle them as errors
    if (response.statusCode == 401 && !_isRefreshing) {
      // Convert 401 response to DioException and handle it
      final dioError = DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        error: 'Unauthorized - token expired',
      );

      // Handle the error
      _handleTokenRefresh(dioError, (result) {
        if (result is Response) {
          handler.next(result);
        } else if (result is DioException) {
          handler.reject(result);
        }
      });
      return;
    }

    // Continue with normal response
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      _handleTokenRefresh(err, (result) {
        if (result is Response) {
          handler.resolve(result);
        } else if (result is DioException) {
          handler.next(result);
        }
      });
      return;
    }

    handler.next(err);
  }

  /// Handle token refresh for both response and error cases
  void _handleTokenRefresh(DioException err, Function(dynamic) callback) async {
    // Skip refresh for auth endpoints to avoid infinite loops
    if (err.requestOptions.path.contains('/auth/')) {
      callback(err);
      return;
    }

    try {
      _isRefreshing = true;

      // Attempt to refresh the token using a separate Dio instance to avoid circular dependency
      await _refreshTokenDirectly();

      // Retry the original request with the new token
      final newToken = DioClient.getCurrentToken();
      if (newToken != null) {
        // Update the request headers with the new token
        err.requestOptions.headers['Authorization'] = 'Bearer $newToken';

        // Retry the request
        try {
          final response = await _dio.fetch(err.requestOptions);

          callback(response);
          return;
        } catch (retryError) {
          callback(err);
          return;
        }
      } else {
        callback(err);
        return;
      }
    } catch (refreshError) {
      await _clearTokens();
      callback(err);
      return;
    } finally {
      _isRefreshing = false;
    }
  }

  /// Refresh token directly without creating circular dependencies
  Future<void> _refreshTokenDirectly() async {
    try {
      // Get refresh token from SharedPreferences directly
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString(AppConfig.refreshTokenKey);

      if (refreshToken == null) {
        throw Exception('No refresh token available');
      }

      // Create a separate Dio instance for refresh to avoid circular dependency
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: AppConfig.baseUrl,
          connectTimeout: Duration(milliseconds: AppConfig.connectionTimeout),
          receiveTimeout: Duration(milliseconds: AppConfig.receiveTimeout),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      final response = await refreshDio.post(
        '/auth/refresh-token',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : Map<String, dynamic>.from(response.data);
        bool isSuccess = false;
        Map<String, dynamic>? tokenData;

        if (data['code'] == 0 &&
            data['message'] == 'Token refreshed successfully') {
          // Original format
          tokenData = data['data'] as Map<String, dynamic>?;
          isSuccess = true;
        } else if (data['success'] == true || data['status'] == 'success') {
          // Alternative format
          tokenData = data['data'] as Map<String, dynamic>? ?? data;
          isSuccess = true;
        } else if (data['accessToken'] != null) {
          // Direct token format
          tokenData = data;
          isSuccess = true;
        }

        if (isSuccess && tokenData != null) {
          final newToken = tokenData['accessToken'] as String?;
          final newRefreshToken = tokenData['refreshToken'] as String?;

          if (newToken != null && newToken.isNotEmpty) {
            // Save new tokens
            await prefs.setString(AppConfig.tokenKey, newToken);

            if (newRefreshToken != null) {
              await prefs.setString(AppConfig.refreshTokenKey, newRefreshToken);
            }

            // Update DioClient with new token
            DioClient.updateAuthToken(newToken);
          } else {
            throw Exception('New access token missing in response');
          }
        } else {
          throw Exception(
            data['message'] ?? data['error'] ?? 'Token refresh failed',
          );
        }
      } else {
        throw Exception('Token refresh failed: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Clear tokens when refresh fails
  Future<void> _clearTokens() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConfig.tokenKey);
      await prefs.remove(AppConfig.refreshTokenKey);
      await prefs.remove(AppConfig.userKey);
      DioClient.updateAuthToken(null);
    } catch (e) {
      AppLogger.auth('Failed to clear tokens: $e');
    }
  }
}
