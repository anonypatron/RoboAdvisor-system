import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../../../domain/entities/dashboard_entity.dart';
import '../../../../domain/entities/holding_entity.dart';
import '../../../dashboard/presentation/dashboard_state.dart';
import '../../../dashboard/presentation/dashboard_view_model.dart';

class TradeBottomSheet extends StatefulWidget {
  const TradeBottomSheet({
    super.key,
    required this.ticker,
    required this.currentPrice,
    required this.isBuy,
  });

  final String ticker;
  final double currentPrice;
  final bool isBuy;

  @override
  State<TradeBottomSheet> createState() => _TradeBottomSheetState();
}

class _TradeBottomSheetState extends State<TradeBottomSheet> {
  final TextEditingController _quantityController = TextEditingController();
  int _quantity = 0;

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Selector<DashboardViewModel, DashboardState>(
      selector: (_, DashboardViewModel viewModel) => viewModel.state,
      builder: (BuildContext context, DashboardState state, _) {
        // Selector narrows rebuilds to the portfolio slice used by this sheet.
        final double cashBalance = state.data?.cashBalance ?? 0;
        final HoldingEntity? holding = _holdingFor(state.data);
        final int availableQuantity = holding?.qty ?? 0;
        final double estimatedTotal = _quantity * widget.currentPrice;
        final String? errorText = _validate(
          cashBalance: cashBalance,
          holdingQuantity: availableQuantity,
          estimatedTotal: estimatedTotal,
        );
        final bool canSubmit = errorText == null && _quantity > 0;

        return Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.md,
            right: AppSpacing.md,
            top: AppSpacing.md,
            bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      '${widget.isBuy ? 'Buy' : 'Sell'} ${widget.ticker}',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  Text(
                    AppFormatters.currency(widget.currentPrice),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                widget.isBuy
                    ? 'Cash available: ${AppFormatters.currency(cashBalance)}'
                    : 'Shares owned: $availableQuantity',
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _quantityController,
                autofocus: true,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Quantity',
                  suffixText: 'shares',
                  errorText: errorText,
                ),
                onChanged: (String value) {
                  setState(() {
                    _quantity = int.tryParse(value) ?? 0;
                  });
                },
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                width: double.infinity,
                padding: AppSpacing.card,
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: <Widget>[
                    const Expanded(child: Text('Estimated total')),
                    Text(
                      AppFormatters.currency(estimatedTotal),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: widget.isBuy
                            ? AppColors.primary
                            : AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: canSubmit
                      ? () => _submit(context, estimatedTotal)
                      : null,
                  child: Text(
                    widget.isBuy ? 'Submit buy order' : 'Submit sell order',
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  HoldingEntity? _holdingFor(DashboardEntity? data) {
    if (data == null) {
      return null;
    }
    for (final HoldingEntity holding in data.holdings) {
      if (holding.ticker == widget.ticker) {
        return holding;
      }
    }
    return null;
  }

  String? _validate({
    required double cashBalance,
    required int holdingQuantity,
    required double estimatedTotal,
  }) {
    if (_quantity <= 0) {
      return null;
    }
    if (widget.isBuy && estimatedTotal > cashBalance) {
      return 'Insufficient cash balance.';
    }
    if (!widget.isBuy && _quantity > holdingQuantity) {
      return 'Insufficient share quantity.';
    }
    return null;
  }

  Future<void> _submit(BuildContext context, double estimatedTotal) async {
    final DashboardViewModel viewModel = context.read<DashboardViewModel>();
    final bool success = widget.isBuy
        ? await viewModel.buyStock(widget.ticker, estimatedTotal)
        : await viewModel.sellStock(widget.ticker, _quantity);

    if (!context.mounted) {
      return;
    }

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? 'Order completed.' : 'Order failed.')),
    );
  }
}
