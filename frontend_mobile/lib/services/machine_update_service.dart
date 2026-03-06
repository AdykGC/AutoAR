import 'dart:convert';
import 'package:http/http.dart' as http;
import 'connect_api_service.dart';
import 'auth_token_service.dart';

class MachineUpdateService {
  static Future<Map<String, dynamic>> update({
    required int id,
    required String name,
    required String type,
    String? location,
    String? serialNumber,
  }) async {
    final token = await AuthTokenService.getToken();
    if (token == null) { throw Exception('Токен не найден'); }
    final url = Uri.parse( ConnectApiService.endpoint('machines/update/$id') );

    final Map<String, dynamic> body = {
      'name': name,
      'type': type,
      if (location != null && location.isNotEmpty) 'location': location,
      if (serialNumber != null && serialNumber.isNotEmpty)
        'serial_number': serialNumber,
    };

    final response = await http.patch(
      url,
      headers: { 'Accept': 'application/json', 'Authorization': 'Bearer $token', 'Content-Type': 'application/json', },
      body: jsonEncode(body),
    );

    final responseData = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return responseData;
    }

    throw Exception(responseData['message'] ?? 'Ошибка обновления');
  }
}