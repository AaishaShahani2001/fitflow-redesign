import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import 'app_card.dart';

/// A short motivational line shown on the dashboard.
class MotivationalQuote {
  const MotivationalQuote(this.text, this.author);

  final String text;
  final String author;

  /// Mock quote pool; swap for real content later without touching the widget.
  static const List<MotivationalQuote> samples = [
    MotivationalQuote(
      'Small steps every day add up to big results.',
      'FitFlow',
    ),
    MotivationalQuote(
      "Take care of your body. It's the only place you have to live.",
      'Jim Rohn',
    ),
    MotivationalQuote(
      'Motivation gets you started. Habit keeps you going.',
      'Jim Ryun',
    ),
    MotivationalQuote(
      'The body achieves what the mind believes.',
      'Napoleon Hill',
    ),
    MotivationalQuote('Little by little, a little becomes a lot.', 'Proverb'),
  ];

  /// Rotates through [samples] so the dashboard feels fresh each day.
  static MotivationalQuote ofToday([DateTime? date]) {
    final today = date ?? DateTime.now();
    final dayOfYear = today.difference(DateTime(today.year)).inDays;
    return samples[dayOfYear % samples.length];
  }
}

/// Welcome card carrying the quote of the day.
class WelcomeCard extends StatelessWidget {
  const WelcomeCard({
    super.key,
    required this.quote,
    this.title = 'Welcome back!',
  });

  final String title;
  final MotivationalQuote quote;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardIconBadge(icon: Icons.format_quote_rounded),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  quote.text,
                  style: textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: AppColors.heading,
                  ),
                ),
                const SizedBox(height: 6),
                Text('— ${quote.author}', style: textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
