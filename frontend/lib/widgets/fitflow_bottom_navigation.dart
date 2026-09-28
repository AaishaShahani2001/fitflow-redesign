import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Destinations of the persistent bottom navigation bar.
enum FitFlowDestination {
  home('Home', Icons.home_outlined, Icons.home_rounded),
  plan('Plan', Icons.fitness_center_outlined, Icons.fitness_center_rounded),
  progress('Progress', Icons.bar_chart_outlined, Icons.bar_chart_rounded),
  community('Community', Icons.groups_outlined, Icons.groups_rounded),
  nutrition('Nutrition', Icons.restaurant_outlined, Icons.restaurant_rounded);

  const FitFlowDestination(this.label, this.icon, this.selectedIcon);

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

/// Material 3 navigation bar styled with the FitFlow palette.
class FitFlowBottomNavigation extends StatelessWidget {
  const FitFlowBottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: [
          for (final destination in FitFlowDestination.values)
            NavigationDestination(
              icon: Icon(destination.icon),
              selectedIcon: Icon(destination.selectedIcon),
              label: destination.label,
              tooltip: destination.label,
            ),
        ],
      ),
    );
  }
}
