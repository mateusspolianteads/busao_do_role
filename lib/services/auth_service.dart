import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthResult {
  final bool sucesso;
  final String? erro;

  const AuthResult({required this.sucesso, this.erro});
}

class AuthService {
  static const String baseUrl = "https://busaorole.fwt.app.br";
  
  // Instância privada do Dio para auth
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  static Future<AuthResult> login(String email, String senha) async {
    try {
      final response = await _dio.post(
        '/login/',
        data: {
          "email": email,
          "senha": senha,
        },
      );

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString("access_token", response.data['access_token']);
        await prefs.setString("refresh_token", response.data['refresh_token']);

        return const AuthResult(sucesso: true);
      }

      return AuthResult(
        sucesso: false,
        erro: response.data['detail'] ?? "Email ou senha inválidos",
      );
    } on DioException catch (e) {
      return AuthResult(
        sucesso: false,
        erro: e.message ?? "Erro de conexão com servidor",
      );
    } catch (e) {
      return AuthResult(
        sucesso: false,
        erro: "Erro desconhecido: ${e.toString()}",
      );
    }
  }

  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString("access_token");
    } catch (e) {
      debugPrint('Erro ao obter token: $e');
      return null;
    }
  }

  static Future<bool> isLogged() async {
    final token = await getToken();
    return token != null;
  }

  static Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove("access_token");
      await prefs.remove("refresh_token");
    } catch (e) {
      debugPrint('Erro ao fazer logout: $e');
    }
  }

  static Future<bool> hasValidSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("access_token");
      return token != null;
    } catch (e) {
      debugPrint('Erro ao verificar sessão: $e');
      return false;
    }
  }

  static Future<String?> refreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refresh = prefs.getString("refresh_token");

      if (refresh == null) return null;

      final response = await _dio.post(
        '/usuarios/refresh',
        data: {"refresh_token": refresh},
      );

      if (response.statusCode == 200) {
        await prefs.setString(
          "access_token",
          response.data["access_token"],
        );

        return response.data["access_token"];
      }

      await logout();
      return null;
    } on DioException catch (e) {
      debugPrint('Erro ao renovar token: ${e.message}');
      await logout();
      return null;
    }
  }
}

