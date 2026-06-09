import 'package:dio/dio.dart';
import 'auth_service.dart';

class DioClient {
  static final Dio dio = Dio(BaseOptions(
    baseUrl: "http://localhost:8000",
    headers: {
      "Content-Type": "multipart/form-data",
    },
  ));

  static Future<void> init() async {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await AuthService.getToken();

          if (token != null) {
            options.headers["Authorization"] = "Bearer $token";
          }

          handler.next(options);
        },
      ),
    );
  }
}