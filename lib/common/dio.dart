import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiResponse<T> {
  final T data;
  final String? message;

  ApiResponse({required this.data, this.message});
}


class DioClient {
  final Dio _dio = Dio();

  DioClient() {
    _dio.options
      ..baseUrl = dotenv.env["ADHNAN_URL"] as String
      ..connectTimeout = const Duration(seconds: 10)
      ..receiveTimeout = const Duration(seconds: 10)
      ..headers = {'Content-Type': 'application/json'};

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Add authentication token
        options.headers['Authorization'] = 'Bearer YOUR_TOKEN';
        return handler.next(options);
      },
      onResponse: (response, handler) {
        // Log or manipulate the response
        print('Response: ${response.statusCode}');
        return handler.next(response);
      },
      onError: (error, handler) {
        // Handle errors globally
        print('Error: ${error.message}');
        return handler.next(error);
      },
    ));
  }

  Dio get dio => _dio;
}
