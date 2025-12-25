import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../error/exceptions.dart';
import 'api_config.dart';
import 'token_pair.dart';
import 'token_refresher.dart';
import 'token_storage.dart';

typedef SessionExpiredCallback = void Function();

class ApiClient {
  ApiClient({
    required TokenStorage tokenStorage,
    required TokenRefresher tokenRefresher,
    SessionExpiredCallback? onSessionExpired,
    Dio? dio,
  })  : _tokenStorage = tokenStorage,
        _tokenRefresher = tokenRefresher,
        _onSessionExpired = onSessionExpired,
        _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: ApiConfig.baseUrl,
                connectTimeout: const Duration(milliseconds: ApiConfig.connectTimeoutMs),
                receiveTimeout: const Duration(milliseconds: ApiConfig.receiveTimeoutMs),
                headers: {
                  'Content-Type': 'application/json',
                },
              ),
            ) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: _onRequest,
      onResponse: _onResponse,
      onError: _onError,
    ));
  }

  final Dio _dio;
  final TokenStorage _tokenStorage;
  final TokenRefresher _tokenRefresher;
  final SessionExpiredCallback? _onSessionExpired;

  Completer<TokenPair?>? _refreshCompleter;

  Dio get client => _dio;

  Future<void> _onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final tokenPair = await _tokenStorage.read();
    if (tokenPair != null && options.headers['Authorization'] == null) {
      options.headers['Authorization'] = 'Bearer ${tokenPair.accessToken}';
    }
    if (ApiConfig.enableHttpLogs) {
      assert(() {
        // Debug-only log for outgoing requests.
        // ignore: avoid_print
        debugPrint('API REQUEST [${options.method}] ${options.uri}');
        if (options.queryParameters.isNotEmpty) {
          // ignore: avoid_print
          debugPrint('API QUERY: ${options.queryParameters}');
        }
        return true;
      }());
    }
    handler.next(options);
  }

  void _onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    if (ApiConfig.enableHttpLogs) {
      assert(() {
        // ignore: avoid_print
        debugPrint(
          'API RESPONSE [${response.requestOptions.method}] ${response.requestOptions.uri} -> '
          '${response.statusCode}',
        );
        if (response.data != null) {
          // ignore: avoid_print
          debugPrint('API RESPONSE BODY: ${response.data}');
        }
        return true;
      }());
    }
    handler.next(response);
  }

  Future<void> _onError(DioException err, ErrorInterceptorHandler handler) async {
    if (ApiConfig.enableHttpLogs) {
      assert(() {
        final uri = err.requestOptions.uri;
        final status = err.response?.statusCode;
        final method = err.requestOptions.method;
        final message = err.message;
        // Debug-only log for networking issues.
        // ignore: avoid_print
        debugPrint('API ERROR [$method] $uri -> $status | $message');
        if (err.response?.data != null) {
          // ignore: avoid_print
          debugPrint('API ERROR BODY: ${err.response?.data}');
        }
        return true;
      }());
    }
    final statusCode = err.response?.statusCode;
    if (statusCode == 401 && !_isRetry(err.requestOptions)) {
      final refreshed = await _refreshToken();
      if (refreshed != null) {
        final cloned = await _retry(err.requestOptions, refreshed.accessToken);
        handler.resolve(cloned);
        return;
      }
      await _tokenStorage.clear();
      _onSessionExpired?.call();
    }

    handler.next(_mapError(err));
  }

  bool _isRetry(RequestOptions options) => options.headers['x-retry'] == true;

  Future<Response<dynamic>> _retry(RequestOptions request, String accessToken) async {
    final options = Options(
      method: request.method,
      headers: Map<String, dynamic>.from(request.headers)
        ..['Authorization'] = 'Bearer $accessToken'
        ..['x-retry'] = true,
      responseType: request.responseType,
      contentType: request.contentType,
      extra: request.extra,
    );

    return _dio.request<dynamic>(
      request.path,
      data: request.data,
      queryParameters: request.queryParameters,
      options: options,
    );
  }

  Future<TokenPair?> _refreshToken() async {
    if (_refreshCompleter != null) {
      return _refreshCompleter?.future;
    }

    _refreshCompleter = Completer<TokenPair?>();
    try {
      final tokenPair = await _tokenStorage.read();
      if (tokenPair == null) {
        _refreshCompleter?.complete(null);
        return null;
      }
      final refreshed = await _tokenRefresher.refresh(tokenPair.refreshToken);
      if (refreshed != null) {
        await _tokenStorage.save(refreshed);
      }
      _refreshCompleter?.complete(refreshed);
      return refreshed;
    } catch (_) {
      _refreshCompleter?.complete(null);
      return null;
    } finally {
      _refreshCompleter = null;
    }
  }

  DioException _mapError(DioException error) {
    final status = error.response?.statusCode;
    if (status == 401) {
      return error.copyWith(error: UnauthorizedException('Unauthorized', code: status));
    }
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.connectionError) {
      return error.copyWith(error: NetworkException('Network error', code: status));
    }
    return error.copyWith(error: AppException('Unexpected error', code: status));
  }
}