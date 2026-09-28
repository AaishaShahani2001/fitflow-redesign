import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import 'app_card.dart';

/// Statistic card showing overall progress as a circular indicator.
class ProgressCard extends StatelessWidget {
  const ProgressCard({
    super.key,
    required this.progress,
    this.title = 'Progress',
    this.ringSize = 84,
  });

  /// Completion between 0.0 and 1.0.
  final double progress;
  final String title;
  final double ringSize;

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0.0, 1.0);
    final percentage = (clamped * 100).round();

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardHeader(icon: Icons.donut_large_rounded, title: title),
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: SizedBox.square(
              dimension: ringSize,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: CircularProgressIndicator(
                      value: clamped,
                      strokeWidth: 9,
                      strokeCap: StrokeCap.round,
                      backgroundColor: AppColors.border,
                      valueColor: const AlwaysStoppedAnimation(
                        AppColors.progressAccent,
                      ),
                      semanticsLabel: title,
                      semanticsValue: '$percentage%',
                    ),
                  ),
                  Text(
                    '$percentage%',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
