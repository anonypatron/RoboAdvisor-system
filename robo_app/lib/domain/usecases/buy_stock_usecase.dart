import '../repositories/portfolio_repository.dart';

class BuyStockUseCase {
  BuyStockUseCase(this._repository);

  final PortfolioRepository _repository;

  Future<void> execute(String ticker, double amount) =>
      _repository.buyStock(ticker, amount);
}
