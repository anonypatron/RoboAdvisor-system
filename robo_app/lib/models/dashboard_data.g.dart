// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Holding _$HoldingFromJson(Map<String, dynamic> json) => _Holding(
  ticker: json['ticker'] as String,
  qty: (json['qty'] as num).toInt(),
  avgPrice: (json['avg_price'] as num).toDouble(),
  returnPct: (json['return_pct'] as num).toDouble(),
);

Map<String, dynamic> _$HoldingToJson(_Holding instance) => <String, dynamic>{
  'ticker': instance.ticker,
  'qty': instance.qty,
  'avg_price': instance.avgPrice,
  'return_pct': instance.returnPct,
};

_DashboardData _$DashboardDataFromJson(Map<String, dynamic> json) =>
    _DashboardData(
      totalAsset: (json['total_asset'] as num).toDouble(),
      cashBalance: (json['cash_balance'] as num).toDouble(),
      stockValue: (json['stock_value'] as num).toDouble(),
      holdings: (json['holdings'] as List<dynamic>)
          .map((e) => Holding.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DashboardDataToJson(_DashboardData instance) =>
    <String, dynamic>{
      'total_asset': instance.totalAsset,
      'cash_balance': instance.cashBalance,
      'stock_value': instance.stockValue,
      'holdings': instance.holdings,
    };
