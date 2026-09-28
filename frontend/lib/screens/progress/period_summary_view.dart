import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../models/progress_data.dart';
import '../../widgets/app_card.dart';

/// Shared layout for Weekly, Monthly and Yearly summary screens.
class PeriodSummaryView extends StatelessWidget {
  const PeriodSummaryView({super.key, required this.data});

  final PeriodSummaryData data;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
            _SummaryHero(data: data),
            const SizedBox(height: AppSpacing.xl),
            _CompletionCard(data: data),
            const SizedBox(height: AppSpacing.lg),
            _GoalsCard(data: data),
            const SizedBox(height: AppSpacing.xxl),
            OutlinedButton(
              onPressed: () {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    const SnackBar(content: Text('Achievements coming soon')),
                  );
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
              child: const Text('View Achievements'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryHero extends StatelessWidget {
  const _SummaryHero({required this.data});

  final PeriodSummaryData data;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        const CardIconBadge(
          icon: Icons.emoji_events_rounded,
          size: 64,
          iconSize: 32,
          shape: BoxShape.circle,
        ),
        const SizedBox(height: AppSpacing.md),
        Text('Great Job!', style: textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.xs),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '${data.completedWorkouts}/${data.targetWorkouts}',
                style: textTheme.headlineMedium?.copyWith(
                  color: AppColors.primary,
                ),
              ),
              TextSpan(text: ' workouts!', style: textTheme.titleMedium),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _CompletionCard extends StatelessWidget {
  const _CompletionCard({required this.data});

  final PeriodSummaryData data;

  @override
  Widget build(BuildContext context) {
    final count = data.slotLabels.length < data.completedSlots.length
        ? data.slotLabels.length
        : data.completedSlots.length;
    // Week (7) and month (4) stay on one row; year (12) wraps at 6.
    final columns = count > 7 ? 6 : count;

    return AppCard(
      child: Column(
        children: [
          for (var rowStart = 0; rowStart < count; rowStart += columns) ...[
            if (rowStart > 0) const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                for (var i = rowStart; i < rowStart + columns && i < count; i++)
                  Expanded(
                    child: _SlotStatus(
                      label: data.slotLabels[i],
                      completed: data.completedSlots[i],
                    ),
                  ),
                for (
                  var pad = 0;
                  pad < columns - _slotsInRow(count, rowStart, columns);
                  pad++
                )
                  const Expanded(child: SizedBox.shrink()),
              ],
            ),
          ],
        ],
      ),
    );
  }

  static int _slotsInRow(int count, int rowStart, int columns) {
    final remaining = count - rowStart;
    return remaining < columns ? remaining : columns;
  }
}

class _SlotStatus extends StatelessWidget {
  const _SlotStatus({required this.label, required this.completed});

  final String label;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpacing.md),
        if (completed)
          const CardIconBadge(
            icon: Icons.check_rounded,
            size: 32,
            iconSize: 18,
            shape: BoxShape.circle,
            background: AppColors.primary,
            foreground: Colors.white,
          )
        else
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
              border: Border.fromBorderSide(BorderSide(color: AppColors.border)),
            ),
            child: const Text(
              '–',
              style: TextStyle(
                color: AppColors.secondaryText,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }
}

class _GoalsCard extends StatelessWidget {
  const _GoalsCard({required this.data});

  final PeriodSummaryData data;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          _GoalProgressRow(
            label: 'Workout Time',
            valueLabel: data.workoutTimeLabel,
            progress: data.workoutTimeProgress,
          ),
          const SizedBox(height: AppSpacing.xl),
          _GoalProgressRow(
            label: 'Nutrition Goal',
            valueLabel: '${data.nutritionPercent}%',
            progress: data.nutritionPercent / 100,
          ),
        ],
      ),
    );
  }
}

class _GoalProgressRow extends StatelessWidget {
  const _GoalProgressRow({
    required this.label,
    required this.valueLabel,
    required this.progress,
  });

  final String label;
  final String valueLabel;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: textTheme.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: Text(
                valueLabel,
                style: textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 10,
            backgroundColor: AppColors.border,
            color: AppColors.progressAccent,
          ),
        ),
      ],
    );
  }
}
