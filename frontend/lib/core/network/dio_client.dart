import 'package:dio/dio.dart';

class DioClient {
  final Dio _dio;
  static final String _apiKey = "99d9e8eb091a4567a736459c3b7f29a8"; // <-- GANTI DENGAN API KEY ANDA

  DioClient()
      : _dio = Dio(BaseOptions(
          baseUrl: "https://api.rawg.io/api/",
          queryParameters: {
            'key': _apiKey, // Selalu lampirkan API key
          },
          connectTimeout: const Duration(milliseconds: 5000),
          receiveTimeout: const Duration(milliseconds: 3000),
        )) {
    // Anda bisa tambahkan interceptor di sini
  }

  // Getter untuk dio instance (Encapsulation)
  Dio get dio => _dio;

  // Contoh fungsi GET
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      // Tangani error di sini
      rethrow;
    }
  }
}

// Nanti ini akan di-inject menggunakan GetIt