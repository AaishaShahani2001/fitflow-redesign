import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../models/workout_plan.dart';
import '../../widgets/app_card.dart';
import '../../widgets/fitflow_bottom_navigation.dart';
import 'ai_workout_result_screen.dart';

/// Mock option lists; replace with real preference data later.
const List<String> _goals = [
  'Lose Weight',
  'Build Muscle',
  'Improve Fitness',
  'Increase Strength',
  'Maintain Fitness',
];
const List<String> _levels = ['Beginner', 'Intermediate', 'Advanced'];
const List<String> _durations = [
  '15 min',
  '20 min',
  '30 min',
  '45 min',
  '60 min',
];
const List<String> _equipment = ['Home', 'Gym', 'No Equipment', 'Dumbbells'];
const List<String> _limitations = [
  'None',
  'Knee Pain',
  'Back Pain',
  'Shoulder Pain',
  'Other',
];

/// Width (at a text scale of 1.0) needed to keep Duration and Equipment
/// side by side before they stack.
const double _sideBySideMinWidth = 300;

/// Workout preference form that will later feed the AI plan generator.
class AiWorkoutPlannerScreen extends StatefulWidget {
  const AiWorkoutPlannerScreen({super.key});

  @override
  State<AiWorkoutPlannerScreen> createState() => _AiWorkoutPlannerScreenState();
}

class _AiWorkoutPlannerScreenState extends State<AiWorkoutPlannerScreen> {
  int _selectedIndex = FitFlowDestination.plan.index;
  String _goal = _goals.first;
  String _level = _levels.first;
  String _duration = _durations[1];
  String _equipmentChoice = _equipment.first;
  String _limitation = _limitations.first;

  /// Plan generated during this session; kept in memory only.
  WorkoutPlan? _currentPlan;

  void _onDestinationSelected(int index) {
    // Home returns to the dashboard; the remaining tabs only update the
    // selected state until their screens exist.
    if (index == FitFlowDestination.home.index) {
      Navigator.of(context).maybePop();
      return;
    }
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
  }

  void _onGeneratePlan() {
    final plan = WorkoutPlan(
      goal: _goal,
      level: _level,
      duration: _duration,
      equipment: _equipmentChoice,
      limitations: _limitation,
    );
    setState(() => _currentPlan = plan);
    _openPlan(plan);
  }

  /// The planner stays underneath so Back and Edit return here with the
  /// current selections intact.
  void _openPlan(WorkoutPlan plan) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AiWorkoutResultScreen(
          plan: plan,
          onPlanChanged: (updated) => setState(() => _currentPlan = updated),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentPlan = _currentPlan;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('AI Workout Planner'),
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
              _DropdownField(
                label: 'Goal',
                value: _goal,
                options: _goals,
                onChanged: (value) => setState(() => _goal = value),
              ),
              const SizedBox(height: AppSpacing.xl),
              _DropdownField(
                label: 'Level',
                value: _level,
                options: _levels,
                onChanged: (value) => setState(() => _level = value),
              ),
              const SizedBox(height: AppSpacing.xl),
              _DurationAndEquipment(
                duration: _duration,
                equipment: _equipmentChoice,
                onDurationChanged: (value) =>
                    setState(() => _duration = value),
                onEquipmentChanged: (value) =>
                    setState(() => _equipmentChoice = value),
              ),
              const SizedBox(height: AppSpacing.xl),
              _DropdownField(
                label: 'Injuries / Limitations',
                value: _limitation,
                options: _limitations,
                onChanged: (value) => setState(() => _limitation = value),
              ),
              const SizedBox(height: AppSpacing.xxl),
              ElevatedButton.icon(
                onPressed: _onGeneratePlan,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                icon: const Icon(Icons.auto_awesome_rounded, size: 20),
                label: const Text('Generate AI Plan'),
              ),
              // Only present once this session has generated a plan.
              if (currentPlan != null) ...[
                const SizedBox(height: AppSpacing.lg),
                _CurrentPlanCard(
                  plan: currentPlan,
                  onTap: () => _openPlan(currentPlan),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Entry point back into the plan generated during this session.
class _CurrentPlanCard extends StatelessWidget {
  const _CurrentPlanCard({required this.plan, required this.onTap});

  final WorkoutPlan plan;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      onTap: onTap,
      semanticLabel: 'View current plan',
      child: Row(
        children: [
          const CardIconBadge(icon: Icons.auto_awesome_rounded, size: 40),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Plan',
                  style: textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  plan.headline,
                  style: textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.secondaryText,
          ),
        ],
      ),
    );
  }
}

/// Duration and Equipment sit side by side, stacking when the row would be
/// too cramped for the current width or text scale.
class _DurationAndEquipment extends StatelessWidget {
  const _DurationAndEquipment({
    required this.duration,
    required this.equipment,
    required this.onDurationChanged,
    required this.onEquipmentChanged,
  });

  final String duration;
  final String equipment;
  final ValueChanged<String> onDurationChanged;
  final ValueChanged<String> onEquipmentChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final durationField = _DropdownField(
          label: 'Duration',
          value: duration,
          options: _durations,
          onChanged: onDurationChanged,
        );
        final equipmentField = _DropdownField(
          label: 'Equipment',
          value: equipment,
          options: _equipment,
          onChanged: onEquipmentChanged,
        );
        final rowBreakpoint = MediaQuery.textScalerOf(
          context,
        ).scale(_sideBySideMinWidth);

        if (constraints.maxWidth < rowBreakpoint) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              durationField,
              const SizedBox(height: AppSpacing.xl),
              equipmentField,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: durationField),
            const SizedBox(width: AppSpacing.lg),
            Expanded(child: equipmentField),
          ],
        );
      },
    );
  }
}

/// Labelled dropdown styled by the shared input decoration theme.
class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.titleSmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpacing.sm),
        DropdownButtonFormField<String>(
          initialValue: value,
          isExpanded: true,
          dropdownColor: AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.button),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.secondaryText,
          ),
          style: textTheme.bodyLarge,
          items: [
            for (final option in options)
              DropdownMenuItem(
                value: option,
                child: Text(
                  option,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
          onChanged: (selected) {
            if (selected != null) onChanged(selected);
          },
        ),
      ],
    );
  }
}
