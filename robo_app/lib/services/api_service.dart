import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/dashboard_data.dart';
import '../utils/logger.dart';

class ApiService {
  static String get baseUrl => dotenv.env['API_URL'] ?? "http://127.0.0.1:8000"; 

  static Future<DashboardData> fetchDashboard() async {
    try {
      final url = Uri.parse('$baseUrl/dashboard');
      final res = await http.get(url);

      if (res.statusCode == 200) {
        return DashboardData.fromJson(jsonDecode(res.body));
      } else {
        logger.e("API 에러 [${res.statusCode}]: ${res.body}"); // Error 로그
        throw Exception('Failed to load dashboard data');
      }
    } catch (e) {
      logger.e("네트워크 예외 발생", error: e); // 에러와 스택트레이스 같이 출력
      rethrow;
    }
  }

  static Future<bool> buyStock(String ticker, double amount) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/trade/buy'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "ticker": ticker,
          "amount": amount,
        }),
      );
      
      if (res.statusCode == 200) {
        return true;
      }
      else {
        throw Exception('Failed to buy stock');
      }
    } catch (e) {
      logger.e("구매 중 예외 발생", error: e);
      return false;
    }
  }
}
