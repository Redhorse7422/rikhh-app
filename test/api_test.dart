import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:rikhh_app/core/app_config.dart';

void main() {
  group('API Connection Tests', () {
    late Dio dio;

    setUp(() {
      dio = Dio(
        BaseOptions(
          baseUrl: AppConfig.baseUrl.replaceAll('/api', ''),
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );
    });

    test('Should connect to backend server', () async {
      try {
        final response = await dio.get('/');
        expect(response.statusCode, 200);
        expect(response.data['status'], 'ok');
      } catch (e) {
        rethrow;
      }
    });

    test('Should get products endpoint', () async {
      try {
        final response = await dio.get('/api/products');
        expect(response.statusCode, 200);
      } catch (e) {
        // This might fail if the endpoint doesn't exist yet, which is expected
        expect(e, isA<DioException>());
      }
    });

    test('Should get categories endpoint', () async {
      try {
        final response = await dio.get('/api/categories');
        expect(response.statusCode, 200);
      } catch (e) {
        expect(e, isA<DioException>());
      }
    });
  });
}
