import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthResult {
  final bool sucesso;
  final String? erro;

  AuthResult({required this.sucesso, this.erro});
}

class AuthService {
  static const String baseUrl = "https://busaorole.fwt.app.br";

  static Future<AuthResult> login(String email, String senha) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login/"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "email": email,
          "senha": senha,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString("access_token", data['access_token']);
        await prefs.setString("refresh_token", data['refresh_token']);

        return AuthResult(sucesso: true);
      }

      return AuthResult(
        sucesso: false,
        erro: data['detail'] ?? "Email ou senha inválidos",
      );
    } catch (e) {
      return AuthResult(
        sucesso: false,
        erro: "Erro de conexão com servidor",
      );
    }
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("access_token");
  }

  static Future<bool> isLogged() async {
    final token = await getToken();
    return token != null;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("access_token");
    await prefs.remove("refresh_token");
  }

  static Future<bool> hasValidSession() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString("access_token");

    if (token == null) return false;

    return true;
  }

  static Future<String?> refreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refresh = prefs.getString("refresh_token");

    if (refresh == null) return null;

    final response = await http.post(
      Uri.parse("$baseUrl/usuarios/refresh"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"refresh_token": refresh}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      await prefs.setString(
        "access_token",
        data["access_token"],
      );

      return data["access_token"];
    }

    await logout();

    return null;
  }
}
