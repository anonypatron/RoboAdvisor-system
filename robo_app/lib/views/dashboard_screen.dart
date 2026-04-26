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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardViewModel>().fetchDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('포트폴리오'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<DashboardViewModel>().fetchDashboard(),
          ),
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

          final data = viewModel.data;
          if (data == null) {
            return const Center(child: Text('대시보드 데이터를 불러오지 못했습니다.'));
          }

          return RefreshIndicator(
            onRefresh: viewModel.fetchDashboard,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                AssetCard(data: data),
                const SizedBox(height: 20),
                const Text(
                  '보유 종목',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                if (data.holdings.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(child: Text('보유 종목이 없습니다.')),
                    ),
                  )
                else
                  ...data.holdings.map((holding) => HoldingItem(holding: holding)),
              ],
            ),
          );
        },
      ),
    );
  }
}
