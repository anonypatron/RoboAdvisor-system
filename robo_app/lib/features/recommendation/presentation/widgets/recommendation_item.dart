import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../../../domain/entities/recommendation_entity.dart';
import '../../../stock_detail/presentation/screens/stock_detail_screen.dart';

class RecommendationItem extends StatelessWidget {
  const RecommendationItem({
    super.key,
    required this.item,
    required this.onQuickBuy,
  });

  final RecommendationEntity item;
  final Future<void> Function() onQuickBuy;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => StockDetailScreen(ticker: item.ticker),
            ),
          );
        },
        child: Padding(
          padding: AppSpacing.card,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(item.ticker, style: textTheme.headlineMedium),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(item.date, style: textTheme.bodySmall),
                      ],
                    ),
                  ),
                  Text(
                    AppFormatters.currency(item.close),
                    style: textTheme.titleLarge?.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  item.signalType,
                  textAlign: TextAlign.center,
                  style: textTheme.titleMedium?.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onQuickBuy,
                  icon: const Icon(Icons.shopping_bag_outlined),
                  label: const Text('Quick buy (\$2000)'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
