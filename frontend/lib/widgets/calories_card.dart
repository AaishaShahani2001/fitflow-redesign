import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import 'app_card.dart';

/// Statistic card showing the remaining calorie budget for the day.
class CaloriesCard extends StatelessWidget {
  const CaloriesCard({
    super.key,
    required this.caloriesLeft,
    this.title = 'Calories',
    this.unitLabel = 'kcal left',
  });

  final int caloriesLeft;
  final String title;
  final String unitLabel;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardHeader(icon: Icons.local_fire_department_rounded, title: title),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _withThousandsSeparator(caloriesLeft),
                    style: textTheme.headlineMedium,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  unitLabel,
                  style: textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _withThousandsSeparator(int value) {
    final digits = value.abs().toString();
    final buffer = StringBuffer(value.isNegative ? '-' : '');
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }
}
