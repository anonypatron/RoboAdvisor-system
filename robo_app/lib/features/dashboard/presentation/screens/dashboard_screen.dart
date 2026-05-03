import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../dashboard_view_model.dart';
import '../widgets/dashboard_body.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardViewModel>().loadIfNeeded();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDarkColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            _DashboardHeader(
              onRefresh: context.read<DashboardViewModel>().loadDashboard,
            ),
            const Expanded(child: DashboardBody()),
          ],
        ),
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({required this.onRefresh});

  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 8, 4),
      child: Row(
        children: <Widget>[
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppDarkColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.auto_graph_rounded,
              color: AppDarkColors.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Robo Advisor',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppDarkColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                'AI-powered portfolio',
                style: TextStyle(
                  fontSize: 11,
                  color: AppDarkColors.textMuted,
                ),
              ),
            ],
          ),
          const Spacer(),
          _RefreshButton(onPressed: onRefresh),
        ],
      ),
    );
  }
}

class _RefreshButton extends StatefulWidget {
  const _RefreshButton({required this.onPressed});

  final Future<void> Function() onPressed;

  @override
  State<_RefreshButton> createState() => _RefreshButtonState();
}

class _RefreshButtonState extends State<_RefreshButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    _controller.repeat();
    await widget.onPressed();
    _controller.stop();
    _controller.reset();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _handleRefresh,
      icon: RotationTransition(
        turns: _controller,
        child: const Icon(
          Icons.refresh_rounded,
          color: AppDarkColors.textMuted,
          size: 22,
        ),
      ),
    );
  }
}
