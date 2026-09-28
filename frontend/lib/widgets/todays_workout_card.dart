import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import 'app_card.dart';

/// Width (at a text scale of 1.0) needed to keep the workout details and the
/// action button on the same row.
const double _sideBySideMinWidth = 280;

/// Primary focal card of the dashboard: the workout scheduled for today.
class TodaysWorkoutCard extends StatelessWidget {
  const TodaysWorkoutCard({
    super.key,
    required this.workoutName,
    required this.duration,
    required this.onStartWorkout,
    this.title = "Today's Workout",
  });

  final String title;
  final String workoutName;
  final String duration;
  final VoidCallback onStartWorkout;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CardIconBadge(icon: Icons.fitness_center_rounded),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  title,
                  style: textTheme.titleLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          // Falls back to a stacked layout when the row would be too cramped
          // (small phones or large system text scale).
          LayoutBuilder(
            builder: (context, constraints) {
              final details = _WorkoutDetails(
                workoutName: workoutName,
                duration: duration,
              );
              final button = ElevatedButton(
                onPressed: onStartWorkout,
                child: const Text('Start Workout'),
              );
              // The breakpoint is scaled with the user's text size so that
              // larger fonts stack instead of overflowing the row.
              final rowBreakpoint = MediaQuery.textScalerOf(
                context,
              ).scale(_sideBySideMinWidth);

              if (constraints.maxWidth < rowBreakpoint) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    details,
                    const SizedBox(height: AppSpacing.lg),
                    button,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(child: details),
                  const SizedBox(width: AppSpacing.md),
                  button,
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _WorkoutDetails extends StatelessWidget {
  const _WorkoutDetails({required this.workoutName, required this.duration});

  final String workoutName;
  final String duration;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          workoutName,
          style: textTheme.headlineSmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.schedule_rounded,
              size: 16,
              color: AppColors.secondaryText,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                duration,
                style: textTheme.bodyMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
