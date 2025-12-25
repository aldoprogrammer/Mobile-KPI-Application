import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_config.dart';
import '../../../../core/network/token_pair.dart';
import '../../../../core/network/token_refresher.dart';
import '../models/auth_token_model.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._client);

  final ApiClient _client;

  Future<AuthTokenModel> login({required String email, required String password}) async {
    try {
      final response = await _client.client.post(
        '/employees/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );
      return AuthTokenModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  AppException _mapException(DioException e) {
    if (e.error is AppException) {
      return e.error as AppException;
    }
    return AppException('Login failed', code: e.response?.statusCode);
  }
}

class AuthRefreshService implements TokenRefresher {
  AuthRefreshService({Dio? dio}) : _dio = dio ?? Dio(BaseOptions(baseUrl: ApiConfig.baseUrl));

  final Dio _dio;

  @override
  Future<TokenPair?> refresh(String refreshToken) async {
    try {
      final response = await _dio.post(
        '/employees/auth/refresh',
        data: {
          'refreshToken': refreshToken,
        },
      );
      final data = response.data as Map<String, dynamic>;
      return TokenPair(
        accessToken: (data['accessToken'] ?? data['token']) as String,
        refreshToken: data['refreshToken'] as String,
      );
    } on DioException {
      return null;
    }
  }
}
