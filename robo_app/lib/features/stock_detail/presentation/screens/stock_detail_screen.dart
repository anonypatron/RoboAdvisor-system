import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../domain/usecases/load_stock_detail_usecase.dart';
import '../../../dashboard/presentation/dashboard_view_model.dart';
import '../../../search/presentation/search_view_model.dart';
import '../stock_detail_view_model.dart';
import '../widgets/stock_detail_body.dart';

class StockDetailScreen extends StatefulWidget {
  const StockDetailScreen({super.key, required this.ticker});

  final String ticker;

  @override
  State<StockDetailScreen> createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends State<StockDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SearchViewModel>().loadIfNeeded();
      context.read<DashboardViewModel>().loadIfNeeded();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<StockDetailViewModel>(
      create: (BuildContext context) => StockDetailViewModel(
        ticker: widget.ticker,
        loadStockDetail: context.read<LoadStockDetailUseCase>(),
      )..load(),
      child: AppScaffold(
        title: widget.ticker,
        actions: <Widget>[
          Selector<SearchViewModel, bool>(
            selector: (_, SearchViewModel viewModel) =>
                viewModel.state.favorites.contains(widget.ticker),
            builder: (BuildContext context, bool isFavorite, _) {
              return IconButton(
                onPressed: () async {
                  await context.read<SearchViewModel>().toggleWatchlist(
                    widget.ticker,
                  );
                  if (!context.mounted) {
                    return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isFavorite
                            ? 'Removed from watchlist.'
                            : 'Added to watchlist.',
                      ),
                    ),
                  );
                },
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? AppColors.danger : null,
                ),
              );
            },
          ),
        ],
        body: StockDetailBody(ticker: widget.ticker),
      ),
    );
  }
}
