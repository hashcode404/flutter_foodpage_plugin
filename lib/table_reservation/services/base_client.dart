import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../constants/api_endpoints.dart';
import 'app_exception/app_exception.dart';
import 'shared_preference/auth_preference.dart';

class BaseClient {
  static const int _timeLimit = 120;
  static ResponseType get responeType => ResponseType.json;
  static String get contentType => "application/json";

  static BaseOptions get _baseOptions => BaseOptions(
      connectTimeout: const Duration(seconds: _timeLimit),
      receiveTimeout: const Duration(seconds: _timeLimit),
      baseUrl: ApiEndpoints.baseUrl,
      contentType: contentType,
      responseType: responeType,
      headers: {"SOURCE": "OWNER", "Language": "en"});

  static Dio get dio => Dio(_baseOptions)
    ..interceptors.add(
      InterceptorsWrapper(
        onRequest: requestInterceptorHandler,
        onResponse: responseInterceptorHandler,
        onError: errorResponseHandler,
      ),
    );
  // ..interceptors.add(LogInterceptor(
  //   error: true,
  //   request: true,
  //   requestHeader: true,
  //   requestBody: true,
  //   responseBody: true,
  // ));

  static void requestInterceptorHandler(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final authenticationKey = await AuthPreference().readAuthKeyData();
    if (authenticationKey == null) {
      final error = UnauthorizedAccessException();
      return handler.reject(
        DioException(
          requestOptions: options,
          message: error.message,
          type: DioExceptionType.unknown,
          error: error,
        ),
      );
    }

    options.headers.addAll({"x-shopToken": authenticationKey});
    handler.next(options);
  }

  static void responseInterceptorHandler(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final data = response.data;

    final dataKey = response.requestOptions.headers["dataKey"] as String?;

    // Check if the data is null
    if (data != null) {
      try {
        final res = jsonDecode(data);

        // Check if 'success' or 'status' is present and not null
        // final success = res['success'] ?? res["status"] ?? false;

        // Check if 'data' is present and not null
        final responseData = res[dataKey ?? 'data'];

        if (responseData == null) {
          final exception = ReponseSyntaxException();
          return handler.reject(DioException(
            requestOptions: response.requestOptions,
            error: exception,
            message: exception.message,
            type: DioExceptionType.badResponse,
          ));
        }

        response.data = jsonEncode(responseData);

        return handler.next(response);
      } catch (e) {
        final exception = FormatErrorException();
        return handler.reject(DioException(
          requestOptions: response.requestOptions,
          error: exception,
          message: exception.message,
          type: DioExceptionType.badResponse,
        ));
      }
    }

    // If any of the checks fail, consider it a bad response
    final exception = InternalServerErrorException();
    return handler.reject(DioException(
      requestOptions: response.requestOptions,
      error: exception,
      message: exception.message,
      type: DioExceptionType.badResponse,
    ));
  }

  static void errorResponseHandler(
    DioException dioError,
    ErrorInterceptorHandler handler,
  ) async {
    final type = dioError.type;
    final res = dioError.response;
    final data = res?.data;
    String? message;
    if (data is String) {
      try {
        final jsonData = json.decode(data) as Map<String, dynamic>?;
        message =
            jsonData?['error']?['message'] ?? jsonData?['data']?['message'];
      } catch (e) {
        debugPrint('Not JSON Decodable: $data');
      }
    }

    AppExceptions exception;

    switch (type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
        exception = ConnectionSlowException();
        break;
      case DioExceptionType.receiveTimeout:
        exception = TimeoutException();
        break;
      case DioExceptionType.badCertificate:
      case DioExceptionType.badResponse:
        exception = InternalServerErrorException(message: message);
        break;
      case DioExceptionType.cancel:
        exception = UserCancelException();
        break;
      case DioExceptionType.connectionError:
        exception = ConnectionLostException();
        break;
      case DioExceptionType.unknown:
        exception = InternalServerErrorException(message: message);
        break;
    }

    return handler.reject(DioException(
      requestOptions: dioError.requestOptions,
      error: exception,
      type: type,
      message: exception.message,
    ));
  }

  //GET
  static Future<String?> get({
    bool needAuth = false,
    String? baseUrl,
    String? dataKey,
    required String api,
    String params = '',
    Map<String, dynamic>? additionalHeaders,
    Map<String, dynamic>? queryParameters,
    String contentType = Headers.jsonContentType,
  }) async {
    final url = baseUrl != null ? baseUrl + api + params : api + params;
    var headers = <String, dynamic>{
      'content-type': contentType,
      'dataKey': dataKey,
    };

    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }

    final response = await dio.get<String>(
      url,
      queryParameters: queryParameters,
      options: Options(headers: headers),
    );

    return response.data;
  }

  //POST
  static Future<String?> post({
    bool needAuth = false,
    String? baseUrl,
    String? dataKey,
    required String api,
    Object? data,
    String params = '',
    Map<String, dynamic>? additionalHeaders,
    Map<String, dynamic>? queryParameters,
    String contentType = Headers.jsonContentType,
  }) async {
    final url = baseUrl != null ? baseUrl + api + params : api + params;
    var headers = <String, dynamic>{
      'content-type': contentType,
      'dataKey': dataKey,
    };

    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }

    final response = await dio.post<String>(
      url,
      data: data,
      queryParameters: queryParameters,
      options: Options(headers: headers),
    );

    return response.data;
  }

  //PUT
  static Future<String?> put({
    bool needAuth = false,
    String? baseUrl,
    String? dataKey,
    required String api,
    Object? data,
    String params = '',
    Map<String, dynamic>? additionalHeaders,
    Map<String, dynamic>? queryParameters,
    String contentType = Headers.jsonContentType,
  }) async {
    final url = baseUrl != null ? baseUrl + api + params : api + params;
    var headers = <String, dynamic>{
      'content-type': contentType,
      'dataKey': dataKey,
    };

    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }

    final response = await dio.put<String>(
      url,
      data: data,
      queryParameters: queryParameters,
      options: Options(headers: headers),
    );

    return response.data;
  }

  //PATCH
  static Future<String?> patch({
    bool needAuthentication = false,
    String? baseUrl,
    required String api,
    String params = '',
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await dio.patch<String>(api + params,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: {'needToken': needAuthentication}));
    return response.data;
  }

  //DELETE
  static Future<String?> delete({
    bool needAuth = false,
    String? baseUrl,
    String? dataKey,
    required String api,
    Object? data,
    String params = '',
    Map<String, dynamic>? additionalHeaders,
    Map<String, dynamic>? queryParameters,
    String contentType = Headers.jsonContentType,
  }) async {
    final url = baseUrl != null ? baseUrl + api + params : api + params;
    var headers = <String, dynamic>{
      'content-type': contentType,
      'dataKey': dataKey,
    };

    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }

    final response = await dio.delete<String>(
      url,
      data: data,
      queryParameters: queryParameters,
      options: Options(headers: headers),
    );

    return response.data;
  }
}
