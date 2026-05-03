import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../../../domain/entities/holding_entity.dart';
import '../../../stock_detail/presentation/screens/stock_detail_screen.dart';

class DashboardHoldingItem extends StatelessWidget {
  const DashboardHoldingItem({super.key, required this.holding});

  final HoldingEntity holding;

  @override
  Widget build(BuildContext context) {
    final Color profitColor = holding.returnPct >= 0
        ? AppColors.accent
        : AppColors.danger;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => StockDetailScreen(ticker: holding.ticker),
            ),
          );
        },
        child: Padding(
          padding: AppSpacing.card,
          child: Row(
            children: <Widget>[
              CircleAvatar(child: Text(holding.ticker.substring(0, 1))),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(holding.ticker, style: textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      '${holding.qty} shares | Avg ${AppFormatters.currency(holding.avgPrice)}',
                      style: textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      'Now ${AppFormatters.currency(holding.currentPrice)} | Value ${AppFormatters.currency(holding.marketValue)}',
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    AppFormatters.signedCurrency(holding.profitAmount),
                    style: textTheme.titleMedium?.copyWith(color: profitColor),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    AppFormatters.signedPercent(holding.returnPct),
                    style: textTheme.bodySmall?.copyWith(color: profitColor),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
