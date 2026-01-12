import 'package:flutter/material.dart';
import 'package:robo_app/views/stock_detail_screen.dart';
import '../models/dashboard_data.dart';

class HoldingItem extends StatelessWidget {
  final Holding holding;

  const HoldingItem({super.key, required this.holding});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StockDetailScreen(ticker: holding.ticker),
            ),
          );
        },
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
