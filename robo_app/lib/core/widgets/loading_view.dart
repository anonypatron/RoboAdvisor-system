import 'package:flutter/material.dart';

import '../constants/app_spacing.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.message = 'Loading data...'});

  final String message;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const CircularProgressIndicator(),
          const SizedBox(height: AppSpacing.md),
          Text(message, style: textTheme.bodyMedium),
        ],
      ),
    );
  }
}
