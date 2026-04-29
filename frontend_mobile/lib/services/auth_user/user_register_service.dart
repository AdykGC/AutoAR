// user_register_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/* [ Services ] */
import 'package:frontend_mobile/services/connect_api_service.dart';

class AuthRegisterService {
  static final storage = FlutterSecureStorage();

  // ==================== REGISTER ====================
  static Future<void> register({
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final url = Uri.parse(ConnectApiService.endpoint('auth/register'));

    try {
      final body = {
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      };

      final response = await http
          .post(
            url,
            headers: {'Accept': 'application/json'},
            body: body,
          )
          .timeout(
            Duration(seconds: ConnectApiService.timeout),
            onTimeout: () {
              throw Exception('Превышено время ожидания ответа от сервера');
            },
          );

      debugPrint('========== REGISTER DEBUG ==========');
      debugPrint('Статус: ${response.statusCode}');
      debugPrint('Ответ API (register): ${response.body}');

      final data = jsonDecode(response.body);

      // ================= SUCCESS =================
      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint('Распарсенные данные: $data');

        final token = data['token'];

        if (token != null) {
          try {
            await storage.write(key: 'token', value: token);

            debugPrint('[SAVED] TOKEN IN STORAGE: $token');

            final savedToken = await storage.read(key: 'token');
            debugPrint('[SAVED] TOKEN FROM STORAGE: $savedToken');
          } catch (e) {
            debugPrint('[UNSAVED] TOKEN IN STORAGE: $e');
            throw Exception('Ошибка сохранения токена: $e');
          }
        } else {
          throw Exception('Токен не найден в ответе сервера');
        }

        debugPrint('===================================');
      }

      // ================= VALIDATION ERROR =================
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

      // ================= SERVER ERROR =================
      else if (response.statusCode >= 500) {
        debugPrint('❌ Серверная ошибка (${response.statusCode})');
        throw Exception('Ошибка сервера. Попробуйте позже.');
      }

      // ================= OTHER ERRORS =================
      else {
        debugPrint('❌ Неизвестная ошибка (${response.statusCode})');
        throw Exception(data['message'] ?? 'Ошибка при регистрации');
      }
    } catch (e) {
      debugPrint('❌ Ошибка запроса к API (register): $e');

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

  // ==================== VALIDATION ====================

  static String? validatePassword(String password) {
    if (password.isEmpty) return 'Введите пароль';
    if (password.length < 8) {
      return 'Пароль должен содержать минимум 8 символов';
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Пароль должен содержать хотя бы одну заглавную букву';
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Пароль должен содержать хотя бы одну цифру';
    }
    return null;
  }

  static String? validateEmail(String email) {
    if (email.isEmpty) return 'Введите email';
    if (!email.contains('@')) return 'Email должен содержать @';
    if (!email.contains('.')) return 'Email должен содержать точку';
    if (email.indexOf('@') > email.lastIndexOf('.')) {
      return 'Некорректный email';
    }
    return null;
  }

  static String? validatePasswordConfirmation(
      String password,
      String confirmation,
  ) {
    if (confirmation.isEmpty) return 'Подтвердите пароль';
    if (password != confirmation) return 'Пароли не совпадают';
    return null;
  }
}