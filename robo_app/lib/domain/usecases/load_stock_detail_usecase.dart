import '../entities/candle_entity.dart';
import '../entities/stock_info_entity.dart';
import '../repositories/market_repository.dart';

class StockDetailResult {
  const StockDetailResult({required this.stockInfo, required this.candles});

  final StockInfoEntity stockInfo;
  final List<CandleEntity> candles;
}

class LoadStockDetailUseCase {
  LoadStockDetailUseCase(this._repository);

  final MarketRepository _repository;

  Future<StockDetailResult> execute(String ticker) async {
    final results = await Future.wait<Object>([
      _repository.fetchStockInfo(ticker),
      _repository.fetchStockHistory(ticker),
    ]);
    return StockDetailResult(
      stockInfo: results[0] as StockInfoEntity,
      candles: results[1] as List<CandleEntity>,
    );
  }
}
