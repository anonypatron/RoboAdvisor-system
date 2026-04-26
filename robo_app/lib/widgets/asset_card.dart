import 'package:flutter/material.dart';

import '../models/dashboard_data.dart';

class AssetCard extends StatelessWidget {
  const AssetCard({super.key, required this.data});

  final DashboardData data;

  @override
  Widget build(BuildContext context) {
    final profitColor = data.totalProfit >= 0 ? Colors.red : Colors.blue;
    final signedRate = data.totalReturnRate >= 0 ? '+' : '';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('총 자산', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Text(
              '\$${data.totalAsset.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('현금 \$${data.cashBalance.toStringAsFixed(2)}'),
                Text('주식 \$${data.stockValue.toStringAsFixed(2)}'),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '손익 \$${data.totalProfit.toStringAsFixed(2)}',
                  style: TextStyle(color: profitColor, fontWeight: FontWeight.w600),
                ),
                Text(
                  '$signedRate${data.totalReturnRate.toStringAsFixed(2)}%',
                  style: TextStyle(color: profitColor, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
