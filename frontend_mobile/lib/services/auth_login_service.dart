// auth_login_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart'; // <-- обязательно
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthLoginService {
    // статические константы для разных платформ
    static const String baseUrl_iOS = 'http://172.20.10.3:8000/api'; // IP для iOS simulator
    static const String baseUrl_Android = 'http://10.0.2.2:8000/api';
    // выберем базовый URL в статическом методе
    static String get baseUrl => defaultTargetPlatform == TargetPlatform.iOS ? baseUrl_iOS : baseUrl_Android;
    static final storage = FlutterSecureStorage();


    // ==================== LOGIN ====================
    static Future<void> login(String email, String password) async {
        final url = Uri.parse('$baseUrl/auth/login');
        try { 
            final response = await http.post( 
                url,  
                headers: {'Accept': 'application/json'},  
                body: {'email': email, 'password': password},  
            );

            debugPrint('========== LOGIN DEBUG ==========');
            debugPrint('Статус: ${response.statusCode}');
            debugPrint('Ответ API (login): ${response.body}');

            if (response.statusCode >= 200 && response.statusCode < 300) {
                // УСПЕШНЫЙ ВХОД (200-299)
                final data = jsonDecode(response.body);
                debugPrint('Распарсенные данные: $data');
                debugPrint('Ключи в data: ${data.keys}');

                if (data.containsKey('data')) {
                    debugPrint('data содержит ключ "data"');
                    debugPrint('data["data"]: ${data['data']}'); 

                    if (data['data'] != null && data['data']['token'] != null) {
                        final tokenData = data['data']['token'];
                        debugPrint('Токен найден: $tokenData');

                        try {
                            await storage.write(key: 'token', value: tokenData);
                            debugPrint('✅ Токен успешно записан в storage');

                            final savedToken = await storage.read(key: 'token');
                            debugPrint('Проверка после записи: $savedToken');
                        } catch (e) {
                            debugPrint('❌ Ошибка при записи в storage: $e'); 
                            throw Exception('Ошибка сохранения токена: $e');
                        }
                    } else {
                        debugPrint('❌ token не найден в data["data"]');
                        throw Exception('Токен не найден в ответе сервера');
                    }
                } else {
                    debugPrint('❌ Нет ключа "data" в ответе');
                    if (data.containsKey('token')) {
                        debugPrint('Но есть token на верхнем уровне: ${data['token']}');
                        // Если токен на верхнем уровне - сохраняем его
                        try {
                            await storage.write(key: 'token', value: data['token']);
                            debugPrint('✅ Токен сохранен (верхний уровень)');
                        } catch (e) {
                            debugPrint('❌ Ошибка сохранения токена: $e');
                        }
                    } else {
                        throw Exception('Неверный формат ответа от сервера');
                    }
                }
                debugPrint('===============================');

            } else if (response.statusCode == 422) {
                // ОШИБКА ВАЛИДАЦИИ (422 Unprocessable Entity)
                debugPrint('❌ Ошибка валидации (422)');
                final responseData = jsonDecode(response.body);

                if (responseData.containsKey('errors')) {
                    final errors = responseData['errors'] as Map<String, dynamic>;

                    // Собираем все ошибки в одну строку
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

            } else if (response.statusCode == 401) {
                // НЕАВТОРИЗОВАН (401 Unauthorized)
                debugPrint('❌ Неверные учетные данные (401)');
                final responseData = jsonDecode(response.body);
                final message = responseData['message'] ?? 'Неверный email или пароль';
                throw Exception(message);

            } else if (response.statusCode == 403) {
                // ДОСТУП ЗАПРЕЩЕН (403 Forbidden)
                debugPrint('❌ Доступ запрещен (403)');
                throw Exception('Доступ запрещен. Обратитесь к администратору.');

            } else if (response.statusCode >= 500) {
                // СЕРВЕРНАЯ ОШИБКА (500+)
                debugPrint('❌ Серверная ошибка (${response.statusCode})');
                throw Exception('Ошибка сервера. Попробуйте позже.');

            } else {
                // ДРУГИЕ ОШИБКИ
                debugPrint('❌ Неизвестная ошибка (${response.statusCode})');
                final responseData = jsonDecode(response.body);
                final message = responseData['message'] ?? 'Произошла ошибка при входе';
                throw Exception(message);
            }

        } catch (e) {
            debugPrint('❌ Ошибка запроса к API (login): $e');

            // Проверяем тип ошибки
            if (e is FormatException) {
                throw Exception('Ошибка формата ответа от сервера');
            } else if (e.toString().contains('SocketException')) {
                throw Exception('Нет подключения к интернету');
            } else if (e.toString().contains('TimeoutException')) {
                throw Exception('Превышено время ожидания ответа от сервера');
            } else {
                rethrow; // Пробрасываем исходную ошибку
            }
        }
    }
}