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
import 'auth_token_service.dart';


// ================= SERVICE =================

class AuthUpdateService {
  static final storage = FlutterSecureStorage();


  // ================= UPDATE USER PROFILE =================

  /// Обновление профиля пользователя
  static Future<void> updateUserProfile({
    String? name,
    String? surname,
    String? phone,
    String? address,
  }) async {

    final token = await AuthTokenService.getToken();

    if (token == null) {
      throw Exception('Токен не найден');
    }

    final url = Uri.parse(
      ConnectApiService.endpoint('auth/update'),
    );

    debugPrint('========== UPDATE PROFILE DEBUG ==========');
    debugPrint('URL: $url');

    try {
      // Составляем тело запроса только с заполненными полями
      final Map<String, dynamic> body = {};

      if (name != null && name.isNotEmpty) {
        body['name'] = name;
        debugPrint('📝 Name: $name');
      }
      if (surname != null && surname.isNotEmpty) {
        body['surname'] = surname;
        debugPrint('📝 Surname: $surname');
      }
      if (phone != null && phone.isNotEmpty) {
        body['phone'] = phone;
        debugPrint('📝 Phone: $phone');
      }
      if (address != null && address.isNotEmpty) {
        body['address'] = address;
        debugPrint('📝 Address: $address');
      }

      debugPrint('📦 Body: $body');

      // PATCH-запрос для обновления данных
      final response = await http
          .patch(
            url,
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(
            Duration(seconds: ConnectApiService.timeout),
            onTimeout: () {
              throw Exception('Превышено время ожидания');
            },
          );

      debugPrint('Статус: ${response.statusCode}');
      debugPrint('Ответ: ${response.body}');

      // -------- SUCCESS --------
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('✅ Профиль успешно обновлен');

        if (data.containsKey('user')) {
          debugPrint('👤 Обновленные данные: ${data['user']}');
        }
      }

      // -------- VALIDATION ERROR --------
      else if (response.statusCode == 422) {
        debugPrint('❌ Ошибка валидации (422)');
        final responseData = jsonDecode(response.body);

        if (responseData.containsKey('errors')) {
          final errors = responseData['errors'] as Map;
          String errorMessage = '';
          errors.forEach((key, value) {
            errorMessage += '${value is List ? value.first : value}\n';
          });
          throw Exception(errorMessage.trim());
        } else {
          throw Exception('Ошибка валидации данных');
        }
      }

      // -------- UNAUTHORIZED --------
      else if (response.statusCode == 401) {
        debugPrint('❌ Ошибка авторизации (401)');
        throw Exception('Сессия истекла. Войдите снова');
      }

      // -------- NOT FOUND --------
      else if (response.statusCode == 404) {
        debugPrint('❌ Маршрут не найден (404)');
        throw Exception('Ошибка сервера: метод обновления не найден');
      }

      // -------- SERVER ERROR --------
      else if (response.statusCode >= 500) {
        debugPrint('❌ Серверная ошибка (${response.statusCode})');
        throw Exception('Ошибка сервера. Попробуйте позже.');
      }

      // -------- OTHER ERRORS --------
      else {
        debugPrint('❌ Неизвестная ошибка (${response.statusCode})');
        throw Exception('Ошибка при обновлении профиля');
      }

    } catch (e) {
      debugPrint('❌ Ошибка запроса к API (update): $e');

      if (e is FormatException) {
        throw Exception('Ошибка формата ответа от сервера');
      } else if (e.toString().contains('SocketException')) {
        throw Exception('Нет подключения к интернету');
      } else if (e.toString().contains('TimeoutException')) {
        throw Exception('Превышено время ожидания');
      } else {
        rethrow;
      }
    }
  }


  // ================= HELPER METHODS =================

  /// Валидация телефона
  static String? validatePhone(String phone) {
    if (phone.isEmpty) return null;
    if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(phone)) {
      return 'Введите корректный номер телефона';
    }
    return null;
  }

  /// Валидация имени
  static String? validateName(String name) {
    if (name.isEmpty) return null;
    if (name.length < 2) return 'Имя должно содержать минимум 2 символа';
    return null;
  }

  /// Валидация адреса
  static String? validateAddress(String address) {
    if (address.isEmpty) return null;
    if (address.length < 5) return 'Адрес должен содержать минимум 5 символов';
    return null;
  }
}
