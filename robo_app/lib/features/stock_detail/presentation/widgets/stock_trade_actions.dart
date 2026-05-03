import 'package:candlesticks/candlesticks.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import 'trade_bottom_sheet.dart';

class StockTradeActions extends StatelessWidget {
  const StockTradeActions({
    super.key,
    required this.ticker,
    required this.candles,
  });

  final String ticker;
  final List<Candle> candles;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.md,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: FilledButton.tonal(
              onPressed: () => _openTradeSheet(context, isBuy: false),
              child: const Text('Sell'),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: FilledButton(
              onPressed: () => _openTradeSheet(context, isBuy: true),
              child: const Text('Buy'),
            ),
          ),
        ],
      ),
    );
  }

  void _openTradeSheet(BuildContext context, {required bool isBuy}) {
    if (candles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No price data available for trading.')),
      );
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext sheetContext) {
        return TradeBottomSheet(
          ticker: ticker,
          currentPrice: candles.first.close,
          isBuy: isBuy,
        );
      },
    );
  }
}
