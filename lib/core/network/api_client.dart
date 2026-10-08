/// Dio-based API client for Zunify backend.
library;

import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

class ApiClient {
  ApiClient({String? baseUrl})
      : _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl ?? (kIsWeb 
                ? 'http://127.0.0.1:3000/api' 
                : (defaultTargetPlatform == TargetPlatform.android 
                    ? 'http://10.0.2.2:3000/api' 
                    : 'http://127.0.0.1:3000/api')),
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 30),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          ),
        ) {
    _dio.interceptors.add(
      LogInterceptor(requestBody: false, responseBody: false),
    );
    _dio.interceptors.add(_ErrorInterceptor());
  }

  final Dio _dio;

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.get<dynamic>(
      path,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
    );
    return _unwrap(response);
  }

  Future<dynamic> post(
    String path, {
    dynamic data,
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.post<dynamic>(
      path,
      data: data,
      cancelToken: cancelToken,
    );
    return _unwrap(response);
  }

  Future<dynamic> patch(
    String path, {
    dynamic data,
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.patch<dynamic>(
      path,
      data: data,
      cancelToken: cancelToken,
    );
    return _unwrap(response);
  }

  Future<dynamic> delete(
    String path, {
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.delete<dynamic>(path, cancelToken: cancelToken);
    return _unwrap(response);
  }

  dynamic _unwrap(Response<dynamic> response) {
    final body = response.data as Map<String, dynamic>?;
    if (body == null) return null;
    if (body['success'] == false) {
      throw ApiException(body['message'] as String? ?? 'Unknown error');
    }
    return body['data'];
  }
}

class ApiException implements Exception {
  const ApiException(this.message);
  final String message;

  @override
  String toString() => 'ApiException: $message';
}

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: const ApiException('Request timed out. Check your connection.'),
          type: err.type,
        ),
      );
      return;
    }
    if (err.type == DioExceptionType.connectionError) {
      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: const ApiException(
            'Cannot reach server. Make sure the backend is running.',
          ),
          type: err.type,
        ),
      );
      return;
    }
    handler.next(err);
  }
}
