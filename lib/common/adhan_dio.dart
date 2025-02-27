import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class AdhanClientDio {
  static final AdhanClientDio _instance = AdhanClientDio._internal();
  static final Dio _dio = Dio();
  final Logger _log = Logger();

  // Private constructor for singleton
  AdhanClientDio._internal() {
    _dio.options = BaseOptions(
      baseUrl: "https://api.aladhan.com/v1/",
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          _log.d('''
          🔵 [REQUEST] → ${options.method} ${options.baseUrl}${options.path}
          Headers: ${options.headers}
          Data: ${options.data}
          ''');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          _log.d('''
          🟢 [RESPONSE] ← ${response.statusCode}
          Data: ${response.data}
          Headers: ${response.headers}
          ''');
          return handler.next(response);
        },
        onError: (error, handler) {
          _log.e('''
          🔴 [ERROR] ❌ ${error.message}
          Status Code: ${error.response?.statusCode}
          Response Data: ${error.response?.data}
          ''');
          return handler.next(error);
        },
      ),
    );
  }

  // Singleton instance getter
  factory AdhanClientDio() => _instance;

  Dio get dio => _dio;
}
