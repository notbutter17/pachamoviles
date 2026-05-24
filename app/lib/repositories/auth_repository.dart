import 'package:dio/dio.dart';

import '../core/errors/api_exception.dart';
import '../models/auth_tokens.dart';
import '../models/user_model.dart';
import '../services/api_client.dart';

/// Auth data source. Talks to the Django JWT endpoints.
class AuthRepository {
  final ApiClient _api;

  AuthRepository(this._api);

  /// POST /auth/login/ -> tokens + user
  Future<({AuthTokens tokens, UserModel user})> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _api.dio.post(
        '/auth/login/',
        data: {'email': email, 'password': password},
      );
      final data = res.data as Map<String, dynamic>;
      return (
        tokens: AuthTokens.fromJson(data),
        user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// GET /auth/me/ -> current user (used for auto-login validation)
  Future<UserModel> me() async {
    try {
      final res = await _api.dio.get('/auth/me/');
      return UserModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
