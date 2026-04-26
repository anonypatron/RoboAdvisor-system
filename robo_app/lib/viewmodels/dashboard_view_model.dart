import 'package:flutter/material.dart';

import '../models/dashboard_data.dart';
import '../services/api_service.dart';
import '../utils/logger.dart';

class DashboardViewModel extends ChangeNotifier {
  DashboardData? _data;
  bool _isLoading = false;
  String? _errorMessage;

  DashboardData? get data => _data;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchDashboard() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _data = await ApiService.fetchDashboard();
    } catch (e) {
      _errorMessage = '대시보드 데이터를 불러오지 못했습니다.';
      logger.e('dashboard fetch failed', error: e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> buyStock(String ticker, double amount) async {
    final success = await ApiService.buyStock(ticker, amount);
    if (success) {
      await fetchDashboard();
    }
    return success;
  }

  Future<bool> sellStock(String ticker, int quantity) async {
    final success = await ApiService.sellStock(ticker, quantity);
    if (success) {
      await fetchDashboard();
    }
    return success;
  }
}
