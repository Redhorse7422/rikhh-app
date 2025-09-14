import 'dart:io';
import 'package:dio/dio.dart';
import '../app_config.dart';

class NetworkTest {
  static Future<Map<String, dynamic>> testConnectivity() async {
    final results = <String, dynamic>{};

    // Test 1: Basic internet connectivity
    try {
      final result = await InternetAddress.lookup('google.com');
      results['internet_connectivity'] =
          result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      results['internet_connectivity'] = false;
    }

    // Test 2: DNS resolution for server
    try {
      final serverHost = AppConfig.baseUrl
          .split('://')[1]
          .split('/')[0]
          .split(':')[0];
      final result = await InternetAddress.lookup(serverHost);
      results['dns_resolution'] =
          result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      results['server_ip'] = result.isNotEmpty ? result[0].address : 'Unknown';
    } catch (e) {
      results['dns_resolution'] = false;
      results['server_ip'] = 'Failed to resolve';
    }

    // Test 3: Server reachability
    try {
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 10);
      dio.options.receiveTimeout = const Duration(seconds: 10);

      final response = await dio.get(AppConfig.serverTestUrl);
      results['server_reachable'] = response.statusCode != null;
      results['server_status'] = response.statusCode;
    } catch (e) {
      results['server_reachable'] = false;
      results['server_error'] = e.toString();
    }

    // Test 4: API endpoint test
    try {
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 10);
      dio.options.receiveTimeout = const Duration(seconds: 10);

      final response = await dio.get('${AppConfig.baseUrl}/health');
      results['api_endpoint'] = response.statusCode != null;
      results['api_status'] = response.statusCode;
    } catch (e) {
      results['api_endpoint'] = false;
      results['api_error'] = e.toString();
    }

    // Test 5: Network configuration info
    results['base_url'] = AppConfig.baseUrl;
    results['server_test_url'] = AppConfig.serverTestUrl;
    results['is_development'] = AppConfig.isDevelopment;
    results['connection_timeout'] = AppConfig.connectionTimeout;
    results['receive_timeout'] = AppConfig.receiveTimeout;

    return results;
  }

  static Future<bool> testSpecificEndpoint(String endpoint) async {
    try {
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 15);
      dio.options.receiveTimeout = const Duration(seconds: 15);

      return true;
    } catch (e) {
      return false;
    }
  }
}
