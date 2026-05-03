import 'dart:convert';

import 'package:candlesticks/candlesticks.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../../../models/candle.dart';
import '../../../models/dashboard_data.dart';
import '../../../models/recommendation.dart';
import '../../../models/stock_info.dart';

class RoboRemoteDataSource {
  RoboRemoteDataSource({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  String get baseUrl {
    // Centralize endpoint resolution so screens never hardcode API addresses.
    final String? envUrl = dotenv.env['API_URL']?.trim();
    if (envUrl == null || envUrl.isEmpty) {
      return 'http://127.0.0.1:8000';
    }
    return envUrl;
  }

  Future<DashboardData> fetchDashboard() async {
    final Map<String, dynamic> json = await _getMap('/dashboard');
    return DashboardData.fromJson(json);
  }

  Future<void> buyStock(String ticker, double amount) async {
    await _post(
      '/trade/buy',
      body: <String, dynamic>{'ticker': ticker, 'amount': amount},
    );
  }

  Future<void> sellStock(String ticker, int quantity) async {
    await _post(
      '/trade/sell',
      body: <String, dynamic>{'ticker': ticker, 'quantity': quantity},
    );
  }

  Future<List<Recommendation>> fetchRecommendations() async {
    final List<dynamic> json = await _getList('/recommendations');
    return json
        .map(
          (dynamic item) =>
              Recommendation.fromJson(item as Map<String, dynamic>),
        )
        .toList(growable: false);
  }

  Future<List<Candle>> fetchStockHistory(String ticker) async {
    final List<dynamic> json = await _getList(
      '/stock/$ticker/history?period=5y',
    );
    return json
        .map((dynamic item) => StockApi.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<StockInfo> fetchStockInfo(String ticker) async {
    final Map<String, dynamic> json = await _getMap('/stock/$ticker/info');
    return StockInfo.fromJson(json);
  }

  Future<List<String>> fetchWatchlist() async {
    final List<dynamic> json = await _getList('/watchlist');
    return List<String>.from(json);
  }

  Future<void> addToWatchlist(String ticker) async {
    await _post('/watchlist', body: <String, dynamic>{'ticker': ticker});
  }

  Future<void> removeFromWatchlist(String ticker) async {
    await _delete('/watchlist/$ticker');
  }

  Future<List<String>> searchStocks(String query) async {
    final List<dynamic> json = await _getList('/watchlist/search?q=$query');
    return List<String>.from(json);
  }

  Future<Map<String, dynamic>> _getMap(String path) async {
    final dynamic response = await _readResponse(_client.get(_buildUri(path)));
    return response as Map<String, dynamic>;
  }

  Future<List<dynamic>> _getList(String path) async {
    final dynamic response = await _readResponse(_client.get(_buildUri(path)));
    return response as List<dynamic>;
  }

  Future<void> _post(String path, {required Map<String, dynamic> body}) async {
    await _readResponse(
      _client.post(
        _buildUri(path),
        headers: const <String, String>{'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ),
    );
  }

  Future<void> _delete(String path) async {
    await _readResponse(_client.delete(_buildUri(path)));
  }

  Future<dynamic> _readResponse(Future<http.Response> request) async {
    final http.Response response = await request;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Request failed: ${response.statusCode} ${response.body}',
      );
    }

    if (response.body.isEmpty) {
      return null;
    }

    return jsonDecode(response.body);
  }

  Uri _buildUri(String path) => Uri.parse('$baseUrl$path');
}
