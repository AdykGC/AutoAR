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

class AuthLogoutService {

  // Secure storage
  static final storage = FlutterSecureStorage();


  // ================= LOGOUT =================
  /// Выход пользователя
  static Future<void> logout() async {
    final token = await storage.read(key: 'token');

    debugPrint('========== LOGOUT DEBUG ==========');
    debugPrint('Токен найден: ${token != null}');

    // -------- API CALL --------
    // Всегда пытаемся вызвать API logout, если токен есть
    if (token != null) {
      await _callLogoutApi(token);
    }

    // -------- LOCAL CLEANUP --------
    await storage.delete(key: 'token');
    debugPrint('[+] Токен удален из локального хранилища');

    await storage.delete(key: 'user_data');

    debugPrint('[+] Выход выполнен успешно');
    debugPrint('===================================');
  }


  // ================= PRIVATE API CALL =================
  static Future<void> _callLogoutApi(String token) async {
    final url = Uri.parse(ConnectApiService.endpoint('auth/logout'));

    try {
      final response = await http
          .post(
            url,
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              debugPrint('⚠️ Таймаут при вызове API logout');
              return http.Response('Timeout', 408);
            },
          );

      debugPrint('Статус API logout: ${response.statusCode}');

      if (response.statusCode == 200) {
        debugPrint('[+] API logout успешен');

        try {
          final data = jsonDecode(response.body);
          debugPrint('Ответ сервера: ${data['message'] ?? 'OK'}');
        } catch (_) {
          debugPrint('Ответ сервера: ${response.body}');
        }

      } else {
        debugPrint('⚠️ API logout вернул статус ${response.statusCode}');
      }

    } catch (e) {
      debugPrint('❌ Ошибка при вызове API logout: $e');
      // Не пробрасываем ошибку дальше - токен удаляется локально всегда
    }
  }


  // ================= ADDITIONAL METHODS =================

  /// Принудительный выход без вызова API
  static Future<void> forceLogout() async {
    debugPrint('========== FORCE LOGOUT ==========');

    await storage.delete(key: 'token');
    await storage.delete(key: 'user_data');

    debugPrint('✅ Принудительный выход выполнен');
    debugPrint('===================================');
  }

  /// Проверка, авторизован ли пользователь
  static Future<bool> isAuthorized() async {
    final token = await storage.read(key: 'token');
    return token != null;
  }

  /// Получение времени последнего выхода
  static Future<DateTime?> getLastLogoutTime() async {
    final timeStr = await storage.read(key: 'last_logout');

    if (timeStr != null) {
      return DateTime.parse(timeStr);
    }

    return null;
  }
}
