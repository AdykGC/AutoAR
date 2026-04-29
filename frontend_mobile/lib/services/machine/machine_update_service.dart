import 'dart:convert';
import 'package:http/http.dart' as http;
/* [ Services ] */
import 'package:frontend_mobile/services/connect_api_service.dart';
import 'package:frontend_mobile/services/auth_token_service.dart';

class MachineUpdateService {
  static Future<Map<String, dynamic>> update({
    required int id,
    required String name,
    required String type,
    String? location,
    String? serialNumber,
    String? macAddress,        // ✅ добавь
    String? connectionType,
    double? installPrice,
    double? priceAdjustment,
    double? latitude,
    double? longitude,
    bool? isActive,
  }) async {
    final token = await AuthTokenService.getToken();
    if (token == null) { throw Exception('Токен не найден'); }
    final url = Uri.parse( ConnectApiService.endpoint('machines/update/$id') );

    final Map<String, dynamic> body = {
      'name': name,
      'type': type,
      if (location != null && location.isNotEmpty) 'location': location,
      if (serialNumber != null && serialNumber.isNotEmpty) 'serial_number': serialNumber, // ✅ исправь ключ
      if (macAddress != null && macAddress.isNotEmpty) 'mac_address': macAddress,         // ✅ добавь
      if (connectionType != null) 'connection_type': connectionType,
      if (installPrice != null) 'install_price': installPrice,
      if (priceAdjustment != null) 'price_adjustment': priceAdjustment,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (isActive != null) 'is_active': isActive,
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