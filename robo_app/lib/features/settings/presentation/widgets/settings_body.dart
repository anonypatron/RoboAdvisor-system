import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/enums/view_status.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../settings_state.dart';
import '../settings_view_model.dart';
import 'settings_content.dart';

class SettingsBody extends StatelessWidget {
  const SettingsBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<SettingsViewModel, SettingsState>(
      selector: (_, SettingsViewModel viewModel) => viewModel.state,
      builder: (BuildContext context, SettingsState state, _) {
        return switch (state.status) {
          ViewStatus.initial || ViewStatus.loading => const LoadingView(
            message: 'Loading settings...',
          ),
          ViewStatus.error => ErrorView(
            message: state.message ?? 'Unable to load settings.',
            onRetry: context.read<SettingsViewModel>().load,
          ),
          _ => SettingsContent(apiUrl: state.apiUrl),
        };
      },
    );
  }
}
