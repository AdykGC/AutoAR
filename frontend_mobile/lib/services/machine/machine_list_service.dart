// machine_list_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
/* [ Services ] */
import 'package:frontend_mobile/services/connect_api_service.dart';
import 'package:frontend_mobile/services/auth_token_service.dart';

class MachineListService {
  static final storage = FlutterSecureStorage();

  static Future<List<dynamic>> fetchMachines() async {
  final token = await AuthTokenService.getToken();
  print('🔑 TOKEN: $token');
  
  final url = Uri.parse(ConnectApiService.endpoint('machines'));
  print('🌐 URL: $url');

  final response = await http
      .get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      )
      .timeout(const Duration(seconds: 30));

  print('📦 STATUS: ${response.statusCode}');
  print('📦 BODY: ${response.body}');

  // ✅ Один раз декодируем
  dynamic responseData;
  try {
    responseData = jsonDecode(response.body);
  } catch (_) {
    throw Exception('Некорректный ответ сервера (не JSON)');
  }

  if (response.statusCode == 401) {
    throw Exception('Неавторизован');
  }

  if (response.statusCode >= 200 && response.statusCode < 300) {
    // ✅ Безопасная проверка
    final machines = responseData?['machine'];
    if (machines == null) {
      return []; // ← возвращаем пустой список вместо throw
    }
    if (machines is! List) {
      throw Exception('Неверный формат данных: machine не является списком');
    }
    return machines;
  }

  // Любая другая ошибка
  final message = (responseData is Map) 
      ? (responseData['message'] ?? 'Ошибка загрузки списка')
      : 'Ошибка загрузки списка';
  throw Exception(message);
}
}