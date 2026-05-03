import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/app_scaffold.dart';
import '../recommendation_view_model.dart';
import '../widgets/recommendation_body.dart';

class RecommendationScreen extends StatefulWidget {
  const RecommendationScreen({super.key});

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecommendationViewModel>().loadIfNeeded();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Recommendations',
      actions: <Widget>[
        IconButton(
          onPressed: () => context
              .read<RecommendationViewModel>()
              .loadRecommendations(forceRefresh: true),
          icon: const Icon(Icons.refresh),
        ),
      ],
      body: const RecommendationBody(),
    );
  }
}
