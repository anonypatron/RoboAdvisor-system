import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../../../domain/entities/dashboard_entity.dart';

class AssetMetricsRow extends StatelessWidget {
  const AssetMetricsRow({super.key, required this.data});

  final DashboardEntity data;

  @override
  Widget build(BuildContext context) {
    final bool returnPositive = data.totalReturnRate >= 0;
    final Color returnColor =
        returnPositive ? AppDarkColors.profit : AppDarkColors.loss;

    return Row(
      children: <Widget>[
        Expanded(
          child: _MetricCard(
            label: 'Cash',
            value: AppFormatters.compactCurrency(data.cashBalance),
            icon: Icons.account_balance_wallet_outlined,
            iconColor: AppDarkColors.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetricCard(
            label: 'Stocks',
            value: AppFormatters.compactCurrency(data.stockValue),
            icon: Icons.show_chart_rounded,
            iconColor: AppDarkColors.accent,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetricCard(
            label: 'Return',
            value: AppFormatters.signedPercent(data.totalReturnRate),
            icon: returnPositive
                ? Icons.trending_up_rounded
                : Icons.trending_down_rounded,
            iconColor: returnColor,
            valueColor: returnColor,
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    this.valueColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppDarkColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppDarkColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppDarkColors.textMuted,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: valueColor ?? AppDarkColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}
