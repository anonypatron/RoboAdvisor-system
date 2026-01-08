import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/dashboard_view_model.dart';
import '../widgets/asset_card.dart';
import '../widgets/holding_item.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();

    // 화면이 다 그려지기까지 기다리기(예약 걸어두는 느낌), 안전장치
    // Flutter에서 렌더링 도중 렌더링하면 에러가 남 << setTimeout()과 비슷함.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DashboardViewModel>(context, listen: false).fetchDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Robo Advisor 🤖'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            // 렌더링 없이 함수만 실행(vs watch(렌더링까지 진행))
            onPressed: () => context.read<DashboardViewModel>().fetchDashboard(), 
          )
        ],
      ),
      body: Consumer<DashboardViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null) {
            return Center(child: Text(viewModel.errorMessage!));
          }

          if (viewModel.data == null) {
            return const Center(child: Text("데이터가 없습니다."));
          }

          final data = viewModel.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AssetCard(data: data),
                const SizedBox(height: 20),
                const Text('📈 보유 종목', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                
                ...data.holdings.map((h) => HoldingItem(holding: h)),
                
                if (data.holdings.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: Text('보유 주식이 없습니다 텅텅~ 🗑️')),
                  ),
                
                const SizedBox(height: 30),
                
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      bool success = await context.read<DashboardViewModel>().buyStock("MMM", 2000.0);
                      
                      if (!context.mounted) return;
                      
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('✅ 매수 주문 성공!')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('❌ 매수 실패 (잔고 확인)')),
                        );
                      }
                    },
                    icon: const Icon(Icons.shopping_cart),
                    label: const Text("MMM \$2000 매수 (Test)"),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
