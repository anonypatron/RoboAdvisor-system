abstract class WatchlistRepository {
  Future<List<String>> fetchWatchlist();

  Future<void> addToWatchlist(String ticker);

  Future<void> removeFromWatchlist(String ticker);
}
