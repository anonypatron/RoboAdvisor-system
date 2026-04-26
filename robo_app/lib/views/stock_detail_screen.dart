import 'package:candlesticks/candlesticks.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/stock_info.dart';
import '../viewmodels/stock_detail_view_model.dart';
import '../viewmodels/watchlist_view_model.dart';
import '../widgets/trade_bottom_sheet.dart';

class StockDetailScreen extends StatelessWidget {
  const StockDetailScreen({super.key, required this.ticker});

  final String ticker;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StockDetailViewModel(ticker)..fetch(),
      child: _StockDetailView(ticker: ticker),
    );
  }
}

class _StockDetailView extends StatelessWidget {
  const _StockDetailView({required this.ticker});

  final String ticker;

  @override
  Widget build(BuildContext context) {
    final watchlistViewModel = context.watch<WatchlistViewModel>();
    final detailViewModel = context.watch<StockDetailViewModel>();
    final isFavorite = watchlistViewModel.favorites.contains(ticker);

    return Scaffold(
      appBar: AppBar(
        title: Text('$ticker 상세'),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : null,
            ),
            onPressed: () async {
              await watchlistViewModel.toggleFavorite(ticker);
              if (!context.mounted) {
                return;
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isFavorite ? '관심 종목에서 제거했습니다.' : '관심 종목에 추가했습니다.',
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: _buildBody(context, detailViewModel),
    );
  }

  Widget _buildBody(BuildContext context, StockDetailViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.errorMessage != null) {
      return Center(child: Text(viewModel.errorMessage!));
    }

    final stockInfo = viewModel.stockInfo;
    if (stockInfo == null) {
      return const Center(child: Text('종목 정보를 불러오지 못했습니다.'));
    }

    return SafeArea(
      child: Column(
        children: [
          if (viewModel.candles.isNotEmpty)
            SizedBox(
              height: 320,
              child: Candlesticks(candles: viewModel.candles),
            ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSummaryCard(stockInfo),
                const SizedBox(height: 16),
                _buildInfoGrid(stockInfo),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: () => _showTradeModal(
                      context,
                      isBuy: false,
                      candles: viewModel.candles,
                    ),
                    child: const Text('매도'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => _showTradeModal(
                      context,
                      isBuy: true,
                      candles: viewModel.candles,
                    ),
                    child: const Text('매수'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(StockInfo stockInfo) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              stockInfo.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              stockInfo.ticker,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Text(
              '\$${stockInfo.currentPrice.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoGrid(StockInfo stockInfo) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _buildInfoTile('현재가', '\$${stockInfo.currentPrice.toStringAsFixed(2)}'),
        _buildInfoTile('PER', stockInfo.peRatio.toStringAsFixed(2)),
        _buildInfoTile('시가총액', _formatMarketCap(stockInfo.marketCap)),
        _buildInfoTile('섹터', stockInfo.sector),
      ],
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  String _formatMarketCap(double marketCap) {
    if (marketCap >= 1000000000000) {
      return '${(marketCap / 1000000000000).toStringAsFixed(2)}T';
    }
    if (marketCap >= 1000000000) {
      return '${(marketCap / 1000000000).toStringAsFixed(2)}B';
    }
    if (marketCap >= 1000000) {
      return '${(marketCap / 1000000).toStringAsFixed(2)}M';
    }
    return marketCap.toStringAsFixed(0);
  }

  void _showTradeModal(
    BuildContext context, {
    required bool isBuy,
    required List<Candle> candles,
  }) {
    if (candles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('차트 데이터가 아직 없습니다.')),
      );
      return;
    }

    final currentPrice = candles.first.close;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) => TradeBottomSheet(
        ticker: ticker,
        currentPrice: currentPrice,
        isBuy: isBuy,
      ),
    );
  }
}
