import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../features/home/presentation/screens/home_screen.dart';
import 'app_providers.dart';

class RoboAdvisorApp extends StatelessWidget {
  const RoboAdvisorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: AppProviders.items,
      child: MaterialApp(
        title: 'Robo Advisor',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const HomeScreen(),
      ),
    );
  }
}
