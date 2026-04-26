class Holding {
  const Holding({
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

  factory Holding.fromJson(Map<String, dynamic> json) {
    return Holding(
      ticker: json['ticker'] as String,
      qty: (json['qty'] as num).toInt(),
      avgPrice: (json['avg_price'] as num).toDouble(),
      currentPrice: (json['current_price'] as num?)?.toDouble() ?? 0,
      marketValue: (json['market_value'] as num?)?.toDouble() ?? 0,
      profitAmount: (json['profit_amount'] as num?)?.toDouble() ?? 0,
      returnPct: (json['return_pct'] as num).toDouble(),
    );
  }
}

class DashboardData {
  const DashboardData({
    required this.totalAsset,
    required this.cashBalance,
    required this.stockValue,
    required this.totalProfit,
    required this.totalReturnRate,
    required this.holdings,
  });

  final double totalAsset;
  final double cashBalance;
  final double stockValue;
  final double totalProfit;
  final double totalReturnRate;
  final List<Holding> holdings;

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      totalAsset: (json['total_asset'] as num).toDouble(),
      cashBalance: (json['cash_balance'] as num).toDouble(),
      stockValue: (json['stock_value'] as num).toDouble(),
      totalProfit: (json['total_profit'] as num?)?.toDouble() ?? 0,
      totalReturnRate: (json['total_return_rate'] as num?)?.toDouble() ?? 0,
      holdings: (json['holdings'] as List<dynamic>)
          .map((item) => Holding.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
