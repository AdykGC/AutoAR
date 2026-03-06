// machine_create_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
/* [ Service ] */
import 'connect_api_service.dart';
import 'auth_token_service.dart';

class MachineCreateService {
    static final storage = FlutterSecureStorage();

    static Future<Map<String, dynamic>> create({
        required String name,
        required String type,
        String? location,
        String? serialNumber,
    }) async {
        final token = await AuthTokenService.getToken();
        if (token == null) {
            throw Exception('Токен не найден');
        }

        final url = Uri.parse( ConnectApiService.endpoint('machines/create'), );
        final Map<String, dynamic> body = {
        'name': name,
        'type': type,
        if (location != null && location.isNotEmpty) 'location': location,
        if (serialNumber != null && serialNumber.isNotEmpty)
            'serial_number': serialNumber,
        };

    debugPrint('📦 Body: $body');

    final response = await http.post( url, headers: { 'Accept': 'application/json', 'Authorization': 'Bearer $token', 'Content-Type': 'application/json', }, body: jsonEncode(body), ).timeout( Duration(seconds: ConnectApiService.timeout), );

    debugPrint('Статус: ${response.statusCode}');
    debugPrint('Ответ API: ${response.body}');

    final responseData = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) { return responseData; }
    if (response.statusCode == 422) {
        final errors = responseData['errors'] as Map<String, dynamic>;
        throw Exception( errors.values.map((e) => (e as List).first).join('\n'), );
    }
    throw Exception(responseData['message'] ?? 'Ошибка сервера');
    }
}