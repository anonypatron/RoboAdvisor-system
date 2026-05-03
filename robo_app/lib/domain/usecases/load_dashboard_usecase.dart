import '../entities/dashboard_entity.dart';
import '../repositories/portfolio_repository.dart';

class LoadDashboardUseCase {
  LoadDashboardUseCase(this._repository);

  final PortfolioRepository _repository;

  Future<DashboardEntity> execute() => _repository.fetchDashboard();
}
