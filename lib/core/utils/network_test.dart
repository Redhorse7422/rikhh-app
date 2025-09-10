import 'dart:io';
import 'package:dio/dio.dart';
import '../app_config.dart';

class NetworkTest {
  static Future<Map<String, dynamic>> testConnectivity() async {
    final results = <String, dynamic>{};
    
    print('🔍 Testing network connectivity...');
    
    // Test 1: Basic internet connectivity
    try {
      final result = await InternetAddress.lookup('google.com');
      results['internet_connectivity'] = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      print('✅ Internet connectivity: ${results['internet_connectivity']}');
    } catch (e) {
      results['internet_connectivity'] = false;
      print('❌ Internet connectivity failed: $e');
    }
    
    // Test 2: DNS resolution for server
    try {
      final serverHost = AppConfig.baseUrl.split('://')[1].split('/')[0].split(':')[0];
      final result = await InternetAddress.lookup(serverHost);
      results['dns_resolution'] = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      results['server_ip'] = result.isNotEmpty ? result[0].address : 'Unknown';
      print('✅ DNS resolution for $serverHost: ${results['dns_resolution']}');
      print('✅ Server IP: ${results['server_ip']}');
    } catch (e) {
      results['dns_resolution'] = false;
      results['server_ip'] = 'Failed to resolve';
      print('❌ DNS resolution failed: $e');
    }
    
    // Test 3: Server reachability
    try {
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 10);
      dio.options.receiveTimeout = const Duration(seconds: 10);
      
      final response = await dio.get(AppConfig.serverTestUrl);
      results['server_reachable'] = response.statusCode != null;
      results['server_status'] = response.statusCode;
      print('✅ Server reachable: ${results['server_reachable']}');
      print('✅ Server status: ${results['server_status']}');
    } catch (e) {
      results['server_reachable'] = false;
      results['server_error'] = e.toString();
      print('❌ Server unreachable: $e');
    }
    
    // Test 4: API endpoint test
    try {
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 10);
      dio.options.receiveTimeout = const Duration(seconds: 10);
      
      final response = await dio.get('${AppConfig.baseUrl}/health');
      results['api_endpoint'] = response.statusCode != null;
      results['api_status'] = response.statusCode;
      print('✅ API endpoint accessible: ${results['api_endpoint']}');
      print('✅ API status: ${results['api_status']}');
    } catch (e) {
      results['api_endpoint'] = false;
      results['api_error'] = e.toString();
      print('❌ API endpoint failed: $e');
    }
    
    // Test 5: Network configuration info
    results['base_url'] = AppConfig.baseUrl;
    results['server_test_url'] = AppConfig.serverTestUrl;
    results['is_development'] = AppConfig.isDevelopment;
    results['connection_timeout'] = AppConfig.connectionTimeout;
    results['receive_timeout'] = AppConfig.receiveTimeout;
    
    print('🔍 Network configuration:');
    print('🔍 Base URL: ${results['base_url']}');
    print('🔍 Server Test URL: ${results['server_test_url']}');
    print('🔍 Development Mode: ${results['is_development']}');
    print('🔍 Connection Timeout: ${results['connection_timeout']}ms');
    print('🔍 Receive Timeout: ${results['receive_timeout']}ms');
    
    return results;
  }
  
  static Future<bool> testSpecificEndpoint(String endpoint) async {
    try {
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 15);
      dio.options.receiveTimeout = const Duration(seconds: 15);
      
      print('🔍 Testing endpoint: $endpoint');
      final response = await dio.get('${AppConfig.baseUrl}$endpoint');
      print('✅ Endpoint test successful: ${response.statusCode}');
      return true;
    } catch (e) {
      print('❌ Endpoint test failed: $e');
      return false;
    }
  }
}
