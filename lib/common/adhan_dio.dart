import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class AdhanClientDio {
  final Dio _dio = Dio();
  final _log = Logger();

  AdhanClientDio() {
    _dio.options
      ..baseUrl = "https://api.aladhan.com/v1/"
      ..connectTimeout = const Duration(seconds: 10)
      ..receiveTimeout = const Duration(seconds: 10)
      ..headers = {'Content-Type': 'application/json'};

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          _log.d("Request URL: ${options.baseUrl}${options.path}");
          _log.d("Request Method: ${options.method}");
          _log.d("Request Headers: ${options.headers}");
          _log.d("Request Data: ${options.data}");
          return handler.next(options);
        },
        onResponse: (response, handler) {
          _log.d("Response Status: ${response.statusCode}");
          _log.d("Response Data: ${response.data}");
          _log.d("Response Headers: ${response.headers}");
          return handler.next(response);
        },
        onError: (error, handler) {
          _log.d("Error: ${error.message}");
          if (error.response != null) {
            _log.d("Error Response Status: ${error.response?.statusCode}");
            _log.d("Error Response Data: ${error.response?.data}");
          }
          return handler.next(error);
        },
      ),
    );
  }

  Dio get dio => _dio;
}
