import '../../domain/entities/candle_entity.dart';
import '../../domain/entities/recommendation_entity.dart';
import '../../domain/entities/stock_info_entity.dart';
import '../../domain/repositories/market_repository.dart';
import '../datasources/remote/robo_remote_data_source.dart';

class MarketRepositoryImpl implements MarketRepository {
  MarketRepositoryImpl({required RoboRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final RoboRemoteDataSource _remoteDataSource;

  @override
  Future<List<RecommendationEntity>> fetchRecommendations() async {
    final dtos = await _remoteDataSource.fetchRecommendations();
    return dtos
        .map(
          (r) => RecommendationEntity(
            ticker: r.ticker,
            date: r.date,
            close: r.close,
            signalType: r.signalType,
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<List<CandleEntity>> fetchStockHistory(String ticker) async {
    final candles = await _remoteDataSource.fetchStockHistory(ticker);
    return candles
        .map(
          (c) => CandleEntity(
            date: c.date,
            open: c.open,
            high: c.high,
            low: c.low,
            close: c.close,
            volume: c.volume,
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<StockInfoEntity> fetchStockInfo(String ticker) async {
    final dto = await _remoteDataSource.fetchStockInfo(ticker);
    return StockInfoEntity(
      ticker: dto.ticker,
      name: dto.name,
      currentPrice: dto.currentPrice,
      peRatio: dto.peRatio,
      marketCap: dto.marketCap,
      sector: dto.sector,
    );
  }

  @override
  Future<List<String>> searchStocks(String query) {
    return _remoteDataSource.searchStocks(query);
  }
}
