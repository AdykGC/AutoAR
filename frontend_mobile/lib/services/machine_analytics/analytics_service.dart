// services/machine_analytics/analytics_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend_mobile/models/analytics_data.dart';
/* [ Service ] */
import 'package:frontend_mobile/services/connect_api_service.dart';
import 'package:frontend_mobile/services/auth_token_service.dart';

class MachineAnalyticsService {
  static Future<AnalyticsData> getAnalytics({
    required int machineId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final token = await AuthTokenService.getToken();
    if (token == null) { throw Exception('Токен не найден'); }


    final baseUrl = ConnectApiService.apiUrl;
    final uri = Uri.parse('$baseUrl/analytics/machine/$machineId').replace( queryParameters: { 'start': startDate.toIso8601String(), 'end': endDate.toIso8601String(), }, );
    final response = await http.get( uri, headers: { 'Accept': 'application/json', 'Authorization': 'Bearer $token', }, );


    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return AnalyticsData.fromJson(json['data']);
    } else if (response.statusCode == 401) {
      throw Exception('Неавторизован');
    } else {
      throw Exception('Ошибка загрузки аналитики: ${response.statusCode}');
    }
  }
}