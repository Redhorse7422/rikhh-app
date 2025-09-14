import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/profile_update_model.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/app_config.dart';

part 'profile_api_service.g.dart';

@RestApi(baseUrl: "")
abstract class ProfileApiService {
  factory ProfileApiService(Dio dio, {String? baseUrl}) = _ProfileApiService;

  @PUT('/v1/users/profile')
  Future<ProfileUpdateResponse> updateProfile(
    @Body() ProfileUpdateRequest request,
  );
}

class ProfileService {
  static final ProfileApiService _apiService = ProfileApiService(
    DioClient.instance,
    baseUrl: AppConfig.baseUrl,
  );

  static Future<ProfileUpdateResponse> updateProfile(
    ProfileUpdateRequest request,
  ) async {
    try {
      return await _apiService.updateProfile(request);
    } catch (e) {
      rethrow;
    }
  }
}
