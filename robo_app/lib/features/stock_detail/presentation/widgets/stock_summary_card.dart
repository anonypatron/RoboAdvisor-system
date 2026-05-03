import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../../../domain/entities/stock_info_entity.dart';

class StockSummaryCard extends StatelessWidget {
  const StockSummaryCard({super.key, required this.stockInfo});

  final StockInfoEntity stockInfo;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: AppSpacing.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(stockInfo.name, style: textTheme.headlineMedium),
            const SizedBox(height: AppSpacing.xxs),
            Text(stockInfo.ticker, style: textTheme.bodySmall),
            const SizedBox(height: AppSpacing.md),
            Text(
              AppFormatters.currency(stockInfo.currentPrice),
              style: textTheme.headlineLarge,
            ),
          ],
        ),
      ),
    );
  }
}
