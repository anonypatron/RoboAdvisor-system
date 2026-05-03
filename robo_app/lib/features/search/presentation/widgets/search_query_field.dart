import 'package:flutter/material.dart';

class SearchQueryField extends StatelessWidget {
  const SearchQueryField({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
    required this.isLoading,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Search ticker (AAPL, MSFT, NVDA)',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: isLoading
            ? const Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : IconButton(onPressed: onClear, icon: const Icon(Icons.close)),
      ),
    );
  }
}
