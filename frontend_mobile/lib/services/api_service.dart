import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
    static final String baseUrl = dotenv.env['FLUTTER_API_BASE_URL'] ?? '';
    static final storage = FlutterSecureStorage();



    // ==================== LOGIN ====================
    static Future<void> login(String email, String password) async {
        try{
            final url = Uri.parse('$baseUrl/auth/login');
            final response = await http.post(url, body: { 'email': email, 'password': password, });

            if (response.statusCode == 200) {
                final data = jsonDecode(response.body);
                final token = data['token'];
                await storage.write(key: 'token', value: token);
            } else {
                throw Exception('Ошибка входа: ${response.body}');
            }
        } catch (e) {
            rethrow;
        }
    }
    static String _handleError(http.Response response) {
        if (response.statusCode == 401) {
            return 'Неверный email или пароль';
        } else if (response.statusCode == 500) {
            return 'Ошибка сервера';
        } else {
            return 'Ошибка: ${response.body}';
        }
    }



    // ==================== REGISTER ====================
    static Future<void> register(String email, String password, String passwordConfirmation) async {
        final url = Uri.parse('$baseUrl/auth/register');
        final response = await http.post(url, body: {
            'email': email,
            'password': password,
            'password_confirmation': passwordConfirmation,
        });

        if (response.statusCode == 201) {
            final data = jsonDecode(response.body);
            final token = data['token'];
            await storage.write(key: 'token', value: token);
        } else {
            throw Exception('Ошибка регистрации: ${response.body}');
        }
    }



  // ==================== ПРОТЕГИРОВАННЫЙ ВЫЗОВ ====================
    static Future<Map<String, dynamic>> getProjects() async {
        final token = await storage.read(key: 'token');
        if (token == null) throw Exception('Нет токена');
            final url = Uri.parse('$baseUrl/projects');
            final response = await http.get( url, headers: {'Authorization': 'Bearer $token'}, );

        if (response.statusCode == 200) {
            return jsonDecode(response.body);
        } else {
            throw Exception('Ошибка запроса: ${response.body}');
        }
    }
}