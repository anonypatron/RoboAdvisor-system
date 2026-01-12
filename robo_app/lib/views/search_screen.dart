import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/watchlist_view_model.dart';
import 'stock_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 화면 켜지면 관심 종목 로딩
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WatchlistViewModel>(context, listen: false).fetchWatchlist();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WatchlistViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text("종목 검색 & 관심 💖")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 1. 검색창
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "종목 코드 검색 (예: MMM, AAPL)",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                    vm.search("");
                  },
                ),
              ),
              onChanged: (value) => vm.search(value),
            ),
            const SizedBox(height: 20),

            // 2. 검색 결과 또는 관심 종목 리스트
            Expanded(
              child: _controller.text.isNotEmpty
                  ? _buildSearchResults(vm)
                  : _buildWatchlist(vm),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(WatchlistViewModel vm) {
    if (vm.searchResults.isEmpty) {
      return const Center(child: Text("검색 결과가 없습니다."));
    }
    return ListView.builder(
      itemCount: vm.searchResults.length,
      itemBuilder: (context, index) {
        final ticker = vm.searchResults[index];
        return ListTile(
          title: Text(ticker, style: const TextStyle(fontWeight: FontWeight.bold)),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => StockDetailScreen(ticker: ticker)),
            );
          },
        );
      },
    );
  }

  Widget _buildWatchlist(WatchlistViewModel vm) {
    if (vm.favorites.isEmpty) {
      return const Center(child: Text("관심 종목을 추가해보세요! ⭐️"));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("내 관심 종목", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            itemCount: vm.favorites.length,
            itemBuilder: (context, index) {
              final ticker = vm.favorites[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.favorite, color: Colors.red),
                  title: Text(ticker, style: const TextStyle(fontWeight: FontWeight.bold)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => StockDetailScreen(ticker: ticker)),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
