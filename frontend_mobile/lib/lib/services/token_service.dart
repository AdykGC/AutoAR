// ================= IMPORTS =================
import 'dart:convert';
import 'package:flutter/foundation.dart'; // обязательно
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


// ================= SERVICE =================
/// Сервис для работы с токенами и авторизацией
class AuthService {
  // ---------------- CONSTANTS ----------------
  // Статические константы для разных платформ
  static const String baseUrl_iOS = 'http://172.20.10.3:8000/api'; // iOS simulator
  static const String baseUrl_Android = 'http://10.0.2.2:8000/api'; // Android emulator

  // Выбор базового URL в зависимости от платформы
  static String get baseUrl =>
      defaultTargetPlatform == TargetPlatform.iOS ? baseUrl_iOS : baseUrl_Android;

  // Secure storage для токена
  static final storage = FlutterSecureStorage();


  // ================= REGISTER =================
  /// Регистрация нового пользователя
  static Future<void> register(
    String email,
    String password,
    String passwordConfirmation,
  ) async {
    final url = Uri.parse('$baseUrl/auth/register');

    try {
      final response = await http.post(
        url,
        headers: {'Accept': 'application/json'},
        body: {
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );

      debugPrint('Ответ API | (status ${response.statusCode}): ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);

        if (data.containsKey('token') && data['token'] != null) {
          await storage.write(key: 'token', value: data['token']);
        }
        return;
      }

      // Ошибка валидации
      if (response.statusCode == 422) {
        final errors = jsonDecode(response.body)['errors'] as Map<String, dynamic>;
        final firstError = errors.values.first;
        final message = firstError is List ? firstError.first : firstError.toString();
        throw Exception(message);
      }

      throw Exception('Ошибка регистрации: ${response.body}');
    } catch (e) {
      debugPrint('Ошибка запроса к API (register): $e');
      rethrow;
    }
  }


  // ================= LOGIN =================
  /// Вход пользователя
  static Future<void> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');

    try {
      final response = await http.post(
        url,
        headers: {'Accept': 'application/json'},
        body: {'email': email, 'password': password},
      );

      debugPrint('Ответ API (login) | (status ${response.statusCode}): ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);

        if (data.containsKey('token') && data['token'] != null) {
          await storage.write(key: 'token', value: data['token']);
        }
        return;
      }

      // Ошибка валидации
      final errors = jsonDecode(response.body)['errors'] as Map<String, dynamic>;
      final firstError = errors.values.first;
      final message = firstError is List ? firstError.first : firstError.toString();
      throw Exception(message);

    } catch (e) {
      debugPrint('Ошибка запроса к API (login): $e');
      rethrow;
    }
  }


  // ================= LOGOUT =================
  /// Выход пользователя
  static Future<void> logout() async {
    final url = Uri.parse('$baseUrl/auth/logout');

    try {
      final token = await storage.read(key: 'token');

      if (token == null) {
        throw Exception('Токен не найден');
      }

      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('Ответ API (logout) | (status ${response.statusCode}): ${response.body}');

      if (response.statusCode == 200) {
        await storage.delete(key: 'token');
      } else {
        throw Exception('Ошибка логаута: ${response.body}');
      }

    } catch (e) {
      debugPrint('Ошибка запроса к API (logout): $e');
      rethrow;
    }
  }
}
