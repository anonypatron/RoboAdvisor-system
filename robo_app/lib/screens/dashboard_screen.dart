import 'package:flutter/material.dart';
import '../models/dashboard_data.dart';
import '../services/api_service.dart';
import '../widgets/asset_card.dart';
import '../widgets/holding_item.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<DashboardData> futureData;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      futureData = ApiService.fetchDashboard();
    });
  }

  void _handleBuy(String ticker) async {
    try {
      bool success = await ApiService.buyStock(ticker, 2000.0);
      if (success) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ 매수 주문 성공!')),
        );
        _refreshData();
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ 매수 실패 (잔고 확인)')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('에러: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Robo Advisor 🤖'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshData)
        ],
      ),
      body: FutureBuilder<DashboardData>(
        future: futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('서버 연결 실패\nError: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('데이터 없음'));
          }

          final data = snapshot.data!;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 분리한 위젯 사용
                AssetCard(data: data),
                
                const SizedBox(height: 20),
                const Text('📈 보유 종목', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                
                // 리스트 렌더링
                ...data.holdings.map((h) => HoldingItem(holding: h)),
                
                if (data.holdings.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: Text('보유 주식이 없습니다 텅텅~ 🗑️')),
                  ),
                
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () => _handleBuy("MMM"),
                    icon: const Icon(Icons.shopping_cart),
                    label: const Text('MMM \$2000 매수 (Test)'),
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
