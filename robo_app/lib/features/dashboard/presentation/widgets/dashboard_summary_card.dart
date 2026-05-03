import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../../../domain/entities/dashboard_entity.dart';

class DashboardSummaryCard extends StatelessWidget {
  const DashboardSummaryCard({super.key, required this.data});

  final DashboardEntity data;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Color profitColor = data.totalProfit >= 0
        ? AppColors.accent
        : AppColors.danger;

    return Card(
      child: Padding(
        padding: AppSpacing.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Total asset', style: textTheme.bodySmall),
            const SizedBox(height: AppSpacing.xs),
            Text(
              AppFormatters.currency(data.totalAsset),
              style: textTheme.headlineLarge,
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: <Widget>[
                Expanded(
                  child: _SummaryMetric(
                    label: 'Cash',
                    value: AppFormatters.currency(data.cashBalance),
                  ),
                ),
                Expanded(
                  child: _SummaryMetric(
                    label: 'Stocks',
                    value: AppFormatters.currency(data.stockValue),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: profitColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: _SummaryMetric(
                      label: 'Profit',
                      value: AppFormatters.signedCurrency(data.totalProfit),
                      valueColor: profitColor,
                    ),
                  ),
                  Expanded(
                    child: _SummaryMetric(
                      label: 'Return',
                      value: AppFormatters.signedPercent(data.totalReturnRate),
                      valueColor: profitColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: textTheme.bodySmall),
        const SizedBox(height: AppSpacing.xxs),
        Text(value, style: textTheme.titleMedium?.copyWith(color: valueColor)),
      ],
    );
  }
}
