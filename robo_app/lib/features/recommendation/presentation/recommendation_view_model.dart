import 'package:flutter/foundation.dart';

import '../../../core/enums/view_status.dart';
import '../../../domain/usecases/fetch_recommendations_usecase.dart';
import '../../../utils/logger.dart';
import 'recommendation_state.dart';

class RecommendationViewModel extends ChangeNotifier {
  RecommendationViewModel({required FetchRecommendationsUseCase fetchRecommendations})
    : _fetchRecommendations = fetchRecommendations;

  final FetchRecommendationsUseCase _fetchRecommendations;

  RecommendationState _state = const RecommendationState();

  RecommendationState get state => _state;

  Future<void> loadIfNeeded() async {
    if (_state.status == ViewStatus.initial) {
      await loadRecommendations();
    }
  }

  Future<void> loadRecommendations({bool forceRefresh = false}) async {
    final DateTime now = DateTime.now();
    if (!forceRefresh &&
        _state.items.isNotEmpty &&
        _isSameDay(_state.lastFetchedAt, now)) {
      return;
    }

    _state = _state.copyWith(status: ViewStatus.loading, clearMessage: true);
    notifyListeners();

    try {
      final items = await _fetchRecommendations.execute();
      _state = _state.copyWith(
        status: items.isEmpty ? ViewStatus.empty : ViewStatus.success,
        items: items,
        lastFetchedAt: now,
      );
    } catch (error, stackTrace) {
      logger.e('recommendation load failed', error: error, stackTrace: stackTrace);
      _state = _state.copyWith(
        status: ViewStatus.error,
        message: 'Failed to load recommendations.',
      );
    }

    notifyListeners();
  }

  bool _isSameDay(DateTime? first, DateTime second) {
    if (first == null) return false;
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }
}
