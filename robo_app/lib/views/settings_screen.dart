import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    String apiUrl = dotenv.env['API_URL'] ?? "";

    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.cloud_outlined),
              title: const Text('API 서버'),
              subtitle: Text(apiUrl),
            ),
          ),
          const Card(
            child: ListTile(
              leading: Icon(Icons.schedule_outlined),
              title: Text('추천 스케줄'),
              subtitle: Text('백엔드에서 매일 오전 8시에 추천 갱신'),
            ),
          ),
        ],
      ),
    );
  }
}
