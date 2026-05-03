import 'package:candlesticks/candlesticks.dart';
import 'package:flutter/foundation.dart';

import '../../../core/enums/view_status.dart';
import '../../../domain/entities/candle_entity.dart';
import '../../../domain/usecases/load_stock_detail_usecase.dart';
import '../../../utils/logger.dart';
import 'stock_detail_state.dart';

class StockDetailViewModel extends ChangeNotifier {
  StockDetailViewModel({
    required String ticker,
    required LoadStockDetailUseCase loadStockDetail,
  }) : _ticker = ticker,
       _loadStockDetail = loadStockDetail;

  final String _ticker;
  final LoadStockDetailUseCase _loadStockDetail;

  StockDetailState _state = const StockDetailState();

  StockDetailState get state => _state;
  String get ticker => _ticker;

  Future<void> load() async {
    _state = _state.copyWith(status: ViewStatus.loading, clearMessage: true);
    notifyListeners();

    try {
      final result = await _loadStockDetail.execute(_ticker);
      _state = _state.copyWith(
        status: ViewStatus.success,
        stockInfo: result.stockInfo,
        candles: result.candles.map(_toCandle).toList(growable: false),
      );
    } catch (error, stackTrace) {
      logger.e('stock detail load failed', error: error, stackTrace: stackTrace);
      _state = _state.copyWith(
        status: ViewStatus.error,
        message: 'Failed to load stock details.',
      );
    }

    notifyListeners();
  }

  Candle _toCandle(CandleEntity e) => Candle(
    date: e.date,
    high: e.high,
    low: e.low,
    open: e.open,
    close: e.close,
    volume: e.volume,
  );
}
