import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import 'settings_info_item.dart';

class SettingsContent extends StatelessWidget {
  const SettingsContent({super.key, required this.apiUrl});

  final String apiUrl;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: AppSpacing.screen,
      children: <Widget>[
        SettingsInfoItem(
          icon: Icons.cloud_outlined,
          title: 'API endpoint',
          subtitle: apiUrl,
        ),
        const SizedBox(height: AppSpacing.sm),
        const SettingsInfoItem(
          icon: Icons.schedule_outlined,
          title: 'Daily refresh',
          subtitle: 'Recommendations refresh every day at 08:00.',
        ),
      ],
    );
  }
}
