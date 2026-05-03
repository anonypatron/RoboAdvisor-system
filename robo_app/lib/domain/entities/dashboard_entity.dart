import 'holding_entity.dart';

class DashboardEntity {
  const DashboardEntity({
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
  final List<HoldingEntity> holdings;
}
