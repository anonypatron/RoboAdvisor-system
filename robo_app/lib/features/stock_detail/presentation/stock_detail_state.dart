import 'package:candlesticks/candlesticks.dart';

import '../../../core/enums/view_status.dart';
import '../../../domain/entities/stock_info_entity.dart';

class StockDetailState {
  const StockDetailState({
    this.status = ViewStatus.initial,
    this.stockInfo,
    this.candles = const <Candle>[],
    this.message,
  });

  final ViewStatus status;
  final StockInfoEntity? stockInfo;
  final List<Candle> candles;
  final String? message;

  StockDetailState copyWith({
    ViewStatus? status,
    StockInfoEntity? stockInfo,
    List<Candle>? candles,
    String? message,
    bool clearMessage = false,
  }) {
    return StockDetailState(
      status: status ?? this.status,
      stockInfo: stockInfo ?? this.stockInfo,
      candles: candles ?? this.candles,
      message: clearMessage ? null : message ?? this.message,
    );
  }
}
