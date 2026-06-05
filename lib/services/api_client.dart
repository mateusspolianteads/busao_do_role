import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ApiClient {
  static const String baseUrl = "https://busaorole.fwt.app.br";

  static Future<http.Response> request(
    String endpoint, {
    String method = "GET",
    Map<String, dynamic>? body,
  }) async {
    Future<http.Response> sendRequest(String? token) async {
      final uri = Uri.parse("$baseUrl$endpoint");

      final headers = {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      };

      switch (method.toUpperCase()) {
        case "POST":
          return await http.post(
            uri,
            headers: headers,
            body: jsonEncode(body),
          );

        case "PUT":
          return await http.put(
            uri,
            headers: headers,
            body: jsonEncode(body),
          );

        case "DELETE":
          return await http.delete(uri, headers: headers);

        default:
          return await http.get(uri, headers: headers);
      }
    }

    final token = await AuthService.getToken();
    var response = await sendRequest(token);

    // refresh token automático
    if (response.statusCode == 401) {
      final novoToken = await AuthService.refreshToken();

      if (novoToken != null) {
        response = await sendRequest(novoToken);
      }
    }

    return response;
  }

  // -------------------------------
  // MÉTODOS PRONTOS
  // -------------------------------

  static Future<http.Response> get(String endpoint) {
    return request(endpoint);
  }

  static Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> body,
  ) {
    return request(
      endpoint,
      method: "POST",
      body: body,
    );
  }

  static Future<http.Response> put(
    String endpoint,
    Map<String, dynamic> body,
  ) {
    return request(
      endpoint,
      method: "PUT",
      body: body,
    );
  }

  static Future<http.Response> delete(String endpoint) {
    return request(
      endpoint,
      method: "DELETE",
    );
  }

  // -------------------------------
  // TRATAMENTO DE ERRO DA API
  // -------------------------------

  static String getErrorMessage(http.Response response) {
    try {
      final data = jsonDecode(response.body);

      if (data is Map && data['detail'] != null) {
        final detail = data['detail'];

        if (detail is String) return detail;

        if (detail is List && detail.isNotEmpty) {
          return detail[0]['msg'] ?? "Erro de validação";
        }
      }

      return "Erro inesperado";
    } catch (_) {
      return "Erro inesperado";
    }
  }

  // -------------------------------
  // CHECAR SUCESSO PADRÃO
  // -------------------------------

  static bool isSuccess(http.Response response) {
    return response.statusCode >= 200 && response.statusCode < 300;
  }
}