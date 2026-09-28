import 'package:flutter/material.dart';

import '../../models/progress_data.dart';
import 'period_summary_view.dart';

/// Child of Progress: a recap of the current week's workouts and goals.
class WeeklySummaryScreen extends StatelessWidget {
  const WeeklySummaryScreen({super.key, this.data = mockWeeklySummary});

  final PeriodSummaryData data;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('Weekly Summary'),
      ),
      body: PeriodSummaryView(data: data),
    );
  }
}
