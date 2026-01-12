import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:robo_app/models/recommendation.dart';
import 'package:candlesticks/candlesticks.dart';
import '../models/dashboard_data.dart';
import '../models/candle.dart';
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

  static Future<bool> sellStock(String ticker, int quantity) async {
    final res = await http.post(
      Uri.parse('$baseUrl/trade/sell'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "ticker": ticker,
        "quantity": quantity,
      }),
    );

    if (res.statusCode == 200) {
      return true;
    }
    else {
      logger.e("매도 실패: ${res.body}");
      return false;
    }
  }

  static Future<List<Recommendation>> fetchRecommendations() async {
    final res = await http.get(Uri.parse('$baseUrl/recommendations'));

    if (res.statusCode == 200) {
      List<dynamic> list = jsonDecode(res.body);
      return list
              .map((json) => Recommendation.fromJson(json))
              .toList();
    }
    else {
      logger.e("Recommendations fetch failed");
      throw Exception("Failed to load recommendations");
    }
  }

  static Future<List<Candle>> fetchStockHistory(String ticker) async {
    final response = await http.get(Uri.parse('$baseUrl/stock/$ticker/history?period=5y'));

    if (response.statusCode == 200) {
      List<dynamic> list = jsonDecode(response.body);
      return list.map((e) => StockApi.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load stock history');
    }
  }

  static Future<List<String>> fetchWatchlist() async {
    final response = await http.get(Uri.parse('$baseUrl/watchlist'));
    if (response.statusCode == 200) {
      return List<String>.from(jsonDecode(response.body));
    }
    return [];
  }

  // 추가
  static Future<void> addToWatchlist(String ticker) async {
    await http.post(
      Uri.parse('$baseUrl/watchlist'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"ticker": ticker}),
    );
  }

  // 삭제
  static Future<void> removeFromWatchlist(String ticker) async {
    await http.delete(Uri.parse('$baseUrl/watchlist/$ticker'));
  }

  // 검색
  static Future<List<String>> searchStocks(String query) async {
    final response = await http.get(Uri.parse('$baseUrl/watchlist/search?q=$query'));
    if (response.statusCode == 200) {
      return List<String>.from(jsonDecode(response.body));
    }
    return [];
  }
  
}
