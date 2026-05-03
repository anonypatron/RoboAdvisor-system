import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/enums/view_status.dart';
import '../dashboard_state.dart';
import '../dashboard_view_model.dart';
import 'dashboard_content.dart';

class DashboardBody extends StatelessWidget {
  const DashboardBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<DashboardViewModel, DashboardState>(
      selector: (_, DashboardViewModel vm) => vm.state,
      builder: (BuildContext context, DashboardState state, _) {
        return switch (state.status) {
          ViewStatus.initial ||
          ViewStatus.loading when state.data == null =>
            const _DarkLoadingView(),
          ViewStatus.error when state.data == null => _DarkErrorView(
            message: state.message ?? 'Unable to load portfolio.',
            onRetry: context.read<DashboardViewModel>().loadDashboard,
          ),
          _ => DashboardContent(
            data: state.data,
            onRefresh: context.read<DashboardViewModel>().loadDashboard,
          ),
        };
      },
    );
  }
}

class _DarkLoadingView extends StatelessWidget {
  const _DarkLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppDarkColors.primary,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Loading portfolio...',
            style: TextStyle(
              fontSize: 13,
              color: AppDarkColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _DarkErrorView extends StatelessWidget {
  const _DarkErrorView({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppDarkColors.loss.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                color: AppDarkColors.loss,
                size: 26,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Connection error',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppDarkColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppDarkColors.textMuted,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                backgroundColor: AppDarkColors.primary.withValues(alpha: 0.12),
                foregroundColor: AppDarkColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
