import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../models/nutrition_data.dart';
import '../../widgets/app_card.dart';
import '../../widgets/fitflow_bottom_navigation.dart';
import '../progress/progress_screen.dart';
import '../workout/ai_workout_planner_screen.dart';
import 'manual_entry_screen.dart';

/// Width (at a text scale of 1.0) needed to keep Quick Add actions in a row.
const double _sideBySideMinWidth = 300;

/// Main Nutrition tab: daily calories, macros, quick add and meals.
class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  int _selectedIndex = FitFlowDestination.nutrition.index;
  NutritionDay _day = NutritionDay.today;
  final Map<NutritionDay, DailyNutrition> _byDay = {
    for (final entry in mockNutritionByDay.entries) entry.key: entry.value,
  };

  DailyNutrition get _nutrition => _byDay[_day]!;

  void _onDestinationSelected(int index) {
    if (index == FitFlowDestination.home.index) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }
    if (index == FitFlowDestination.plan.index) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const AiWorkoutPlannerScreen()),
      );
      return;
    }
    if (index == FitFlowDestination.progress.index) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ProgressScreen()),
      );
      return;
    }
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
  }

  Future<void> _openManualEntry() async {
    final meal = await Navigator.of(context).push<MealEntry>(
      MaterialPageRoute(
        builder: (_) => ManualEntryScreen(
          dayLabel: nutritionDayLabels[_day]!,
        ),
      ),
    );
    if (!mounted || meal == null) return;

    setState(() => _byDay[_day] = _nutrition.adding(meal));
    _showMessage('${meal.name} added');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final heading = _day == NutritionDay.today
        ? "Today's Nutrition"
        : "Yesterday's Nutrition";
    final mealsHeading = _day == NutritionDay.today
        ? "Today's Meals"
        : "Yesterday's Meals";

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: const Text('Nutrition'),
        actions: [
          _DayMenu(
            selected: _day,
            onChanged: (day) => setState(() => _day = day),
          ),
        ],
      ),
      bottomNavigationBar: FitFlowBottomNavigation(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onDestinationSelected,
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.xxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(heading, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.lg),
              _CaloriesCard(nutrition: _nutrition),
              const SizedBox(height: AppSpacing.xl),
              Text('Quick Add', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.md),
              _QuickAddActions(
                onScan: () => _showMessage('Scan Meal coming soon'),
                onManual: _openManualEntry,
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                mealsHeading,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.md),
              for (var i = 0; i < _nutrition.meals.length; i++) ...[
                if (i > 0) const SizedBox(height: AppSpacing.md),
                _MealCard(
                  meal: _nutrition.meals[i],
                  onTap: () => _showMessage(
                    '${_nutrition.meals[i].mealType} details coming soon',
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DayMenu extends StatelessWidget {
  const _DayMenu({required this.selected, required this.onChanged});

  final NutritionDay selected;
  final ValueChanged<NutritionDay> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<NutritionDay>(
      tooltip: 'Select day',
      initialValue: selected,
      onSelected: onChanged,
      itemBuilder: (context) => [
        for (final day in NutritionDay.values)
          PopupMenuItem(
            value: day,
            child: Text(nutritionDayLabels[day]!),
          ),
      ],
      child: Padding(
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              nutritionDayLabels[selected]!,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppColors.primaryDark,
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.primaryDark,
            ),
          ],
        ),
      ),
    );
  }
}

class _CaloriesCard extends StatelessWidget {
  const _CaloriesCard({required this.nutrition});

  final DailyNutrition nutrition;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Calories', style: textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(nutrition.calorieLabel, style: textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
              value: nutrition.calorieProgress.clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: AppColors.border,
              color: AppColors.progressAccent,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: _MacroColumn(
                  macro: nutrition.protein,
                  alignment: CrossAxisAlignment.start,
                ),
              ),
              Expanded(
                child: _MacroColumn(
                  macro: nutrition.carbs,
                  alignment: CrossAxisAlignment.center,
                ),
              ),
              Expanded(
                child: _MacroColumn(
                  macro: nutrition.fat,
                  alignment: CrossAxisAlignment.end,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroColumn extends StatelessWidget {
  const _MacroColumn({
    required this.macro,
    this.alignment = CrossAxisAlignment.start,
  });

  final MacroTarget macro;
  final CrossAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final align = switch (alignment) {
      CrossAxisAlignment.end => TextAlign.end,
      CrossAxisAlignment.center => TextAlign.center,
      _ => TextAlign.start,
    };

    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          macro.label,
          style: textTheme.titleSmall,
          textAlign: align,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          macro.valueLabel,
          style: textTheme.bodySmall,
          textAlign: align,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _QuickAddActions extends StatelessWidget {
  const _QuickAddActions({required this.onScan, required this.onManual});

  final VoidCallback onScan;
  final VoidCallback onManual;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scan = OutlinedButton.icon(
          onPressed: onScan,
          icon: const Icon(Icons.photo_camera_outlined, size: 20),
          label: const Text('Scan Meal'),
        );
        final manual = ElevatedButton.icon(
          onPressed: onManual,
          icon: const Icon(Icons.add_rounded, size: 20),
          label: const Text('Manual Entry'),
        );
        final rowBreakpoint = MediaQuery.textScalerOf(
          context,
        ).scale(_sideBySideMinWidth);

        if (constraints.maxWidth < rowBreakpoint) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              scan,
              const SizedBox(height: AppSpacing.md),
              manual,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: scan),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: manual),
          ],
        );
      },
    );
  }
}

class _MealCard extends StatelessWidget {
  const _MealCard({required this.meal, required this.onTap});

  final MealEntry meal;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      onTap: onTap,
      semanticLabel: '${meal.mealType}, ${meal.name}, ${formatKcal(meal.kcal)}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(meal.mealType, style: textTheme.titleSmall),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: Text(
                  meal.name,
                  style: textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(formatKcal(meal.kcal), style: textTheme.bodyMedium),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.secondaryText,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
