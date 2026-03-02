// ================= IMPORTS =================

// Dart
import 'dart:convert';

// Flutter
import 'package:flutter/foundation.dart';

// Packages
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Services
import 'connect_api_service.dart';


// ================= SERVICE =================

class AuthTokenService {

  // Secure storage
  static final storage = FlutterSecureStorage();


  // ================= TOKEN METHODS =================

  /// Проверка наличия токена
  static Future<bool> hasToken() async {
    final token = await storage.read(key: 'token');
    return token != null;
  }

  /// Получение токена
  static Future<String?> getToken() async {
    return await storage.read(key: 'token');
  }

  /// Удаление токена
  static Future<void> deleteToken() async {
    await storage.delete(key: 'token');
    debugPrint('[+] Токен удален');
  }


  // ================= GET USER PROFILE =================

  /// Получение информации о пользователе
  static Future<Map<String, dynamic>> getUserProfile() async {

    final token = await getToken();

    if (token == null) {
      throw Exception('Токен не найден');
    }

    final url = Uri.parse(
      ConnectApiService.endpoint('auth/user'),
    );

    debugPrint('🌐 Запрос к: $url');

    try {

      final response = await http
          .get(
            url,
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(
            Duration(seconds: ConnectApiService.timeout),
            onTimeout: () {
              throw Exception('Превышено время ожидания ответа от сервера');
            },
          );

      // -------- DEBUG --------
      debugPrint('========== GET PROFILE DEBUG ==========');
      debugPrint('Статус: ${response.statusCode}');
      debugPrint('Ответ: ${response.body}');

      // -------- SUCCESS --------
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data.containsKey('data')) {
          return data['data'] as Map<String, dynamic>;
        } else {
          return data;
        }

      }

      // -------- UNAUTHORIZED --------
      else if (response.statusCode == 401) {
        await deleteToken();
        throw Exception('Сессия истекла. Войдите снова');
      }

      // -------- OTHER ERRORS --------
      else {
        throw Exception('Ошибка загрузки профиля: ${response.statusCode}');
      }

    } catch (e) {
      debugPrint('❌ Ошибка загрузки профиля: $e');
      rethrow;
    }
  }
}
