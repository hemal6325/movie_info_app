import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiClient {
  final Dio dio;
  final String apiKey = dotenv.env['TMDB_API_KEY'] ?? '';

  ApiClient._internal(this.dio);

  static ApiClient create() {
    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.themoviedb.org/3',
        queryParameters: {'api_key': dotenv.env['TMDB_API_KEY']},
        connectTimeout: const Duration(milliseconds: 5000),
        receiveTimeout: const Duration(milliseconds: 5000),
      ),
    );
    // Optional: logging interceptor
    dio.interceptors.add(
      LogInterceptor(responseBody: false, requestBody: false),
    );
    return ApiClient._internal(dio);
  }

  Future<Response> get(String path, {Map<String, dynamic>? params}) {
    final allParams = {...?params};
    return dio.get(path, queryParameters: allParams);
  }
}
