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
          _log.d("Request URL: ${options.baseUrl}${options.path} \n" +
              "Request Method: ${options.method} \n" +
              "Request Headers: ${options.headers} \n " +
              "Request Data: ${options.data}");
          return handler.next(options);
        },
        onResponse: (response, handler) {
          _log.d("Response Status: ${response.statusCode} \n" +
              "Response Data: ${response.data} \n" +
              "Response Headers: ${response.headers}");
          return handler.next(response);
        },
        onError: (error, handler) {
          String messageError = "Error: ${error.message}";
          if (error.response != null) {
            messageError =
                "$messageError\n Error Response Status: ${error.response?.statusCode} \n Error Response Data: ${error.response?.data}";
          }
          _log.d(messageError);

          return handler.next(error);
        },
      ),
    );
  }

  Dio get dio => _dio;
}
