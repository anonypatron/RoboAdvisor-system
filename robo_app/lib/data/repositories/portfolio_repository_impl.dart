import '../../domain/entities/dashboard_entity.dart';
import '../../domain/entities/holding_entity.dart';
import '../../domain/repositories/portfolio_repository.dart';
import '../datasources/remote/robo_remote_data_source.dart';

class PortfolioRepositoryImpl implements PortfolioRepository {
  PortfolioRepositoryImpl({required RoboRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final RoboRemoteDataSource _remoteDataSource;

  @override
  Future<DashboardEntity> fetchDashboard() async {
    final dto = await _remoteDataSource.fetchDashboard();
    return DashboardEntity(
      totalAsset: dto.totalAsset,
      cashBalance: dto.cashBalance,
      stockValue: dto.stockValue,
      totalProfit: dto.totalProfit,
      totalReturnRate: dto.totalReturnRate,
      holdings: dto.holdings
          .map(
            (h) => HoldingEntity(
              ticker: h.ticker,
              qty: h.qty,
              avgPrice: h.avgPrice,
              currentPrice: h.currentPrice,
              marketValue: h.marketValue,
              profitAmount: h.profitAmount,
              returnPct: h.returnPct,
            ),
          )
          .toList(growable: false),
    );
  }

  @override
  Future<void> buyStock(String ticker, double amount) {
    return _remoteDataSource.buyStock(ticker, amount);
  }

  @override
  Future<void> sellStock(String ticker, int quantity) {
    return _remoteDataSource.sellStock(ticker, quantity);
  }
}
