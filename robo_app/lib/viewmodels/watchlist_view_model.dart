import 'package:flutter/material.dart';
import '../services/api_service.dart';

class WatchlistViewModel extends ChangeNotifier {
  List<String> _favorites = []; // 관심 종목 리스트
  List<String> _searchResults = []; // 검색 결과

  List<String> get favorites => _favorites;
  List<String> get searchResults => _searchResults;

  // 관심 종목 불러오기
  Future<void> fetchWatchlist() async {
    _favorites = await ApiService.fetchWatchlist();
    notifyListeners();
  }

  // 관심 종목 토글 (추가/삭제)
  Future<void> toggleFavorite(String ticker) async {
    if (_favorites.contains(ticker)) {
      await ApiService.removeFromWatchlist(ticker);
      _favorites.remove(ticker);
    } else {
      await ApiService.addToWatchlist(ticker);
      _favorites.add(ticker);
    }
    notifyListeners();
  }

  // 검색
  Future<void> search(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
    } else {
      _searchResults = await ApiService.searchStocks(query);
    }
    notifyListeners();
  }
}
