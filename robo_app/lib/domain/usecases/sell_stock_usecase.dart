import '../repositories/portfolio_repository.dart';

class SellStockUseCase {
  SellStockUseCase(this._repository);

  final PortfolioRepository _repository;

  Future<void> execute(String ticker, int quantity) =>
      _repository.sellStock(ticker, quantity);
}
