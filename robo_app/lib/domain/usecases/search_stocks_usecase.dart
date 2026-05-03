import '../repositories/market_repository.dart';

class SearchStocksUseCase {
  SearchStocksUseCase(this._repository);

  final MarketRepository _repository;

  Future<List<String>> execute(String query) =>
      _repository.searchStocks(query);
}
