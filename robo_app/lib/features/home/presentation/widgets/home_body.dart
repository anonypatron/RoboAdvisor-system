import 'package:flutter/material.dart';

class HomeBody extends StatelessWidget {
  const HomeBody({
    super.key,
    required this.selectedIndex,
    required this.screens,
  });

  final int selectedIndex;
  final List<Widget> screens;

  @override
  Widget build(BuildContext context) {
    return IndexedStack(index: selectedIndex, children: screens);
  }
}
