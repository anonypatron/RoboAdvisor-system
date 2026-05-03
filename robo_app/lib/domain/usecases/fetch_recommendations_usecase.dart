import '../entities/recommendation_entity.dart';
import '../repositories/market_repository.dart';

class FetchRecommendationsUseCase {
  FetchRecommendationsUseCase(this._repository);

  final MarketRepository _repository;

  Future<List<RecommendationEntity>> execute() =>
      _repository.fetchRecommendations();
}
