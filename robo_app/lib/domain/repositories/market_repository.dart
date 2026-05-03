import '../entities/candle_entity.dart';
import '../entities/recommendation_entity.dart';
import '../entities/stock_info_entity.dart';

abstract class MarketRepository {
  Future<List<RecommendationEntity>> fetchRecommendations();

  Future<List<CandleEntity>> fetchStockHistory(String ticker);

  Future<StockInfoEntity> fetchStockInfo(String ticker);

  Future<List<String>> searchStocks(String query);
}
