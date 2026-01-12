import 'package:freezed_annotation/freezed_annotation.dart';

part 'recommendation.freezed.dart';
part 'recommendation.g.dart';

// flutter pub run build_runner build --delete-conflicting-outputs
@freezed
abstract class Recommendation with _$Recommendation {
  
  factory Recommendation({
    required String ticker,
    required String date,
    required double close,
    @JsonKey(name: 'signal_type') required String signalType,
  }) = _Recommendation;

  factory Recommendation.fromJson(Map<String, dynamic> json) => _$RecommendationFromJson(json);
}
