import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../../../domain/entities/holding_entity.dart';
import '../../../stock_detail/presentation/screens/stock_detail_screen.dart';

class HoldingCard extends StatelessWidget {
  const HoldingCard({super.key, required this.holding});

  final HoldingEntity holding;

  @override
  Widget build(BuildContext context) {
    final bool isPositive = holding.returnPct >= 0;
    final Color accentColor =
        isPositive ? AppDarkColors.profit : AppDarkColors.loss;

    return GestureDetector(
      onTap: () => _navigateToDetail(context),
      child: Container(
        decoration: BoxDecoration(
          color: AppDarkColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border(
            left: BorderSide(color: accentColor, width: 3),
            top: BorderSide(color: AppDarkColors.border),
            right: BorderSide(color: AppDarkColors.border),
            bottom: BorderSide(color: AppDarkColors.border),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: <Widget>[
            _TickerBadge(ticker: holding.ticker),
            const SizedBox(width: 14),
            Expanded(child: _HoldingInfo(holding: holding)),
            _HoldingValue(
              holding: holding,
              accentColor: accentColor,
              isPositive: isPositive,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => StockDetailScreen(ticker: holding.ticker),
      ),
    );
  }
}

class _TickerBadge extends StatelessWidget {
  const _TickerBadge({required this.ticker});

  final String ticker;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppDarkColors.surfaceHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text(
        ticker.length > 2 ? ticker.substring(0, 2) : ticker,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: AppDarkColors.primary,
          letterSpacing: -0.4,
        ),
      ),
    );
  }
}

class _HoldingInfo extends StatelessWidget {
  const _HoldingInfo({required this.holding});

  final HoldingEntity holding;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          holding.ticker,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppDarkColors.textPrimary,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          '${holding.qty} shares  ·  avg ${AppFormatters.currency(holding.avgPrice)}',
          style: const TextStyle(
            fontSize: 12,
            color: AppDarkColors.textMuted,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          AppFormatters.currency(holding.currentPrice),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppDarkColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _HoldingValue extends StatelessWidget {
  const _HoldingValue({
    required this.holding,
    required this.accentColor,
    required this.isPositive,
  });

  final HoldingEntity holding;
  final Color accentColor;
  final bool isPositive;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Text(
          AppFormatters.compactCurrency(holding.marketValue),
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppDarkColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                isPositive
                    ? Icons.arrow_upward_rounded
                    : Icons.arrow_downward_rounded,
                size: 11,
                color: accentColor,
              ),
              const SizedBox(width: 2),
              Text(
                '${holding.returnPct.abs().toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: accentColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 3),
        Text(
          AppFormatters.signedCurrency(holding.profitAmount),
          style: TextStyle(
            fontSize: 12,
            color: accentColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
