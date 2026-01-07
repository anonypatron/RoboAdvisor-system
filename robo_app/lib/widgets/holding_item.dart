import 'package:flutter/material.dart';
import '../models/dashboard_data.dart';

class HoldingItem extends StatelessWidget {
  final Holding holding;

  const HoldingItem({super.key, required this.holding});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Text(holding.ticker[0])),
        title: Text(holding.ticker, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${holding.qty}주 | 평단 \$${holding.avgPrice.toStringAsFixed(2)}'),
        trailing: Text(
          '${holding.returnPct >= 0 ? "+" : ""}${holding.returnPct.toStringAsFixed(2)}%',
          style: TextStyle(
            color: holding.returnPct >= 0 ? Colors.red : Colors.blue,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
