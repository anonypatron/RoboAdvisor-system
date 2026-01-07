import 'package:flutter/material.dart';
import '../models/dashboard_data.dart';

class AssetCard extends StatelessWidget {
  final DashboardData data;

  const AssetCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text('총 자산', style: TextStyle(fontSize: 16, color: Colors.grey)),
            Text('\$${data.totalAsset.toStringAsFixed(2)}', 
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('💵 현금: \$${data.cashBalance.toStringAsFixed(2)}'),
                Text('📊 주식: \$${data.stockValue.toStringAsFixed(2)}'),
              ],
            )
          ],
        ),
      ),
    );
  }
}
