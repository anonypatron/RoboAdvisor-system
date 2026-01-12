import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/dashboard_view_model.dart';

class TradeBottomSheet extends StatefulWidget {
  final String ticker;
  final double currentPrice;
  final bool isBuy;

  const TradeBottomSheet({
    super.key,
    required this.ticker,
    required this.currentPrice,
    required this.isBuy,
  });

  @override
  State<TradeBottomSheet> createState() => _TradeBottomSheetState();
}

class _TradeBottomSheetState extends State<TradeBottomSheet> {
  final TextEditingController _qtyController = TextEditingController();
  int _quantity = 0;

  @override
  Widget build(BuildContext context) {
    final dashboardVm = context.watch<DashboardViewModel>();

    final cashBalance = dashboardVm.data?.cashBalance ?? .0;
    final myHolding = dashboardVm.data?.holdings.firstWhere(
      (h) => h.ticker == widget.ticker,
      orElse: () => null as dynamic,
    );

    final int holdingQty = (dashboardVm.data?.holdings.any((h) => h.ticker == widget.ticker) ?? false)
        ? dashboardVm.data!.holdings.firstWhere((h) => h.ticker == widget.ticker).qty
        : 0;

    final double estimatedTotal = _quantity * widget.currentPrice;

    bool isValid = false;
    String? errorText;

    if (_quantity > 0) {
      if (widget.isBuy) {
        if (estimatedTotal > cashBalance) {
          errorText = "현금이 부족합니다.";
        }
        else {
          isValid = true;
        }
      }
      else {
        if (_quantity > holdingQty) {
          errorText = "보유 수량이 부족합니다.";
        }
        else {
          isValid = true;
        }
      }
    }

    return Padding(
      // 키보드 올라왔을 때 가려짐 방지
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // 내용물만큼만 높이 차지
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 헤더 (종목명, 현재가)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${widget.isBuy ? '매수' : '매도'}하기 (${widget.ticker})",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                "\$${widget.currentPrice.toStringAsFixed(2)}",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          
          // 2. 내 상황 (보유 현금 or 보유 수량)
          Text(
            widget.isBuy 
              ? "보유 현금: \$${cashBalance.toStringAsFixed(2)}"
              : "보유 수량: ${holdingQty}주",
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),

          // 3. 수량 입력 필드
          TextField(
            controller: _qtyController,
            keyboardType: TextInputType.number,
            autofocus: true, // 창 뜨자마자 키보드 올리기
            decoration: InputDecoration(
              labelText: "수량 (주)",
              border: const OutlineInputBorder(),
              errorText: errorText,
              suffixText: "주",
            ),
            onChanged: (val) {
              setState(() {
                _quantity = int.tryParse(val) ?? 0;
              });
            },
          ),
          const SizedBox(height: 20),

          // 4. 예상 금액 표시
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("예상 체결 금액", style: TextStyle(fontSize: 16)),
              Text(
                "\$${estimatedTotal.toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: 20, 
                  fontWeight: FontWeight.bold,
                  color: widget.isBuy ? Colors.red : Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 5. 주문 버튼
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: isValid
                  ? () async {
                      bool success = false;
                      if (widget.isBuy) {
                        // 매수: 금액($)으로 환산해서 요청 (기존 API 활용)
                        success = await dashboardVm.buyStock(widget.ticker, estimatedTotal);
                      } else {
                        // 매도: 수량(주)으로 요청 (신규 API 활용)
                        // ViewModel에 sellStock 함수를 추가해야 함 (아래 단계 참조)
                        success = await dashboardVm.sellStock(widget.ticker, _quantity);
                      }

                      if (!context.mounted) return;
                      
                      if (success) {
                        Navigator.pop(context); // 모달 닫기
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('주문이 체결되었습니다!')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('주문 실패! 다시 확인해주세요.')),
                        );
                      }
                    }
                  : null, // 유효하지 않으면 버튼 비활성화
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.isBuy ? Colors.red : Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: Text(widget.isBuy ? "매수 주문" : "매도 주문"),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
