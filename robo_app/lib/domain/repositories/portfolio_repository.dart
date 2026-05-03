import '../entities/dashboard_entity.dart';

abstract class PortfolioRepository {
  Future<DashboardEntity> fetchDashboard();

  Future<void> buyStock(String ticker, double amount);

  Future<void> sellStock(String ticker, int quantity);
}
