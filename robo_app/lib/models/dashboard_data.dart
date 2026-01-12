import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_data.freezed.dart';
part 'dashboard_data.g.dart';

// flutter pub run build_runner build --delete-conflicting-outputs
@freezed
abstract class Holding with _$Holding{

  factory Holding({
    required String ticker,
    required int qty,
    @JsonKey(name: 'avg_price') required double avgPrice,
    @JsonKey(name: 'return_pct') required double returnPct,
  }) = _Holding;

  factory Holding.fromJson(Map<String, dynamic> json) => _$HoldingFromJson(json);
}

@freezed
abstract class DashboardData with _$DashboardData {
  // 불변 객체 (@Data + @Builder)와 유사함.
  factory DashboardData({
    @JsonKey(name: 'total_asset') required double totalAsset,
    @JsonKey(name: 'cash_balance') required double cashBalance,
    @JsonKey(name: 'stock_value') required double stockValue,
    required List<Holding> holdings,
  }) = _DashboardData;

  factory DashboardData.fromJson(Map<String, dynamic> json) => _$DashboardDataFromJson(json);
}
