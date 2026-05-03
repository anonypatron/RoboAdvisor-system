import 'package:flutter/material.dart';

import '../../../dashboard/presentation/screens/dashboard_screen.dart';
import '../../../recommendation/presentation/screens/recommendation_screen.dart';
import '../../../search/presentation/screens/search_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../widgets/home_body.dart';
import '../widgets/home_navigation_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = <Widget>[
    DashboardScreen(),
    RecommendationScreen(),
    SearchScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HomeBody(selectedIndex: _selectedIndex, screens: _screens),
      bottomNavigationBar: HomeNavigationBar(
        selectedIndex: _selectedIndex,
        onSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
