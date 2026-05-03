import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';

class WatchlistItem extends StatelessWidget {
  const WatchlistItem({
    super.key,
    required this.ticker,
    required this.onTap,
    required this.onRemove,
  });

  final String ticker;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Card(
      child: ListTile(
        onTap: onTap,
        leading: const Icon(Icons.favorite, color: AppColors.danger),
        title: Text(ticker, style: textTheme.titleMedium),
        trailing: IconButton(
          onPressed: onRemove,
          icon: const Icon(Icons.delete_outline),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
      ),
    );
  }
}
