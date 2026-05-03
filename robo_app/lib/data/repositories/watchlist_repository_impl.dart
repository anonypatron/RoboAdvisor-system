import '../../domain/repositories/watchlist_repository.dart';
import '../datasources/remote/robo_remote_data_source.dart';

class WatchlistRepositoryImpl implements WatchlistRepository {
  WatchlistRepositoryImpl({required RoboRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final RoboRemoteDataSource _remoteDataSource;

  @override
  Future<void> addToWatchlist(String ticker) {
    return _remoteDataSource.addToWatchlist(ticker);
  }

  @override
  Future<List<String>> fetchWatchlist() {
    return _remoteDataSource.fetchWatchlist();
  }

  @override
  Future<void> removeFromWatchlist(String ticker) {
    return _remoteDataSource.removeFromWatchlist(ticker);
  }
}
