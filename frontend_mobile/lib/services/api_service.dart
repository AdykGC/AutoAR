import 'dart:convert';
import 'package:flutter/foundation.dart'; // <-- обязательно
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  // статические константы для разных платформ
    static const String baseUrl_iOS = 'http://172.20.10.3:8000/api'; // твой локальный IP для iOS
    static const String baseUrl_Android = 'http://10.0.2.2:8000/api';

  // выберем базовый URL в статическом методе
  static String get baseUrl =>
      defaultTargetPlatform == TargetPlatform.iOS
          ? baseUrl_iOS
          : baseUrl_Android;

  static final storage = FlutterSecureStorage();

  // ==================== TEST ====================
  static Future<void> testConnection() async {
    final url = Uri.parse('$baseUrl/ping');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        print('API доступен: ${response.body}');
      } else {
        print('Ошибка API: ${response.statusCode}');
      }
    } catch (e) {
      print('Не удалось подключиться: $e');
    }
  }

  // ==================== LOGIN ====================
  static Future<void> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');
    final response = await http.post(url, body: {'email': email, 'password': password});

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];
      await storage.write(key: 'token', value: token);
    } else {
      throw Exception('Ошибка входа: ${response.body}');
    }
  }

  // ==================== REGISTER ====================
    static Future<void> register(
            String email, 
            String password, 
            String passwordConfirmation
        ) async {
            final url = Uri.parse('$baseUrl/auth/register');
            final response = await http.post(url, body: {
                'email': email,
                'password': password,
                'password_confirmation': passwordConfirmation,
            });
        if (response.statusCode == 201) {
            final data = jsonDecode(response.body);
            final token = data['token'];
            await storage.write(key: 'token', value: token);
        } else if (response.statusCode == 422) {
            // Ошибки валидации Laravel
            final errors = jsonDecode(response.body)['errors'] as Map<String, dynamic>;
            final firstError = errors.values.first;
            final message = firstError is List ? firstError.first : firstError.toString();
            throw Exception(message);
        } else {
            throw Exception('Ошибка регистрации: ${response.body}');
        }
    }

  // ==================== GET PROJECTS ====================
  static Future<Map<String, dynamic>> getProjects() async {
    final token = await storage.read(key: 'token');
    if (token == null) throw Exception('Нет токена');

    final url = Uri.parse('$baseUrl/projects');
    final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Ошибка запроса: ${response.body}');
    }
  }
}
