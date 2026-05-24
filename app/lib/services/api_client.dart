import 'package:dio/dio.dart';

import '../config/app_config.dart';
import 'secure_storage_service.dart';

/// Thin Dio wrapper that:
///  - attaches the Bearer access token to every request,
///  - transparently refreshes a 401 once via `/auth/refresh/`,
///  - signals an unrecoverable session loss through [onSessionExpired].
class ApiClient {
  final Dio dio;
  final SecureStorageService _storage;

  /// Invoked when the refresh flow fails and the user must log in again.
  void Function()? onSessionExpired;

  ApiClient(this._storage, {Dio? dioOverride})
      : dio = dioOverride ??
            Dio(
              BaseOptions(
                baseUrl: AppConfig.apiBaseUrl,
                connectTimeout: AppConfig.connectTimeout,
                receiveTimeout: AppConfig.receiveTimeout,
                contentType: 'application/json',
              ),
            ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onError: _onError,
      ),
    );
  }

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Auth endpoints must never carry a stale token.
    if (!options.path.contains('/auth/login') &&
        !options.path.contains('/auth/refresh')) {
      final token = await _storage.readAccess();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  Future<void> _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    final response = error.response;
    final isAuthCall = error.requestOptions.path.contains('/auth/');
    final alreadyRetried = error.requestOptions.extra['retried'] == true;

    if (response?.statusCode == 401 && !isAuthCall && !alreadyRetried) {
      final refreshed = await _tryRefresh();
      if (refreshed) {
        try {
          final clone = await _retry(error.requestOptions);
          return handler.resolve(clone);
        } on DioException catch (e) {
          return handler.next(e);
        }
      }
      onSessionExpired?.call();
    }
    handler.next(error);
  }

  Future<bool> _tryRefresh() async {
    final refresh = await _storage.readRefresh();
    if (refresh == null) return false;
    try {
      final res = await dio.post(
        '/auth/refresh/',
        data: {'refresh': refresh},
      );
      final newAccess = res.data['access'] as String?;
      if (newAccess == null) return false;
      await _storage.saveAccess(newAccess);
      return true;
    } on DioException {
      return false;
    }
  }

  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final token = await _storage.readAccess();
    final options = Options(
      method: requestOptions.method,
      headers: {
        ...requestOptions.headers,
        if (token != null) 'Authorization': 'Bearer $token',
      },
      extra: {...requestOptions.extra, 'retried': true},
    );
    return dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }
}
