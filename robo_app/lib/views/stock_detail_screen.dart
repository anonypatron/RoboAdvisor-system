import 'package:flutter/material.dart';
import 'package:candlesticks/candlesticks.dart';
import 'package:provider/provider.dart';

import '../services/api_service.dart';
import '../viewmodels/dashboard_view_model.dart'; // 매수용
import '../viewmodels/watchlist_view_model.dart';
import '../utils/logger.dart';
import '../widgets/trade_bottom_sheet.dart';

class StockDetailScreen extends StatefulWidget {
  final String ticker; // 어떤 종목인지 받아야 함

  const StockDetailScreen({super.key, required this.ticker});

  @override
  State<StockDetailScreen> createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends State<StockDetailScreen> {
  List<Candle> candles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final data = await ApiService.fetchStockHistory(widget.ticker);
      setState(() {
        candles = data;
        isLoading = false;
      });
    } catch (e) {
      logger.e(e); // 실제로는 logger 사용 추천
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    
    final watchlistVm = context.watch<WatchlistViewModel>();
    final isFavorite = watchlistVm.favorites.contains(widget.ticker);

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.ticker} 상세 분석'),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : null,
            ),
            onPressed: () {
              watchlistVm.toggleFavorite(widget.ticker);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isFavorite ? "관심 종목에서 삭제됨" : "관심 종목에 추가됨"),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          )
        ],
      ),
      body: SafeArea(
        child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 1. 차트 영역 (높이 고정)
                SizedBox(
                  height: 350,
                  child: Candlesticks(
                    candles: candles,
                    // 워터마크 제거 등의 옵션
                  ),
                ),
                
                // 2. 정보 및 AI 의견 영역
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("AI 투자 의견", style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 10),
                        _buildAiBadge(), // AI 배지
                        const SizedBox(height: 20),
                        const Text("이 종목은 현재 '골든 크로스' 구간에 위치해 있으며,\n거래량이 동반 상승하여 매수 적기로 판단됩니다.",
                           style: TextStyle(color: Colors.grey, height: 1.5)),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      // 매도 버튼 (파란색)
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () => _showTradeModal(context, false), // false = 매도
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text("매도", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15), // 버튼 사이 간격
                      
                      // 매수 버튼 (빨간색)
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () => _showTradeModal(context, true), // true = 매수
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text("매수", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
      )
    );
  }

  Widget _buildAiBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red),
      ),
      child: const Text("🚀 강력 매수 (Strong Buy)", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
    );
  }

  void _buyStock(BuildContext context) async {
      final dashboardVm = context.read<DashboardViewModel>();
      final double currentCash = dashboardVm.data?.cashBalance ?? 0.0;

      double buyAmount = 2000.0;

      if (currentCash < buyAmount) {
        buyAmount = currentCash;
      }

      if (buyAmount < 10.0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('잔고가 부족합니다. (보유: \$${currentCash.toStringAsFixed(2)})')),
        );
        return;
      }

      bool success = await dashboardVm.buyStock(widget.ticker, buyAmount);
      if(!mounted) return;
      if(success) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('매수 체결 완료!')));
          Navigator.pop(context); // 뒤로 가기
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('매수 실패! 잔고 부족 또는 수량 계산 오류.')),
        );
      }
  }
  
  void _showTradeModal(BuildContext context, bool isBuy) {
    // 현재가가 0이면 차트 로딩 덜 된 것
    if (candles.isEmpty) return; 

    final currentPrice = candles.first.close; // 최신 종가

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 키보드 올라올 때 창 크기 조절
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => TradeBottomSheet(
        ticker: widget.ticker,
        currentPrice: currentPrice,
        isBuy: isBuy,
      ),
    );
  }
  
}
