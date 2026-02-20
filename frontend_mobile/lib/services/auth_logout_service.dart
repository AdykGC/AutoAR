// auth_logout_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthLogoutService {
    static const String baseUrl_iOS = 'http://172.20.10.3:8000/api';
    static const String baseUrl_Android = 'http://10.0.2.2:8000/api';

    static String get baseUrl => defaultTargetPlatform == TargetPlatform.iOS ? baseUrl_iOS : baseUrl_Android;
    static final storage = FlutterSecureStorage();


    // ==================== LOGOUT ====================
    static Future<void> logout() async {
        final token = await storage.read(key: 'token');
        
        debugPrint('========== LOGOUT DEBUG ==========');
        debugPrint('Токен найден: ${token != null}');
        
        // Всегда пытаемся вызвать API logout, даже если токена нет
        if (token != null) {
            await _callLogoutApi(token);
        }
        
        // В любом случае удаляем токен локально
        await storage.delete(key: 'token');
        debugPrint('✅ Токен удален из локального хранилища');
        
        // Дополнительно очищаем возможные другие данные
        await storage.delete(key: 'user_data');
        
        debugPrint('✅ Выход выполнен успешно');
        debugPrint('===================================');
    }

    static Future<void> _callLogoutApi(String token) async {
        final url = Uri.parse('$baseUrl/auth/logout');
        
        try {
            final response = await http.post(
                url,
                headers: {
                    'Accept': 'application/json',
                    'Authorization': 'Bearer $token',
                },
            ).timeout(
                const Duration(seconds: 5),
                onTimeout: () {
                    debugPrint('⚠️ Таймаут при вызове API logout');
                    return http.Response('Timeout', 408);
                },
            );

            debugPrint('Статус API logout: ${response.statusCode}');
            
            if (response.statusCode == 200) {
                debugPrint('✅ API logout успешен');
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
            // Не пробрасываем ошибку дальше - всегда удаляем токен локально
        }
    }

    // ==================== ДОПОЛНИТЕЛЬНЫЕ МЕТОДЫ ====================

    // Принудительный выход без вызова API (например, при ошибке сети)
    static Future<void> forceLogout() async {
        debugPrint('========== FORCE LOGOUT ==========');
        await storage.delete(key: 'token');
        await storage.delete(key: 'user_data');
        debugPrint('✅ Принудительный выход выполнен');
        debugPrint('===================================');
    }

    // Проверка статуса авторизации
    static Future<bool> isAuthorized() async {
        final token = await storage.read(key: 'token');
        return token != null;
    }

    // Получение информации о последнем выходе
    static Future<DateTime?> getLastLogoutTime() async {
        final timeStr = await storage.read(key: 'last_logout');
        if (timeStr != null) {
            return DateTime.parse(timeStr);
        }
        return null;
    }
}