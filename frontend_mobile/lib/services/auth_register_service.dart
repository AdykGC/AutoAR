// auth_register_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
/* [ Service ] */
import 'connect_api_service.dart';

class AuthRegisterService {
    static final storage = FlutterSecureStorage();

    // ==================== REGISTER ====================
    static Future<void> register({ required String email, required String password, required String passwordConfirmation, /* String? name, String? surname, */ }) async {
        final url = Uri.parse(ConnectApiService.endpoint('auth/register'));

        try {
            final Map<String, dynamic> body = { 'email': email, 'password': password, 'password_confirmation': passwordConfirmation, };
            final response = await http.post( url, headers: {'Accept': 'application/json'}, body: body, ).timeout( Duration(seconds: ConnectApiService.timeout), onTimeout: () { throw Exception('Превышено время ожидания ответа от сервера'); }, );

            debugPrint('========== REGISTER DEBUG ==========');
            debugPrint('Статус: ${response.statusCode}');
            debugPrint('Ответ API (register): ${response.body}');

            if (response.statusCode >= 200 && response.statusCode < 300) {
                /* [+] РЕГИСТРАЦИЯ */
                final data = jsonDecode(response.body);
                debugPrint('Распарсенные данные: $data');
                debugPrint('Ключи в data: ${data.keys}');

                /* [+] блок data */
                if (data.containsKey('data')) {
                    debugPrint('ключ "data"');
                    debugPrint('data["data"]: ${data['data']}');

                    /* [+] Token из data */
                    if (data.containsKey('data') && data['data'] != null) {
                        final tokenData = data['data']['token'];

                        /* [+] Token имеет значение */
                        if (tokenData != null) {
                            try {
                                await storage.write(key: 'token', value: tokenData);
                                debugPrint('[SAVED] TOKEN IN STORAGE:  $tokenData');
                                final savedToken = await storage.read(key: 'token');
                                debugPrint('[SAVED] TOKEN FROM STORAGE: $savedToken');
                            } catch (e) {
                                debugPrint('[UNSAVED] TOKEN IN STORAGE: $e'); 
                                throw Exception('Ошибка сохранения токена: $e');
                            }
                        }
                    } 

                    /* [-] Token из data */ 
                    else {
                        debugPrint('Token не найден в data["data"]');
                        throw Exception('Токен не найден в ответе сервера');
                    }
                } 
                /* [-] блок data */
                else {
                    debugPrint(' Нет ключа "data" в ответе');
                }
                debugPrint('===================================');


            } else if (response.statusCode == 422) {
                // ОШИБКА ВАЛИДАЦИИ
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
                
            } else if (response.statusCode >= 500) {
                // СЕРВЕРНАЯ ОШИБКА
                debugPrint('❌ Серверная ошибка (${response.statusCode})');
                throw Exception('Ошибка сервера. Попробуйте позже.');
                
            } else {
                // ДРУГИЕ ОШИБКИ
                debugPrint('❌ Неизвестная ошибка (${response.statusCode})');
                final responseData = jsonDecode(response.body);
                final message = responseData['message'] ?? 'Ошибка при регистрации';
                throw Exception(message);
            }
            
        } catch (e) {
            debugPrint('❌ Ошибка запроса к API (register): $e');
            
            // Проверяем тип ошибки
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

    // ==================== ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ ====================

    // Валидация пароля на клиенте
    static String? validatePassword(String password) {
        if (password.isEmpty) { return 'Введите пароль'; }
        if (password.length < 8) { return 'Пароль должен содержать минимум 8 символов'; }
        if (!password.contains(RegExp(r'[A-Z]'))) { return 'Пароль должен содержать хотя бы одну заглавную букву'; }
        if (!password.contains(RegExp(r'[0-9]'))) { return 'Пароль должен содержать хотя бы одну цифру'; }
        return null;
    }

    // Валидация email
    static String? validateEmail(String email) {
        if (email.isEmpty) { return 'Введите email'; }
        if (!email.contains('@')) { return 'Email должен содержать @'; }
        if (!email.contains('.')) { return 'Email должен содержать точку'; }
        if (email.indexOf('@') > email.lastIndexOf('.')) { return 'Некорректный email (домен должен быть после @)'; }
        return null;
    }

    // Проверка совпадения паролей
    static String? validatePasswordConfirmation(String password, String confirmation) {
        if (confirmation.isEmpty) { return 'Подтвердите пароль'; }
        if (password != confirmation) { return 'Пароли не совпадают'; }
        return null;
    }
}