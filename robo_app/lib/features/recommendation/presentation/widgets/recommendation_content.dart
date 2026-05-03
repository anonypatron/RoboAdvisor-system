import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../domain/entities/recommendation_entity.dart';
import '../../../dashboard/presentation/dashboard_view_model.dart';
import 'recommendation_item.dart';

class RecommendationContent extends StatelessWidget {
  const RecommendationContent({super.key, required this.items});

  final List<RecommendationEntity> items;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: AppSpacing.screen,
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (BuildContext context, int index) {
        final RecommendationEntity item = items[index];
        return RecommendationItem(
          item: item,
          onQuickBuy: () async {
            final bool success = await context
                .read<DashboardViewModel>()
                .buyStock(item.ticker, 2000);
            if (!context.mounted) {
              return;
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  success ? 'Buy order completed.' : 'Buy order failed.',
                ),
              ),
            );
          },
        );
      },
    );
  }
}
