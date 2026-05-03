import 'package:flutter/foundation.dart';

import '../../../core/enums/view_status.dart';
import '../../../domain/usecases/get_watchlist_usecase.dart';
import '../../../domain/usecases/search_stocks_usecase.dart';
import '../../../domain/usecases/toggle_watchlist_usecase.dart';
import '../../../utils/logger.dart';
import 'search_state.dart';

class SearchViewModel extends ChangeNotifier {
  SearchViewModel({
    required GetWatchlistUseCase getWatchlist,
    required SearchStocksUseCase searchStocks,
    required ToggleWatchlistUseCase toggleWatchlist,
  }) : _getWatchlist = getWatchlist,
       _searchStocks = searchStocks,
       _toggleWatchlist = toggleWatchlist;

  final GetWatchlistUseCase _getWatchlist;
  final SearchStocksUseCase _searchStocks;
  final ToggleWatchlistUseCase _toggleWatchlist;

  SearchState _state = const SearchState();

  SearchState get state => _state;

  Future<void> loadIfNeeded() async {
    if (_state.status == ViewStatus.initial) {
      await loadWatchlist();
    }
  }

  Future<void> loadWatchlist() async {
    _state = _state.copyWith(status: ViewStatus.loading, clearMessage: true);
    notifyListeners();

    try {
      final List<String> favorites = await _getWatchlist.execute();
      _state = _state.copyWith(
        status: favorites.isEmpty ? ViewStatus.empty : ViewStatus.success,
        favorites: favorites,
      );
    } catch (error, stackTrace) {
      logger.e('watchlist load failed', error: error, stackTrace: stackTrace);
      _state = _state.copyWith(
        status: ViewStatus.error,
        message: 'Failed to load watchlist.',
      );
    }

    notifyListeners();
  }

  Future<void> updateQuery(String value) async {
    final String query = value.trim();
    _state = _state.copyWith(
      query: value,
      clearMessage: true,
      results: query.isEmpty ? const <String>[] : _state.results,
      isSearching: query.isNotEmpty,
    );
    notifyListeners();

    if (query.isEmpty) {
      _state = _state.copyWith(isSearching: false);
      notifyListeners();
      return;
    }

    try {
      final List<String> results = await _searchStocks.execute(query);
      _state = _state.copyWith(
        results: results,
        isSearching: false,
        status: _state.favorites.isEmpty ? ViewStatus.empty : ViewStatus.success,
      );
    } catch (error, stackTrace) {
      logger.e('search failed', error: error, stackTrace: stackTrace);
      _state = _state.copyWith(isSearching: false, message: 'Search failed.');
    }

    notifyListeners();
  }

  Future<void> toggleWatchlist(String ticker) async {
    final bool isFavorite = _state.favorites.contains(ticker);

    try {
      if (isFavorite) {
        await _toggleWatchlist.remove(ticker);
        _state = _state.copyWith(
          favorites: _state.favorites
              .where((String item) => item != ticker)
              .toList(growable: false),
          status: _state.favorites.length == 1 ? ViewStatus.empty : _state.status,
        );
      } else {
        await _toggleWatchlist.add(ticker);
        _state = _state.copyWith(
          favorites: <String>[..._state.favorites, ticker],
          status: ViewStatus.success,
        );
      }

      notifyListeners();
    } catch (error, stackTrace) {
      logger.e('watchlist toggle failed', error: error, stackTrace: stackTrace);
      _state = _state.copyWith(message: 'Watchlist update failed.');
      notifyListeners();
    }
  }
}
