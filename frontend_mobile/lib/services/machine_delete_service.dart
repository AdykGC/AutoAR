import 'package:http/http.dart' as http;
import 'connect_api_service.dart';
import 'auth_token_service.dart';

class MachineDeleteService {
    static Future<void> delete(int id) async {
        final token = await AuthTokenService.getToken();
        if (token == null) { throw Exception('Токен не найден'); }
        final url = Uri.parse( ConnectApiService.endpoint('machines/delete/$id'), );
        final response = await http.post( url, headers: { 'Accept': 'application/json', 'Authorization': 'Bearer $token', }, );
        if (response.statusCode < 200 || response.statusCode >= 300) {
            throw Exception('Ошибка удаления');
        }
    }
}