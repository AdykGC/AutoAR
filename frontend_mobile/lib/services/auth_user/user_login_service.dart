// user_login_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/* [ Services ] */
import 'package:frontend_mobile/services/connect_api_service.dart';

class AuthLoginService {
  static final storage = FlutterSecureStorage();
  static Future<void> login(String email, String password) async {
    final url = Uri.parse(ConnectApiService.endpoint('auth/login'));
    try {
      final response = await http.post( url, headers: {'Accept': 'application/json'}, body: {'email': email, 'password': password}, ).timeout( Duration(seconds: ConnectApiService.timeout), onTimeout: () { throw Exception('Превышено время ожидания ответа от сервера'); }, );
      debugPrint('========== LOGIN DEBUG ==========');
      debugPrint('Статус: ${response.statusCode}');
      debugPrint('Ответ API (login): ${response.body}');

      final data = jsonDecode(response.body);

      // ================= SUCCESS =================
      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint('Распарсенные данные: $data');

        final token = data['token'];

        if (token != null) {
          await storage.write(key: 'token', value: token);
          debugPrint('[SAVED] TOKEN: $token');

          final savedToken = await storage.read(key: 'token');
          debugPrint('[STORAGE CHECK] TOKEN: $savedToken');
        } else {
          throw Exception('Токен не найден в ответе сервера');
        }

        debugPrint('===============================');
      }

      // ================= VALIDATION =================
      else if (response.statusCode == 422) {
        debugPrint('❌ Ошибка валидации (422)');

        if (data.containsKey('errors')) {
          final errors = data['errors'] as Map<String, dynamic>;

          String errorMessage = '';
          errors.forEach((key, value) {
            if (value is List) {
              errorMessage += '${value.first}\n';
            } else {
              errorMessage += '$value\n';
            }
          });

          throw Exception(errorMessage.trim());
        } else {
          throw Exception(data['message'] ?? 'Ошибка валидации данных');
        }
      }

      // ================= AUTH =================
      else if (response.statusCode == 401) {
        throw Exception(data['message'] ?? 'Неверный email или пароль');
      }

      // ================= FORBIDDEN =================
      else if (response.statusCode == 403) {
        throw Exception('Доступ запрещен. Обратитесь к администратору.');
      }

      // ================= SERVER =================
      else if (response.statusCode >= 500) {
        throw Exception('Ошибка сервера. Попробуйте позже.');
      }

      // ================= OTHER =================
      else {
        throw Exception(data['message'] ?? 'Произошла ошибка при входе');
      }
    } catch (e) {
      debugPrint('❌ Ошибка запроса (login): $e');

      if (e is FormatException) {
        throw Exception('Ошибка формата ответа от сервера');
      } else if (e.toString().contains('SocketException')) {
        throw Exception('Нет подключения к интернету');
      } else if (e.toString().contains('TimeoutException')) {
        throw Exception('Превышено время ожидания ответа от сервера');
      } else {
        rethrow;
      }
    }
  }
}