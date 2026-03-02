// machine_list_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'connect_api_service.dart';
import 'auth_token_service.dart';

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
      return responseData['data']; 
      // если Laravel возвращает:
      // { success: true, data: [ ... ] }
    }

    if (response.statusCode == 401) {
      throw Exception('Неавторизован');
    }

    throw Exception(responseData['message'] ?? 'Ошибка загрузки списка');
  }
}