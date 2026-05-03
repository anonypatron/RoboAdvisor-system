import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/enums/view_status.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../stock_detail_state.dart';
import '../stock_detail_view_model.dart';
import 'stock_detail_content.dart';

class StockDetailBody extends StatelessWidget {
  const StockDetailBody({super.key, required this.ticker});

  final String ticker;

  @override
  Widget build(BuildContext context) {
    return Selector<StockDetailViewModel, StockDetailState>(
      selector: (_, StockDetailViewModel viewModel) => viewModel.state,
      builder: (BuildContext context, StockDetailState state, _) {
        return switch (state.status) {
          ViewStatus.initial || ViewStatus.loading => const LoadingView(
            message: 'Loading stock details...',
          ),
          ViewStatus.error => ErrorView(
            message: state.message ?? 'Unable to load stock details.',
            onRetry: context.read<StockDetailViewModel>().load,
          ),
          _ => StockDetailContent(ticker: ticker, state: state),
        };
      },
    );
  }
}
