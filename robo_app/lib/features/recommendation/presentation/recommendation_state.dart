import '../../../core/enums/view_status.dart';
import '../../../domain/entities/recommendation_entity.dart';

class RecommendationState {
  const RecommendationState({
    this.status = ViewStatus.initial,
    this.items = const <RecommendationEntity>[],
    this.message,
    this.lastFetchedAt,
  });

  final ViewStatus status;
  final List<RecommendationEntity> items;
  final String? message;
  final DateTime? lastFetchedAt;

  RecommendationState copyWith({
    ViewStatus? status,
    List<RecommendationEntity>? items,
    String? message,
    bool clearMessage = false,
    DateTime? lastFetchedAt,
  }) {
    return RecommendationState(
      status: status ?? this.status,
      items: items ?? this.items,
      message: clearMessage ? null : message ?? this.message,
      lastFetchedAt: lastFetchedAt ?? this.lastFetchedAt,
    );
  }
}
