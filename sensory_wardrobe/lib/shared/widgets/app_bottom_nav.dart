import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';

/// Persistent bottom navigation bar shown on main app screens.
/// Five destinations map to the five primary DFD user-facing processes.
class AppBottomNav extends StatelessWidget {
  final int currentIndex;

  const AppBottomNav({super.key, required this.currentIndex});

  static const _destinations = [
    (icon: Icons.home_outlined,      activeIcon: Icons.home,              label: 'Home',       route: AppRoutes.dashboard),
    (icon: Icons.checkroom_outlined, activeIcon: Icons.checkroom,         label: 'Log',        route: AppRoutes.logOutfit),
    (icon: Icons.auto_awesome_outlined, activeIcon: Icons.auto_awesome,   label: 'Suggest',    route: AppRoutes.suggestions),
    (icon: Icons.library_books_outlined, activeIcon: Icons.library_books, label: 'Wardrobe',   route: AppRoutes.wardrobe),
    (icon: Icons.bar_chart_outlined, activeIcon: Icons.bar_chart,         label: 'History',    route: AppRoutes.history),
  ];

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      backgroundColor: Colors.white,
      indicatorColor: AppColors.teal.withValues(alpha: 0.15),
      onDestinationSelected: (index) {
        if (index != currentIndex) {
          context.go(_destinations[index].route);
        }
      },
      destinations: _destinations.map((d) {
        return NavigationDestination(
          icon: Icon(d.icon),
          selectedIcon: Icon(d.activeIcon, color: AppColors.teal),
          label: d.label,
        );
      }).toList(),
    );
  }
}
