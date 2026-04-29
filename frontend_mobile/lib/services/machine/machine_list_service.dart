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
    if (token == null) {
      throw Exception('Токен не найден');
    }

    final url = Uri.parse( ConnectApiService.endpoint('machines'), );

    final response = await http .get( url, headers: { 'Accept': 'application/json', 'Authorization': 'Bearer $token', }, ) .timeout( Duration(seconds: ConnectApiService.timeout), );

    final responseData = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);

    if (data == null || data['machine'] == null) {
      throw Exception('Пустой ответ сервера');
    }

    return data['machine'] as List;
    }

    if (response.statusCode == 401) {
      throw Exception('Неавторизован');
    }

    throw Exception(responseData['message'] ?? 'Ошибка загрузки списка');
  }
}