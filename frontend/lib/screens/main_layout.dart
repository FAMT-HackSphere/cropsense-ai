import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme.dart';
import 'home_screen.dart';
import 'soil_input_screen.dart';
import 'history_screen.dart';
import 'more_screen.dart';
import 'crop_result_screen.dart';
import 'package:provider/provider.dart';
import '../providers/crop_plan_provider.dart';

class MainLayout extends StatefulWidget {
  final int initialIndex;
  
  const MainLayout({super.key, this.initialIndex = 0});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final planner = context.watch<CropPlanProvider>();
    
    // The Recommendation tab shows Result if data exists, otherwise Input
    final hasRecommendation = planner.cropResult != null;
    
    final List<Widget> pages = [
      HomeScreen(onNavigateTab: _onTabTapped),
      hasRecommendation 
          ? CropResultScreen(onReset: () => context.read<CropPlanProvider>().reset()) 
          : SoilInputScreen(onSubmitted: () => _onTabTapped(1)), // Stays on 1 but UI updates
      const HistoryScreen(),
      const MoreScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onTabTapped,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard),
            label: l10n.home,
          ),
          NavigationDestination(
            icon: const Icon(Icons.eco_outlined),
            selectedIcon: const Icon(Icons.eco),
            label: l10n.plan,
          ),
          NavigationDestination(
            icon: const Icon(Icons.history_outlined),
            selectedIcon: const Icon(Icons.history),
            label: l10n.history,
          ),
          NavigationDestination(
            icon: const Icon(Icons.more_horiz_outlined),
            selectedIcon: const Icon(Icons.more_horiz),
            label: l10n.more,
          ),
        ],
      ),
    );
  }
}
