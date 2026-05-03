class HoldingEntity {
  const HoldingEntity({
    required this.ticker,
    required this.qty,
    required this.avgPrice,
    required this.currentPrice,
    required this.marketValue,
    required this.profitAmount,
    required this.returnPct,
  });

  final String ticker;
  final int qty;
  final double avgPrice;
  final double currentPrice;
  final double marketValue;
  final double profitAmount;
  final double returnPct;
}
