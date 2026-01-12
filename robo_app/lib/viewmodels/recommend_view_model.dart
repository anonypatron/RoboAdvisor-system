import 'package:flutter/material.dart';
import '../models/recommendation.dart';
import '../services/api_service.dart';
import '../utils/logger.dart';

class RecommendViewModel extends ChangeNotifier {
  List<Recommendation> _items = [];
  bool _isLoading = false;
  DateTime? _lastFetchTime;

  List<Recommendation> get items => _items;
  bool get isLoading => _isLoading;

  bool _isSameDay(DateTime? date1, DateTime date2) {
    if (date1 == null) return false;

    return date1.year == date2.year &&
            date1.month == date2.month &&
            date1.day == date2.day;
  }
  
  /* 
    추천 종목 가져오기
    데이터가 이미 있으면 캐시를 사용
    단, 장투에서만 사용할 것. 단기에서는 매 초가 중요하기 때문에 매번 refresh해야함!
  */
  Future<void> fetchRecommendations({bool forceRefresh = false}) async {
    final now = DateTime.now();

    if (_items.isNotEmpty && !forceRefresh && _isSameDay(_lastFetchTime, now)) {
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _items = await ApiService.fetchRecommendations();
      _lastFetchTime = DateTime.now();
    } catch (e) {
      logger.e("추천 종목 로드 실패", error: e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
