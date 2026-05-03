import 'package:candlesticks/candlesticks.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/empty_view.dart';

class StockChartCard extends StatelessWidget {
  const StockChartCard({super.key, required this.candles});

  final List<Candle> candles;

  @override
  Widget build(BuildContext context) {
    if (candles.isEmpty) {
      return const Card(
        child: SizedBox(
          height: 220,
          child: EmptyView(
            title: 'No chart data',
            message: 'Historical price data is not available.',
            icon: Icons.show_chart_outlined,
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: SizedBox(height: 280, child: Candlesticks(candles: candles)),
      ),
    );
  }
}
