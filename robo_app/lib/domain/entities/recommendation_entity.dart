class RecommendationEntity {
  const RecommendationEntity({
    required this.ticker,
    required this.date,
    required this.close,
    required this.signalType,
  });

  final String ticker;
  final String date;
  final double close;
  final String signalType;
}
