// ================= IMPORTS =================

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;


// ================= SERVICE =================

/// Сервис для работы с API
class ConnectApiService {
  // Singleton
  static final ConnectApiService _instance = ConnectApiService._internal();
  factory ConnectApiService() => _instance;
  ConnectApiService._internal();

  // ---------------- VARIABLES ----------------
  static String? _baseUrl;
  static String? _apiUrl;
  static int? _timeout;

  // ================= INIT =================
  /// Инициализация сервиса (вызывать в main.dart)
  static Future<void> init() async {
    try {
      await dotenv.load(fileName: ".env");

      // Выбор базового URL в зависимости от платформы
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        _baseUrl = dotenv.env['API_URL_IOS'] ?? 'http://127.0.0.1:8000/api';
      } else {
        _baseUrl = dotenv.env['API_URL_ANDROID'] ?? 'http://10.0.2.2:8000/api';
      }

      // Таймаут по умолчанию
      _timeout = int.tryParse(dotenv.env['API_TIMEOUT'] ?? '30') ?? 30;

      // Формируем полный API URL
      _apiUrl = _baseUrl;

      debugPrint('========== CONNECT API SERVICE ==========');
      debugPrint('Платформа: $defaultTargetPlatform');
      debugPrint('Base URL: $_baseUrl');
      debugPrint('API URL: $_apiUrl');
      debugPrint('Timeout: $_timeout секунд');
      debugPrint('=========================================');

    } catch (e) {
      debugPrint('[-] Ошибка загрузки .env файла: $e');
    }
  }


  // ================= GETTERS =================
  static String get baseUrl => _baseUrl ?? 'http://10.0.2.2:8000/api';
  static String get apiUrl => _apiUrl ?? baseUrl;
  static int get timeout => _timeout ?? 30;


  // ================= METHODS =================

  /// Обновление API URL (например, при изменении IP)
  static Future<void> updateApiUrl(String newUrl) async {
    _baseUrl = newUrl;
    _apiUrl = newUrl;
    debugPrint('[+] API URL обновлен: $newUrl');
  }

  /// Получение полного URL для конкретного эндпоинта
  static String endpoint(String path) {
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    return '$apiUrl/$cleanPath';
  }

  /// Проверка доступности API
  static Future<bool> checkApiConnection() async {
    try {
      final url = Uri.parse('$apiUrl/health');
      final response = await http
          .get(url)
          .timeout(Duration(seconds: timeout));

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('[-] API недоступен: $e');
      return false;
    }
  }
}
