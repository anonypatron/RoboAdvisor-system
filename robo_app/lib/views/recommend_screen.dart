import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:robo_app/views/stock_detail_screen.dart';
import '../viewmodels/recommend_view_model.dart';
import '../viewmodels/dashboard_view_model.dart';

class RecommendScreen extends StatefulWidget {
  const RecommendScreen({super.key});

  @override
  State<RecommendScreen> createState() => _RecommendScreenState();
}

class _RecommendScreenState extends State<RecommendScreen> {
  
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RecommendViewModel>(context, listen: false).fetchRecommendations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('오늘의 AI 추천 🚀'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<RecommendViewModel>().fetchRecommendations(forceRefresh: true),
          )
        ],
      ),
      body: Consumer<RecommendViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text("AI가 시장을 분석 중입니다... 🧠"),
                ],
              ),
            );
          }

          if (viewModel.items.isEmpty) {
            return const Center(child: Text("오늘은 살만한 종목이 없네요 🤷‍♂️"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: viewModel.items.length,
            itemBuilder: (context, index) {
              final item = viewModel.items[index];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StockDetailScreen(ticker: item.ticker),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.ticker, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                                Text(item.date, style: const TextStyle(color: Colors.grey)),
                              ],
                            ),
                            Text('\$${item.close.toStringAsFixed(2)}', 
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text("💡 전략 포착: ${item.signalType}", 
                              style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              // 대시보드 ViewModel을 빌려와서 매수 실행
                              // (Provider의 장점: 다른 ViewModel 함수도 쉽게 호출 가능)
                              bool success = await context.read<DashboardViewModel>().buyStock(item.ticker, 2000.0);
                              
                              if(!context.mounted) return;
                              if(success) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('매수 성공! 자산 탭에서 확인하세요.')));
                              }
                            },
                            icon: const Icon(Icons.shopping_cart_checkout),
                            label: const Text("바로 매수하기 (\$2000)"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
