class Holding {
  final String ticker;
  final int qty;
  final double avgPrice;
  final double returnPct;

  Holding({
    required this.ticker,
    required this.qty,
    required this.avgPrice,
    required this.returnPct,
  });

  factory Holding.fromJson(Map<String, dynamic> json) {
    return Holding(
      ticker: json['ticker'],
      qty: json['qty'],
      avgPrice: (json['avg_price'] as num).toDouble(),
      returnPct: (json['return_pct'] as num).toDouble(),
    );
  }
}

class DashboardData {
  final double totalAsset;
  final double cashBalance;
  final double stockValue;
  final List<Holding> holdings;

  DashboardData({
    required this.totalAsset,
    required this.cashBalance,
    required this.stockValue,
    required this.holdings,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    var list = json['holdings'] as List;
    List<Holding> holdingList = list.map((i) => Holding.fromJson(i)).toList();

    return DashboardData(
      totalAsset: (json['total_asset'] as num).toDouble(),
      cashBalance: (json['cash_balance'] as num).toDouble(),
      stockValue: (json['stock_value'] as num).toDouble(),
      holdings: holdingList,
    );
  }
}
