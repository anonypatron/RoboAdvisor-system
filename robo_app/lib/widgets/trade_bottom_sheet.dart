import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/dashboard_data.dart';
import '../viewmodels/dashboard_view_model.dart';

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
  final TextEditingController _qtyController = TextEditingController();
  int _quantity = 0;

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dashboardViewModel = context.watch<DashboardViewModel>();
    final cashBalance = dashboardViewModel.data?.cashBalance ?? 0.0;
    final Holding? holding = dashboardViewModel.data?.holdings.cast<Holding?>().firstWhere(
          (item) => item?.ticker == widget.ticker,
          orElse: () => null,
        );
    final holdingQty = holding?.qty ?? 0;
    final estimatedTotal = _quantity * widget.currentPrice;

    bool isValid = false;
    String? errorText;

    if (_quantity > 0) {
      if (widget.isBuy) {
        if (estimatedTotal > cashBalance) {
          errorText = '현금 잔고가 부족합니다.';
        } else {
          isValid = true;
        }
      } else if (_quantity > holdingQty) {
        errorText = '보유 수량이 부족합니다.';
      } else {
        isValid = true;
      }
    }

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${widget.isBuy ? '매수' : '매도'} (${widget.ticker})',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                '\$${widget.currentPrice.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.isBuy
                ? '현금 잔고: \$${cashBalance.toStringAsFixed(2)}'
                : '보유 수량: $holdingQty주',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _qtyController,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: InputDecoration(
              labelText: '수량',
              border: const OutlineInputBorder(),
              suffixText: '주',
              errorText: errorText,
            ),
            onChanged: (value) {
              setState(() {
                _quantity = int.tryParse(value) ?? 0;
              });
            },
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('예상 체결 금액'),
              Text(
                '\$${estimatedTotal.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: widget.isBuy ? Colors.red : Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: isValid
                  ? () async {
                      final success = widget.isBuy
                          ? await dashboardViewModel.buyStock(widget.ticker, estimatedTotal)
                          : await dashboardViewModel.sellStock(widget.ticker, _quantity);

                      if (!context.mounted) {
                        return;
                      }

                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            success ? '주문이 체결되었습니다.' : '주문 처리에 실패했습니다.',
                          ),
                        ),
                      );
                    }
                  : null,
              child: Text(widget.isBuy ? '매수 주문' : '매도 주문'),
            ),
          ),
        ],
      ),
    );
  }
}
