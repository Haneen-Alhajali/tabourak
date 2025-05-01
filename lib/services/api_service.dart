import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String _baseUrl = 'http://localhost:3000/api';

  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  static Future<dynamic> post(String endpoint, dynamic data) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/$endpoint'),
      headers: await _getHeaders(),
      body: json.encode(data),
    );
    return _handleResponse(response);
  }

  static Future<dynamic> get(String endpoint) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/$endpoint'),
      headers: await _getHeaders(),
    );
    return _handleResponse(response);
  }

  static dynamic _handleResponse(http.Response response) {
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Request failed: ${response.statusCode}');
    }
  }
}