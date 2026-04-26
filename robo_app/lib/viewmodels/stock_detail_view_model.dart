import 'package:candlesticks/candlesticks.dart';
import 'package:flutter/material.dart';

import '../models/stock_info.dart';
import '../services/api_service.dart';
import '../utils/logger.dart';

class StockDetailViewModel extends ChangeNotifier {
  StockDetailViewModel(this.ticker);

  final String ticker;

  StockInfo? _stockInfo;
  List<Candle> _candles = [];
  bool _isLoading = false;
  String? _errorMessage;

  StockInfo? get stockInfo => _stockInfo;
  List<Candle> get candles => _candles;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetch() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        ApiService.fetchStockInfo(ticker),
        ApiService.fetchStockHistory(ticker),
      ]);

      _stockInfo = results[0] as StockInfo;
      _candles = results[1] as List<Candle>;
    } catch (e) {
      _errorMessage = '종목 상세 데이터를 불러오지 못했습니다.';
      logger.e('stock detail fetch failed', error: e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
