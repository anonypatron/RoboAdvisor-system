class StockInfoEntity {
  const StockInfoEntity({
    required this.ticker,
    required this.name,
    required this.currentPrice,
    required this.peRatio,
    required this.marketCap,
    required this.sector,
  });

  final String ticker;
  final String name;
  final double currentPrice;
  final double peRatio;
  final double marketCap;
  final String sector;
}
