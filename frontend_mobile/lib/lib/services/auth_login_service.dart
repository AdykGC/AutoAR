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

class AuthLoginService {

  // Secure storage для токена
  static final storage = FlutterSecureStorage();


  // ================= LOGIN =================

  static Future<void> login(String email, String password) async {
    final url = Uri.parse(
      ConnectApiService.endpoint('auth/login'),
    );

    try {

      // -------- REQUEST --------
      final response = await http
          .post(
            url,
            headers: {'Accept': 'application/json'},
            body: {
              'email': email,
              'password': password,
            },
          )
          .timeout(
            Duration(seconds: ConnectApiService.timeout),
            onTimeout: () {
              throw Exception(
                'Превышено время ожидания ответа от сервера',
              );
            },
          );

      // -------- DEBUG --------
      debugPrint('========== LOGIN DEBUG ==========');
      debugPrint('Статус: ${response.statusCode}');
      debugPrint('Ответ API (login): ${response.body}');


      // ================= SUCCESS =================
      if (response.statusCode >= 200 && response.statusCode < 300) {

        final data = jsonDecode(response.body);

        debugPrint('Распарсенные данные: $data');
        debugPrint('Ключи в data: ${data.keys}');

        // -------- DATA BLOCK --------
        if (data.containsKey('data')) {
          debugPrint('data содержит ключ "data"');
          debugPrint('data["data"]: ${data['data']}');

          // -------- TOKEN EXTRACTION --------
          if (data['data'] != null) {
            final tokenData = data['data']['token'];

            if (tokenData != null) {
              try {
                await storage.write(
                  key: 'token',
                  value: tokenData,
                );

                debugPrint('[SAVED] TOKEN IN STORAGE: $tokenData');

                final savedToken = await storage.read(key: 'token');
                debugPrint('[SAVED] TOKEN FROM STORAGE: $savedToken');

              } catch (e) {
                debugPrint('[UNSAVED] TOKEN IN STORAGE: $e');
                throw Exception('Ошибка сохранения токена: $e');
              }
            } else {
              debugPrint('Token не найден в data["data"]');
              throw Exception('Токен не найден в ответе сервера');
            }
          }

        } else {
          debugPrint('Нет ключа "data" в ответе');
        }

        debugPrint('===============================');
      }


      // ================= VALIDATION ERROR (422) =================
      else if (response.statusCode == 422) {
        debugPrint('❌ Ошибка валидации (422)');

        final responseData = jsonDecode(response.body);

        if (responseData.containsKey('errors')) {
          final errors = responseData['errors'] as Map<String, dynamic>;

          String errorMessage = '';
          errors.forEach((key, value) {
            if (value is List) {
              errorMessage += '${value.first}\n';
            } else {
              errorMessage += '$value\n';
            }
          });

          debugPrint('Детали ошибок: $errors');
          throw Exception(errorMessage.trim());

        } else if (responseData.containsKey('message')) {
          throw Exception(responseData['message']);

        } else {
          throw Exception('Ошибка валидации данных');
        }
      }


      // ================= UNAUTHORIZED (401) =================
      else if (response.statusCode == 401) {
        debugPrint('❌ Неверные учетные данные (401)');

        final responseData = jsonDecode(response.body);
        final message =
            responseData['message'] ?? 'Неверный email или пароль';

        throw Exception(message);
      }


      // ================= FORBIDDEN (403) =================
      else if (response.statusCode == 403) {
        debugPrint('❌ Доступ запрещен (403)');
        throw Exception(
          'Доступ запрещен. Обратитесь к администратору.',
        );
      }


      // ================= SERVER ERROR (500+) =================
      else if (response.statusCode >= 500) {
        debugPrint('❌ Серверная ошибка (${response.statusCode})');
        throw Exception('Ошибка сервера. Попробуйте позже.');
      }


      // ================= OTHER ERRORS =================
      else {
        debugPrint('❌ Неизвестная ошибка (${response.statusCode})');

        final responseData = jsonDecode(response.body);
        final message =
            responseData['message'] ?? 'Произошла ошибка при входе';

        throw Exception(message);
      }

    }


    // ================= NETWORK ERROR HANDLING =================
    catch (e) {
      debugPrint('❌ Ошибка запроса к API (login): $e');

      if (e is FormatException) {
        throw Exception('Ошибка формата ответа от сервера');

      } else if (e.toString().contains('SocketException')) {
        throw Exception('Нет подключения к интернету');

      } else if (e.toString().contains('TimeoutException')) {
        throw Exception(
          'Превышено время ожидания ответа от сервера',
        );

      } else {
        rethrow;
      }
    }
  }
}
