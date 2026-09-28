import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../models/progress_data.dart';
import '../../widgets/app_card.dart';
import '../../widgets/fitflow_bottom_navigation.dart';
import '../../widgets/workout_line_chart.dart';
import '../workout/ai_workout_planner_screen.dart';
import 'monthly_summary_screen.dart';
import 'weekly_summary_screen.dart';
import 'yearly_summary_screen.dart';

/// Main Progress tab: period selector, workouts chart, stats and badges.
class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  int _selectedIndex = FitFlowDestination.progress.index;
  ProgressPeriod _period = ProgressPeriod.week;

  ProgressSnapshot get _snapshot => ProgressSnapshot.byPeriod[_period]!;

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
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
  }

  void _openPeriodSummary() {
    final Widget screen = switch (_period) {
      ProgressPeriod.week => const WeeklySummaryScreen(),
      ProgressPeriod.month => const MonthlySummaryScreen(),
      ProgressPeriod.year => const YearlySummaryScreen(),
    };
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Progress'),
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
              _PeriodSelector(
                selected: _period,
                onChanged: (period) => setState(() => _period = period),
              ),
              const SizedBox(height: AppSpacing.lg),
              _WorkoutsChartCard(
                snapshot: _snapshot,
                summaryLabel: switch (_period) {
                  ProgressPeriod.week => 'View Weekly Summary',
                  ProgressPeriod.month => 'View Monthly Summary',
                  ProgressPeriod.year => 'View Yearly Summary',
                },
                onViewSummary: _openPeriodSummary,
              ),
              const SizedBox(height: AppSpacing.lg),
              _StatsRow(snapshot: _snapshot),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Achievements',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.md),
              const _AchievementsRow(items: mockAchievements),
            ],
          ),
        ),
      ),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({required this.selected, required this.onChanged});

  final ProgressPeriod selected;
  final ValueChanged<ProgressPeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<ProgressPeriod>(
      showSelectedIcon: false,
      expandedInsets: EdgeInsets.zero,
      style: SegmentedButton.styleFrom(
        backgroundColor: AppColors.card,
        foregroundColor: AppColors.secondaryText,
        selectedForegroundColor: Colors.white,
        selectedBackgroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.border),
        textStyle: Theme.of(context).textTheme.titleSmall,
      ),
      segments: const [
        ButtonSegment(value: ProgressPeriod.week, label: Text('Week')),
        ButtonSegment(value: ProgressPeriod.month, label: Text('Month')),
        ButtonSegment(value: ProgressPeriod.year, label: Text('Year')),
      ],
      selected: {selected},
      onSelectionChanged: (value) {
        if (value.isNotEmpty) onChanged(value.first);
      },
    );
  }
}

class _WorkoutsChartCard extends StatelessWidget {
  const _WorkoutsChartCard({
    required this.snapshot,
    required this.summaryLabel,
    required this.onViewSummary,
  });

  final ProgressSnapshot snapshot;
  final String summaryLabel;
  final VoidCallback onViewSummary;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text('Workouts', style: textTheme.titleLarge)),
              Flexible(
                child: TextButton(
                  onPressed: onViewSummary,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.secondaryText,
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.only(left: AppSpacing.sm),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          summaryLabel,
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, size: 18),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          WorkoutLineChart(points: snapshot.chart),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.snapshot});

  final ProgressSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.fitness_center_rounded,
              value: '${snapshot.workoutCount}',
              label: 'Workouts',
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _StatCard(
              icon: Icons.schedule_rounded,
              value: snapshot.totalTimeLabel,
              label: 'Total Time',
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _StatCard(
              icon: Icons.local_fire_department_rounded,
              value: '${snapshot.streakDays}',
              label: 'Day Streak',
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          CardIconBadge(icon: icon, size: 34, iconSize: 18),
          const SizedBox(height: AppSpacing.sm),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value, style: textTheme.titleLarge),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: textTheme.bodySmall,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _AchievementsRow extends StatelessWidget {
  const _AchievementsRow({required this.items});

  final List<AchievementItem> items;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: AppSpacing.md),
          Expanded(child: _AchievementBadge(item: items[i])),
        ],
      ],
    );
  }
}

class _AchievementBadge extends StatelessWidget {
  const _AchievementBadge({required this.item});

  final AchievementItem item;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CardIconBadge(
          icon: _iconFor(item.iconName),
          size: 56,
          iconSize: 28,
          shape: BoxShape.circle,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          item.name,
          style: Theme.of(context).textTheme.titleSmall,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  static IconData _iconFor(String name) {
    return switch (name) {
      'military_tech' => Icons.military_tech_rounded,
      'workspace_premium' => Icons.workspace_premium_rounded,
      'emoji_events' => Icons.emoji_events_rounded,
      _ => Icons.stars_rounded,
    };
  }
}
