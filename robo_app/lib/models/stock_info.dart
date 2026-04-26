class StockInfo {
  const StockInfo({
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

  factory StockInfo.fromJson(Map<String, dynamic> json) {
    return StockInfo(
      ticker: json['ticker'] as String,
      name: json['name'] as String,
      currentPrice: (json['current_price'] as num).toDouble(),
      peRatio: (json['pe_ratio'] as num).toDouble(),
      marketCap: (json['market_cap'] as num).toDouble(),
      sector: json['sector'] as String,
    );
  }
}
