import 'dart:convert';

import 'package:candlesticks/candlesticks.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/candle.dart';
import '../models/dashboard_data.dart';
import '../models/recommendation.dart';
import '../models/stock_info.dart';
import '../utils/logger.dart';

class ApiService {
  static String get baseUrl {
    final apiUrl = dotenv.env['API_URL'];

    if (apiUrl == null || apiUrl.isEmpty) {
      throw Exception('API_URL not configured');
    }

    return apiUrl;
  }

  static Future<DashboardData> fetchDashboard() async {
    final res = await http.get(Uri.parse('$baseUrl/dashboard'));
    if (res.statusCode != 200) {
      logger.e('dashboard fetch failed: ${res.statusCode} ${res.body}');
      throw Exception('Failed to load dashboard data');
    }

    return DashboardData.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  static Future<bool> buyStock(String ticker, double amount) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/trade/buy'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'ticker': ticker, 'amount': amount}),
      );
      return res.statusCode == 200;
    } catch (e) {
      logger.e('buy request failed', error: e);
      return false;
    }
  }

  static Future<bool> sellStock(String ticker, int quantity) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/trade/sell'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'ticker': ticker, 'quantity': quantity}),
      );
      return res.statusCode == 200;
    } catch (e) {
      logger.e('sell request failed', error: e);
      return false;
    }
  }

  static Future<List<Recommendation>> fetchRecommendations() async {
    final res = await http.get(Uri.parse('$baseUrl/recommendations'));
    if (res.statusCode != 200) {
      logger.e('recommendations fetch failed: ${res.statusCode} ${res.body}');
      throw Exception('Failed to load recommendations');
    }

    final list = jsonDecode(res.body) as List<dynamic>;
    return list
        .map((json) => Recommendation.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  static Future<List<Candle>> fetchStockHistory(String ticker) async {
    final response = await http.get(
      Uri.parse('$baseUrl/stock/$ticker/history?period=5y'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to load stock history');
    }

    final list = jsonDecode(response.body) as List<dynamic>;
    return list.map((item) => StockApi.fromJson(item as Map<String, dynamic>)).toList();
  }

  static Future<StockInfo> fetchStockInfo(String ticker) async {
    final response = await http.get(Uri.parse('$baseUrl/stock/$ticker/info'));
    if (response.statusCode != 200) {
      throw Exception('Failed to load stock info');
    }

    return StockInfo.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<List<String>> fetchWatchlist() async {
    final response = await http.get(Uri.parse('$baseUrl/watchlist'));
    if (response.statusCode == 200) {
      return List<String>.from(jsonDecode(response.body) as List<dynamic>);
    }
    return [];
  }

  static Future<void> addToWatchlist(String ticker) async {
    await http.post(
      Uri.parse('$baseUrl/watchlist'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'ticker': ticker}),
    );
  }

  static Future<void> removeFromWatchlist(String ticker) async {
    await http.delete(Uri.parse('$baseUrl/watchlist/$ticker'));
  }

  static Future<List<String>> searchStocks(String query) async {
    final response = await http.get(Uri.parse('$baseUrl/watchlist/search?q=$query'));
    if (response.statusCode == 200) {
      return List<String>.from(jsonDecode(response.body) as List<dynamic>);
    }
    return [];
  }
}
