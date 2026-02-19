import 'dart:convert';
import 'package:flutter/foundation.dart'; // <-- обязательно
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  // статические константы для разных платформ
    static const String baseUrl_iOS = 'http://172.20.10.3:8000/api'; // твой локальный IP для iOS
    static const String baseUrl_Android = 'http://10.0.2.2:8000/api';

  // выберем базовый URL в статическом методе
  static String get baseUrl =>
      defaultTargetPlatform == TargetPlatform.iOS
          ? baseUrl_iOS
          : baseUrl_Android;

  static final storage = FlutterSecureStorage();

    // ==================== REGISTER ====================
    static Future<void> register( String email,  String password,  String passwordConfirmation ) async {

        final url = Uri.parse('$baseUrl/auth/register');

        try{
            final response = await 
              http.post( 
                url,
                headers: { 'Accept': 'application/json', }, 
                body: { 'email': email, 'password': password, 'password_confirmation': passwordConfirmation, } 
                );
            debugPrint('Ответ API | (status ${response.statusCode}): ${response.body}' );

            if (response.statusCode >= 200 && response.statusCode < 300) {
                final data = jsonDecode(response.body);
                if (data.containsKey('token') &&
                    data['token'] != null) {
                    await storage.write( key: 'token', value: data['token'] );
                }
                return;
            } else if ( response.statusCode == 422 ) {
                final errors = jsonDecode(response.body)['errors'] as Map<String, dynamic>;
                final firstError = errors.values.first;
                final message = firstError is List ? firstError.first : firstError.toString();
                throw Exception(message);
            } else {
                throw Exception('Ошибка регистрации: ${response.body}');
            }
        } catch (e) {
            debugPrint('Ошибка запроса к API: $e');
            rethrow;
        }
    }
}
