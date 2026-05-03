import '../repositories/watchlist_repository.dart';

class ToggleWatchlistUseCase {
  ToggleWatchlistUseCase(this._repository);

  final WatchlistRepository _repository;

  Future<void> add(String ticker) => _repository.addToWatchlist(ticker);

  Future<void> remove(String ticker) => _repository.removeFromWatchlist(ticker);
}
