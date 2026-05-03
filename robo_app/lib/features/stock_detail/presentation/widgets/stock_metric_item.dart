import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';

class StockMetricItem extends StatelessWidget {
  const StockMetricItem({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: AppSpacing.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(label, style: textTheme.bodySmall),
            const SizedBox(height: AppSpacing.xs),
            Text(value, style: textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}
