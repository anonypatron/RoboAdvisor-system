import 'package:flutter/foundation.dart';

import '../../../core/enums/view_status.dart';
import '../../../domain/usecases/buy_stock_usecase.dart';
import '../../../domain/usecases/load_dashboard_usecase.dart';
import '../../../domain/usecases/sell_stock_usecase.dart';
import '../../../utils/logger.dart';
import 'dashboard_state.dart';

class DashboardViewModel extends ChangeNotifier {
  DashboardViewModel({
    required LoadDashboardUseCase loadDashboard,
    required BuyStockUseCase buyStock,
    required SellStockUseCase sellStock,
  }) : _loadDashboard = loadDashboard,
       _buyStock = buyStock,
       _sellStock = sellStock;

  final LoadDashboardUseCase _loadDashboard;
  final BuyStockUseCase _buyStock;
  final SellStockUseCase _sellStock;

  DashboardState _state = const DashboardState();

  DashboardState get state => _state;

  Future<void> loadIfNeeded() async {
    if (_state.status == ViewStatus.initial) {
      await loadDashboard();
    }
  }

  Future<void> loadDashboard() async {
    _state = _state.copyWith(status: ViewStatus.loading, clearMessage: true);
    notifyListeners();

    try {
      final data = await _loadDashboard.execute();
      _state = _state.copyWith(
        status: data.holdings.isEmpty ? ViewStatus.empty : ViewStatus.success,
        data: data,
        clearMessage: true,
      );
    } catch (error, stackTrace) {
      logger.e('dashboard load failed', error: error, stackTrace: stackTrace);
      _state = _state.copyWith(
        status: ViewStatus.error,
        message: 'Failed to load portfolio data.',
      );
    }

    notifyListeners();
  }

  Future<bool> buyStock(String ticker, double amount) async {
    return _runTrade(action: () => _buyStock.execute(ticker, amount));
  }

  Future<bool> sellStock(String ticker, int quantity) async {
    return _runTrade(action: () => _sellStock.execute(ticker, quantity));
  }

  Future<bool> _runTrade({required Future<void> Function() action}) async {
    _state = _state.copyWith(isSubmittingTrade: true, clearMessage: true);
    notifyListeners();

    try {
      await action();
      await loadDashboard();
      return true;
    } catch (error, stackTrace) {
      logger.e('trade request failed', error: error, stackTrace: stackTrace);
      _state = _state.copyWith(
        isSubmittingTrade: false,
        message: 'Trade request failed.',
      );
      notifyListeners();
      return false;
    } finally {
      if (_state.isSubmittingTrade) {
        _state = _state.copyWith(isSubmittingTrade: false);
        notifyListeners();
      }
    }
  }
}
