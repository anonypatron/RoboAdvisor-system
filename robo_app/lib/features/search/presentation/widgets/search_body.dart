import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/enums/view_status.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../search_state.dart';
import '../search_view_model.dart';
import 'search_content.dart';

class SearchBody extends StatelessWidget {
  const SearchBody({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Selector<SearchViewModel, SearchState>(
      selector: (_, SearchViewModel viewModel) => viewModel.state,
      builder: (BuildContext context, SearchState state, _) {
        if (state.status == ViewStatus.loading &&
            state.favorites.isEmpty &&
            !state.isSearchMode) {
          return const LoadingView(message: 'Loading watchlist...');
        }

        if (state.status == ViewStatus.error &&
            state.favorites.isEmpty &&
            !state.isSearchMode) {
          return ErrorView(
            message: state.message ?? 'Unable to load search data.',
            onRetry: context.read<SearchViewModel>().loadWatchlist,
          );
        }

        return SearchContent(controller: controller, state: state);
      },
    );
  }
}
