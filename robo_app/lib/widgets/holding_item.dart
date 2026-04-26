import 'package:flutter/material.dart';

import '../models/dashboard_data.dart';
import '../views/stock_detail_screen.dart';

class HoldingItem extends StatelessWidget {
  const HoldingItem({super.key, required this.holding});

  final Holding holding;

  @override
  Widget build(BuildContext context) {
    final profitColor = holding.returnPct >= 0 ? Colors.red : Colors.blue;
    final signedRate = holding.returnPct >= 0 ? '+' : '';

    return Card(
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StockDetailScreen(ticker: holding.ticker),
            ),
          );
        },
        leading: CircleAvatar(child: Text(holding.ticker[0])),
        title: Text(
          holding.ticker,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '보유 ${holding.qty}주  |  평균 \$${holding.avgPrice.toStringAsFixed(2)}\n'
          '현재 \$${holding.currentPrice.toStringAsFixed(2)}  |  평가 \$${holding.marketValue.toStringAsFixed(2)}',
        ),
        isThreeLine: true,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${holding.profitAmount.toStringAsFixed(2)}',
              style: TextStyle(color: profitColor, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '$signedRate${holding.returnPct.toStringAsFixed(2)}%',
              style: TextStyle(color: profitColor, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
