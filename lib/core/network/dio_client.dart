import 'package:dio/dio.dart';
import '../app_config.dart';

class DioClient {
  static Dio? _instance;

  static Dio get instance {
    _instance ??= _createDio();
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
        // Dio 5.x specific options
        responseType: ResponseType.json,
        contentType: Headers.jsonContentType,
        // Additional options for better compatibility
        validateStatus: (status) {
          return status != null && status < 500;
        },
        // Network optimization for Dio 5.x
        followRedirects: true,
        maxRedirects: 5,
        // Add persistent connection settings
        persistentConnection: true,
        // Add extra options for better error handling
        extra: {
          'withCredentials': false,
        },
      ),
    );

    // Add interceptors for logging, authentication, etc.
    dio.interceptors.addAll([
      _LoggingInterceptor(),
      _AuthInterceptor(dio),
      _ErrorInterceptor(),
      _RetryInterceptor(),
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
}

class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
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
    print('🔍 Auth Interceptor: Headers for ${options.path}: ${options.headers}');
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      print('🔍 Auth Error: 401 Unauthorized for ${err.requestOptions.path}');
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
        print('⏰ Connection timeout - Server took too long to respond');
        print('💡 Try increasing timeout or check server performance');
        break;
      case DioExceptionType.sendTimeout:
        print('⏰ Send timeout - Request took too long to send');
        print('💡 Check network upload speed or increase timeout');
        break;
      case DioExceptionType.receiveTimeout:
        print('⏰ Receive timeout - Server response took too long');
        print('💡 Check server processing time or increase timeout');
        break;
      case DioExceptionType.badResponse:
        print('📥 Bad response: ${err.response?.statusCode}');
        print('💡 Check server logs for errors');
        break;
      case DioExceptionType.cancel:
        print('❌ Request cancelled');
        break;
      case DioExceptionType.connectionError:
        print('🌐 Connection error - Cannot establish connection');
        print('💡 Check if server is running and accessible');
        break;
      case DioExceptionType.unknown:
        print('❓ Unknown error - This usually indicates a network or parsing issue');
        print('🔍 Request URL: ${err.requestOptions.uri}');
        print('🔍 Request method: ${err.requestOptions.method}');
        print('🔍 Request headers: ${err.requestOptions.headers}');
        break;
      case DioExceptionType.badCertificate:
        print('🔒 Bad certificate');
        break;
    }

    // Log additional error details
    print('🔍 Error details: ${err.message}');
    print('🔍 Error type: ${err.type}');
    print('🔍 Request path: ${err.requestOptions.path}');
    if (err.response != null) {
      print('🔍 Response status: ${err.response?.statusCode}');
      print('🔍 Response data: ${err.response?.data}');
    } else {
      print('🔍 No response received');
    }

    handler.next(err);
  }
}

class _RetryInterceptor extends Interceptor {
  static const int _maxRetries = 2;
  static const Duration _retryDelay = Duration(seconds: 1);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Only retry on connection errors and timeouts
    if (_shouldRetry(err) && _getRetryCount(err.requestOptions) < _maxRetries) {
      final retryCount = _getRetryCount(err.requestOptions);
      print('🔄 Retrying request (attempt ${retryCount + 1}/$_maxRetries)...');

      // Wait before retrying
      await Future.delayed(_retryDelay * (retryCount + 1));

      try {
        // Create a new request with updated retry count
        final retryOptions = err.requestOptions.copyWith(
          extra: {...err.requestOptions.extra, 'retryCount': retryCount + 1},
        );

        // Retry the request using the same Dio instance
        final response = await Dio().fetch(retryOptions);
        print('✅ Retry successful!');
        handler.resolve(response);
        return;
      } catch (retryError) {
        print('❌ Retry failed: $retryError');
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
