import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../../../core/widgets/sparkline_chart.dart';
import '../../../../domain/entities/dashboard_entity.dart';

// Placeholder daily values — replace with real time-series data from API
const List<double> _kDummySparkline = <double>[
  100, 97, 103, 101, 108, 106, 112, 109, 116, 114,
  120, 118, 125, 122, 129, 127, 133, 131, 138, 140,
];

class PortfolioHeaderCard extends StatelessWidget {
  const PortfolioHeaderCard({super.key, required this.data});

  final DashboardEntity data;

  @override
  Widget build(BuildContext context) {
    final bool isPositive = data.totalReturnRate >= 0;
    final Color returnColor =
        isPositive ? AppDarkColors.profit : AppDarkColors.loss;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF1C2B4A), Color(0xFF0F1729)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppDarkColors.border),
      ),
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _HeaderRow(isPositive: isPositive),
          const SizedBox(height: 18),
          _PortfolioValue(totalAsset: data.totalAsset),
          const SizedBox(height: 10),
          _ReturnRow(
            profit: data.totalProfit,
            returnRate: data.totalReturnRate,
            color: returnColor,
            isPositive: isPositive,
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 52,
            child: SparklineChart(data: _kDummySparkline, color: returnColor),
          ),
        ],
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({required this.isPositive});

  final bool isPositive;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        const Text(
          'TOTAL PORTFOLIO',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppDarkColors.textMuted,
            letterSpacing: 1.2,
          ),
        ),
        _LiveBadge(isPositive: isPositive),
      ],
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge({required this.isPositive});

  final bool isPositive;

  @override
  Widget build(BuildContext context) {
    final Color color = isPositive ? AppDarkColors.profit : AppDarkColors.loss;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            'Live',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _PortfolioValue extends StatelessWidget {
  const _PortfolioValue({required this.totalAsset});

  final double totalAsset;

  @override
  Widget build(BuildContext context) {
    return Text(
      AppFormatters.currency(totalAsset),
      style: const TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: AppDarkColors.textPrimary,
        letterSpacing: -1.2,
        height: 1.1,
      ),
    );
  }
}

class _ReturnRow extends StatelessWidget {
  const _ReturnRow({
    required this.profit,
    required this.returnRate,
    required this.color,
    required this.isPositive,
  });

  final double profit;
  final double returnRate;
  final Color color;
  final bool isPositive;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        _ProfitPill(profit: profit, color: color, isPositive: isPositive),
        const SizedBox(width: 10),
        Text(
          AppFormatters.signedPercent(returnRate),
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(width: 6),
        const Text(
          '· All-time',
          style: TextStyle(
            fontSize: 13,
            color: AppDarkColors.textMuted,
          ),
        ),
      ],
    );
  }
}

class _ProfitPill extends StatelessWidget {
  const _ProfitPill({
    required this.profit,
    required this.color,
    required this.isPositive,
  });

  final double profit;
  final Color color;
  final bool isPositive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            isPositive
                ? Icons.arrow_upward_rounded
                : Icons.arrow_downward_rounded,
            size: 13,
            color: color,
          ),
          const SizedBox(width: 3),
          Text(
            AppFormatters.signedCurrency(profit),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
