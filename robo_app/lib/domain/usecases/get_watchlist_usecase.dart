import '../repositories/watchlist_repository.dart';

class GetWatchlistUseCase {
  GetWatchlistUseCase(this._repository);

  final WatchlistRepository _repository;

  Future<List<String>> execute() => _repository.fetchWatchlist();
}
