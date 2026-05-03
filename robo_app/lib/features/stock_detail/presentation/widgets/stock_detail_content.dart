import 'package:candlesticks/candlesticks.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../../../domain/entities/stock_info_entity.dart';
import '../stock_detail_state.dart';
import 'stock_chart_card.dart';
import 'stock_metrics_grid.dart';
import 'stock_summary_card.dart';
import 'stock_trade_actions.dart';

class StockDetailContent extends StatelessWidget {
  const StockDetailContent({
    super.key,
    required this.ticker,
    required this.state,
  });

  final String ticker;
  final StockDetailState state;

  @override
  Widget build(BuildContext context) {
    final StockInfoEntity? stockInfo = state.stockInfo;
    if (stockInfo == null) {
      return const EmptyView(
        title: 'No stock data',
        message: 'Please try again in a moment.',
        icon: Icons.query_stats_outlined,
      );
    }

    return SafeArea(
      child: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              padding: AppSpacing.screen,
              children: <Widget>[
                StockChartCard(candles: state.candles),
                const SizedBox(height: AppSpacing.md),
                StockSummaryCard(stockInfo: stockInfo),
                const SizedBox(height: AppSpacing.md),
                StockMetricsGrid(stockInfo: stockInfo),
              ],
            ),
          ),
          StockTradeActions(ticker: ticker, candles: state.candles),
        ],
      ),
    );
  }
}
