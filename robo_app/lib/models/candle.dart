import 'package:candlesticks/candlesticks.dart';

// 라이브러리 호환성을 위해 freezed 사용 안함
class StockApi {
  static Candle fromJson(Map<String, dynamic> json) {
    return Candle(
      date: DateTime.parse(json['date']),
      high: (json['high'] as num).toDouble(),
      low: (json['low'] as num).toDouble(),
      open: (json['open'] as num).toDouble(),
      close: (json['close'] as num).toDouble(),
      volume: (json['volume'] as num).toDouble(),
    );
  }
}
