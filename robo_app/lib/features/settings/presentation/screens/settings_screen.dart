import 'package:flutter/material.dart';

import '../../../../core/widgets/app_scaffold.dart';
import '../widgets/settings_body.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(title: 'Settings', body: SettingsBody());
  }
}
