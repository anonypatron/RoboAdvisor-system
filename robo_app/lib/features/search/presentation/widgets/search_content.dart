import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../stock_detail/presentation/screens/stock_detail_screen.dart';
import '../search_state.dart';
import '../search_view_model.dart';
import 'search_query_field.dart';
import 'search_result_item.dart';
import 'watchlist_item.dart';

class SearchContent extends StatelessWidget {
  const SearchContent({
    super.key,
    required this.controller,
    required this.state,
  });

  final TextEditingController controller;
  final SearchState state;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.screen,
      child: Column(
        children: <Widget>[
          SearchQueryField(
            controller: controller,
            isLoading: state.isSearching,
            onChanged: (String value) {
              context.read<SearchViewModel>().updateQuery(value);
            },
            onClear: () {
              controller.clear();
              context.read<SearchViewModel>().updateQuery('');
            },
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: state.isSearchMode
                ? _SearchResults(state: state)
                : _WatchlistContent(state: state),
          ),
        ],
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({required this.state});

  final SearchState state;

  @override
  Widget build(BuildContext context) {
    if (state.isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.results.isEmpty) {
      return const EmptyView(
        title: 'No results',
        message: 'Try another ticker or company symbol.',
        icon: Icons.search_off_outlined,
      );
    }

    return ListView.separated(
      itemCount: state.results.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (BuildContext context, int index) {
        final String ticker = state.results[index];
        return SearchResultItem(
          ticker: ticker,
          isFavorite: state.favorites.contains(ticker),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => StockDetailScreen(ticker: ticker),
              ),
            );
          },
          onFavoriteToggle: () =>
              context.read<SearchViewModel>().toggleWatchlist(ticker),
        );
      },
    );
  }
}

class _WatchlistContent extends StatelessWidget {
  const _WatchlistContent({required this.state});

  final SearchState state;

  @override
  Widget build(BuildContext context) {
    if (state.favorites.isEmpty) {
      return const EmptyView(
        title: 'Watchlist is empty',
        message: 'Add a few symbols and track them from here.',
        icon: Icons.favorite_border,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SectionHeader(title: 'Watchlist'),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: ListView.separated(
            itemCount: state.favorites.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (BuildContext context, int index) {
              final String ticker = state.favorites[index];
              return WatchlistItem(
                ticker: ticker,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => StockDetailScreen(ticker: ticker),
                    ),
                  );
                },
                onRemove: () =>
                    context.read<SearchViewModel>().toggleWatchlist(ticker),
              );
            },
          ),
        ),
      ],
    );
  }
}
