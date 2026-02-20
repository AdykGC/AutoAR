// auth_token_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
/* [ Service ] */
import 'connect_api_service.dart';

class AuthTokenService {
    static final storage = FlutterSecureStorage();

    // ==================== TOKEN METHODS ====================
    static Future<bool> hasToken() async {
        final token = await storage.read(key: 'token');
        return token != null;
    }

    static Future<String?> getToken() async {
        return await storage.read(key: 'token');
    }

    static Future<void> deleteToken() async {
        await storage.delete(key: 'token');
        debugPrint('[+] Токен удален');
    }

    // ==================== GET USER PROFILE ====================
    static Future<Map<String, dynamic>> getUserProfile() async {
        final token = await getToken();
        if (token == null) { 
            throw Exception('Токен не найден'); 
        }

        final url = Uri.parse(ConnectApiService.endpoint('auth/user'));
        debugPrint('🌐 Запрос к: $url');
        
        try {
            final response = await http.get(
                url, 
                headers: { 
                    'Accept': 'application/json', 
                    'Authorization': 'Bearer $token', 
                },
            ).timeout(
                Duration(seconds: ConnectApiService.timeout),
                onTimeout: () {
                    throw Exception('Превышено время ожидания ответа от сервера');
                },
            );
            
            debugPrint('========== GET PROFILE DEBUG ==========');
            debugPrint('Статус: ${response.statusCode}');
            debugPrint('Ответ: ${response.body}');

            if (response.statusCode == 200) {
                final data = jsonDecode(response.body);
                
                if (data.containsKey('data')) {
                    return data['data'] as Map<String, dynamic>;
                } else {
                    return data;
                }
            } else if (response.statusCode == 401) {
                await deleteToken();
                throw Exception('Сессия истекла. Войдите снова');
            } else {
                throw Exception('Ошибка загрузки профиля: ${response.statusCode}');
            }
        } catch (e) {
            debugPrint('❌ Ошибка загрузки профиля: $e');
            rethrow;
        }
    }
}