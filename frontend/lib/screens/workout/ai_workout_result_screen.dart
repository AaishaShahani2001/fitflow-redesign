import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../models/workout_plan.dart';
import '../../widgets/app_card.dart';

/// Width (at a text scale of 1.0) needed to keep Edit and Regenerate on the
/// same row before they stack.
const double _sideBySideMinWidth = 260;

/// Result of the AI Workout Planner: the generated plan, its explanation and
/// the active workout timer.
class AiWorkoutResultScreen extends StatefulWidget {
  const AiWorkoutResultScreen({
    super.key,
    required this.plan,
    this.onPlanChanged,
  });

  final WorkoutPlan plan;

  /// Notifies the planner when Regenerate swaps the workout, so the Plan
  /// section keeps showing the same current plan.
  final ValueChanged<WorkoutPlan>? onPlanChanged;

  @override
  State<AiWorkoutResultScreen> createState() => _AiWorkoutResultScreenState();
}

class _AiWorkoutResultScreenState extends State<AiWorkoutResultScreen> {
  Timer? _workoutTimer;
  int _elapsedSeconds = 0;
  bool _isWorkoutActive = false;
  bool _isPaused = false;
  late WorkoutPlan _plan = widget.plan;

  @override
  void dispose() {
    _workoutTimer?.cancel();
    super.dispose();
  }

  /// Single place that owns the ticker so two timers can never run at once.
  void _startTicker() {
    _workoutTimer?.cancel();
    _workoutTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsedSeconds++);
    });
  }

  void _stopTicker() {
    _workoutTimer?.cancel();
    _workoutTimer = null;
  }

  void _startWorkout() {
    setState(() {
      _isWorkoutActive = true;
      _isPaused = false;
      _elapsedSeconds = 0;
    });
    _startTicker();
  }

  void _pauseWorkout() {
    _stopTicker();
    setState(() => _isPaused = true);
  }

  void _resumeWorkout() {
    setState(() => _isPaused = false);
    _startTicker();
  }

  Future<void> _finishWorkout() async {
    final shouldFinish = await _confirm(
      title: 'Finish Workout?',
      message: 'Are you sure you want to finish this workout?',
      cancelLabel: 'Cancel',
      confirmLabel: 'Finish',
    );
    if (!shouldFinish || !mounted) return;

    _stopTicker();
    final completedIn = _formatDuration(_elapsedSeconds);
    setState(() => _isPaused = true);

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Workout Complete!'),
        content: Text('You completed your workout in $completedIn.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
    if (!mounted) return;

    setState(() {
      _isWorkoutActive = false;
      _isPaused = false;
      _elapsedSeconds = 0;
    });
  }

  void _onEdit() => Navigator.of(context).maybePop();

  void _onRegenerate() {
    final regenerated = _plan.regenerated();
    setState(() => _plan = regenerated);
    widget.onPlanChanged?.call(regenerated);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Workout regenerated')));
  }

  /// Guards the back gesture and the app bar arrow while a workout runs.
  Future<void> _onPopAttempt(bool didPop) async {
    if (didPop) return;
    final shouldLeave = await _confirm(
      title: 'Workout in Progress',
      message:
          'Your workout timer is still running. '
          'Do you want to leave this workout?',
      cancelLabel: 'Stay',
      confirmLabel: 'Leave Workout',
    );
    if (!shouldLeave || !mounted) return;

    _stopTicker();
    setState(() {
      _isWorkoutActive = false;
      _isPaused = false;
    });
    Navigator.of(context).pop();
  }

  Future<bool> _confirm({
    required String title,
    required String message,
    required String cancelLabel,
    required String confirmLabel,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(cancelLabel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// `MM:SS`, switching to `HH:MM:SS` past the hour.
  static String _formatDuration(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds);
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (duration.inHours > 0) {
      return '${duration.inHours.toString().padLeft(2, '0')}:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isWorkoutActive,
      onPopInvokedWithResult: (didPop, _) => _onPopAttempt(didPop),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: 'Back',
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: const Text('Your AI Workout'),
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
                _SummaryCard(headline: _plan.headline, level: _plan.level),
                const SizedBox(height: AppSpacing.lg),
                if (_isWorkoutActive) ...[
                  _WorkoutTimerCard(
                    elapsedLabel: _formatDuration(_elapsedSeconds),
                    isPaused: _isPaused,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
                _ExerciseListCard(exercises: _plan.workout.exercises),
                const SizedBox(height: AppSpacing.lg),
                // Hidden while active so the plan cannot change mid-workout.
                if (!_isWorkoutActive) ...[
                  _WhyThisPlanCard(
                    summary: _plan.workout.summary,
                    rationale: _plan.rationale,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  _SecondaryActions(
                    onEdit: _onEdit,
                    onRegenerate: _onRegenerate,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ElevatedButton(
                    onPressed: _startWorkout,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                    child: const Text('Start Workout'),
                  ),
                ] else ...[
                  ElevatedButton(
                    onPressed: _isPaused ? _resumeWorkout : _pauseWorkout,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                    child: Text(_isPaused ? 'Resume Workout' : 'Pause Workout'),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  OutlinedButton(
                    onPressed: _finishWorkout,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                    child: const Text('Finish Workout'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.headline, required this.level});

  final String headline;
  final String level;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      child: Row(
        children: [
          const CardIconBadge(icon: Icons.auto_awesome_rounded, size: 44),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(headline, style: textTheme.titleLarge),
                const SizedBox(height: AppSpacing.xs),
                Text(level, style: textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Shown only while a workout is active.
class _WorkoutTimerCard extends StatelessWidget {
  const _WorkoutTimerCard({
    required this.elapsedLabel,
    required this.isPaused,
  });

  final String elapsedLabel;
  final bool isPaused;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      child: Column(
        children: [
          Text(
            'WORKOUT TIME',
            style: textTheme.bodySmall?.copyWith(letterSpacing: 1.2),
          ),
          const SizedBox(height: AppSpacing.md),
          FittedBox(
            child: Text(
              elapsedLabel,
              style: textTheme.headlineMedium?.copyWith(
                fontSize: 48,
                color: AppColors.primary,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _StatusPill(isPaused: isPaused),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.isPaused});

  final bool isPaused;

  @override
  Widget build(BuildContext context) {
    final color = isPaused ? AppColors.secondaryText : AppColors.progressAccent;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: isPaused
            ? AppColors.border
            : AppColors.accent.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            isPaused ? 'Workout Paused' : 'Workout Active',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: isPaused ? AppColors.secondaryText : AppColors.primaryDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseListCard extends StatelessWidget {
  const _ExerciseListCard({required this.exercises});

  final List<Exercise> exercises;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Column(
        children: [
          for (var i = 0; i < exercises.length; i++) ...[
            if (i > 0)
              const Divider(indent: AppSpacing.lg, endIndent: AppSpacing.lg),
            _ExerciseRow(position: i + 1, exercise: exercises[i]),
          ],
        ],
      ),
    );
  }
}

class _ExerciseRow extends StatelessWidget {
  const _ExerciseRow({required this.position, required this.exercise});

  final int position;
  final Exercise exercise;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          _PositionBadge(position: position),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              exercise.name,
              style: textTheme.titleSmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(exercise.detail, style: textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _PositionBadge extends StatelessWidget {
  const _PositionBadge({required this.position});

  final int position;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.35),
        shape: BoxShape.circle,
      ),
      child: Text(
        '$position',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.primaryDark,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _WhyThisPlanCard extends StatelessWidget {
  const _WhyThisPlanCard({required this.summary, required this.rationale});

  final String summary;
  final String rationale;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      color: AppColors.accent.withValues(alpha: 0.22),
      borderColor: AppColors.accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CardIconBadge(
                icon: Icons.lightbulb_outline_rounded,
                size: 34,
                iconSize: 18,
                background: AppColors.card,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text('Why this plan?', style: textTheme.titleMedium),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            summary,
            style: textTheme.bodyLarge?.copyWith(color: AppColors.heading),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(rationale, style: textTheme.bodySmall),
        ],
      ),
    );
  }
}

/// Edit and Regenerate sit side by side, stacking on very narrow widths or
/// large text scales.
class _SecondaryActions extends StatelessWidget {
  const _SecondaryActions({required this.onEdit, required this.onRegenerate});

  final VoidCallback onEdit;
  final VoidCallback onRegenerate;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final edit = OutlinedButton(
          onPressed: onEdit,
          child: const Text('Edit'),
        );
        final regenerate = OutlinedButton(
          onPressed: onRegenerate,
          child: const Text('Regenerate'),
        );
        final rowBreakpoint = MediaQuery.textScalerOf(
          context,
        ).scale(_sideBySideMinWidth);

        if (constraints.maxWidth < rowBreakpoint) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              edit,
              const SizedBox(height: AppSpacing.md),
              regenerate,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: edit),
            const SizedBox(width: AppSpacing.lg),
            Expanded(child: regenerate),
          ],
        );
      },
    );
  }
}
