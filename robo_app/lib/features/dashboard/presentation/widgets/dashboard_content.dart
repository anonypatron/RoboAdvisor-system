import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../domain/entities/dashboard_entity.dart';
import '../../../../domain/entities/holding_entity.dart';
import 'asset_metrics_row.dart';
import 'holding_card.dart';
import 'portfolio_header_card.dart';

class DashboardContent extends StatelessWidget {
  const DashboardContent({
    super.key,
    required this.data,
    required this.onRefresh,
  });

  final DashboardEntity? data;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final DashboardEntity? portfolio = data;
    if (portfolio == null) return const _EmptyPortfolio();

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppDarkColors.primary,
      backgroundColor: AppDarkColors.surface,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: <Widget>[
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            sliver: SliverList(
              delegate: SliverChildListDelegate(<Widget>[
                PortfolioHeaderCard(data: portfolio),
                const SizedBox(height: 14),
                AssetMetricsRow(data: portfolio),
                const SizedBox(height: 28),
              ]),
            ),
          ),
          _HoldingsHeader(isEmpty: portfolio.holdings.isEmpty),
          if (portfolio.holdings.isNotEmpty)
            _HoldingsList(holdings: portfolio.holdings)
          else
            const _EmptyHoldings(),
          const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
        ],
      ),
    );
  }
}

class _HoldingsHeader extends StatelessWidget {
  const _HoldingsHeader({required this.isEmpty});

  final bool isEmpty;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverToBoxAdapter(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            const Text(
              'Holdings',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppDarkColors.textPrimary,
              ),
            ),
            if (!isEmpty)
              const Text(
                'Market Value',
                style: TextStyle(
                  fontSize: 12,
                  color: AppDarkColors.textMuted,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HoldingsList extends StatelessWidget {
  const _HoldingsList({required this.holdings});

  final List<HoldingEntity> holdings;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: HoldingCard(holding: holdings[index]),
          ),
          childCount: holdings.length,
        ),
      ),
    );
  }
}

class _EmptyHoldings extends StatelessWidget {
  const _EmptyHoldings();

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppDarkColors.surfaceHigh,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                color: AppDarkColors.textMuted,
                size: 28,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'No holdings yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppDarkColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Place your first trade to see\nyour portfolio here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppDarkColors.textMuted,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyPortfolio extends StatelessWidget {
  const _EmptyPortfolio();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Portfolio unavailable',
        style: TextStyle(color: AppDarkColors.textMuted),
      ),
    );
  }
}
