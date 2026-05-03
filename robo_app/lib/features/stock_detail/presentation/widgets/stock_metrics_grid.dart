import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../../../domain/entities/stock_info_entity.dart';
import 'stock_metric_item.dart';

class StockMetricsGrid extends StatelessWidget {
  const StockMetricsGrid({super.key, required this.stockInfo});

  final StockInfoEntity stockInfo;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.55,
      crossAxisSpacing: AppSpacing.sm,
      mainAxisSpacing: AppSpacing.sm,
      children: <Widget>[
        StockMetricItem(
          label: 'Current price',
          value: AppFormatters.currency(stockInfo.currentPrice),
        ),
        StockMetricItem(
          label: 'P/E ratio',
          value: stockInfo.peRatio.toStringAsFixed(2),
        ),
        StockMetricItem(
          label: 'Market cap',
          value: AppFormatters.marketCap(stockInfo.marketCap),
        ),
        StockMetricItem(label: 'Sector', value: stockInfo.sector),
      ],
    );
  }
}
