import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/enums/view_status.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../recommendation_state.dart';
import '../recommendation_view_model.dart';
import 'recommendation_content.dart';

class RecommendationBody extends StatelessWidget {
  const RecommendationBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<RecommendationViewModel, RecommendationState>(
      selector: (_, RecommendationViewModel viewModel) => viewModel.state,
      builder: (BuildContext context, RecommendationState state, _) {
        return switch (state.status) {
          ViewStatus.initial || ViewStatus.loading => const LoadingView(
            message: 'Analyzing market ideas...',
          ),
          ViewStatus.error => ErrorView(
            message: state.message ?? 'Unable to load recommendations.',
            onRetry: () => context
                .read<RecommendationViewModel>()
                .loadRecommendations(forceRefresh: true),
          ),
          ViewStatus.empty => const EmptyView(
            title: 'No recommendations today',
            message: 'Try again after the next scheduled refresh.',
            icon: Icons.lightbulb_outline,
          ),
          _ => RecommendationContent(items: state.items),
        };
      },
    );
  }
}
