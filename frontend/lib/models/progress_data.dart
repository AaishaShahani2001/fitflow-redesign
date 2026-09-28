/// Dashboard period shown by the Week / Month / Year selector.
enum ProgressPeriod { week, month, year }

/// One labelled value on the workouts chart.
class ChartPoint {
  const ChartPoint({required this.label, required this.value});

  final String label;
  final double value;
}

/// Mock snapshot for one dashboard period.
///
/// Replace these constants with live data later without touching the widgets.
class ProgressSnapshot {
  const ProgressSnapshot({
    required this.chart,
    required this.workoutCount,
    required this.totalTimeLabel,
    required this.streakDays,
  });

  final List<ChartPoint> chart;
  final int workoutCount;
  final String totalTimeLabel;
  final int streakDays;

  static const Map<ProgressPeriod, ProgressSnapshot> byPeriod = {
    ProgressPeriod.week: ProgressSnapshot(
      chart: [
        ChartPoint(label: 'Mon', value: 1),
        ChartPoint(label: 'Tue', value: 1),
        ChartPoint(label: 'Wed', value: 2),
        ChartPoint(label: 'Thu', value: 2),
        ChartPoint(label: 'Fri', value: 3),
        ChartPoint(label: 'Sat', value: 4),
        ChartPoint(label: 'Sun', value: 5),
      ],
      workoutCount: 12,
      totalTimeLabel: '4.5 h',
      streakDays: 5,
    ),
    ProgressPeriod.month: ProgressSnapshot(
      chart: [
        ChartPoint(label: 'W1', value: 2),
        ChartPoint(label: 'W2', value: 3),
        ChartPoint(label: 'W3', value: 4),
        ChartPoint(label: 'W4', value: 6),
      ],
      workoutCount: 28,
      totalTimeLabel: '18.0 h',
      streakDays: 7,
    ),
    ProgressPeriod.year: ProgressSnapshot(
      chart: [
        ChartPoint(label: 'J', value: 8),
        ChartPoint(label: 'F', value: 10),
        ChartPoint(label: 'M', value: 12),
        ChartPoint(label: 'A', value: 11),
        ChartPoint(label: 'M', value: 14),
        ChartPoint(label: 'J', value: 16),
        ChartPoint(label: 'J', value: 15),
        ChartPoint(label: 'A', value: 18),
        ChartPoint(label: 'S', value: 20),
        ChartPoint(label: 'O', value: 19),
        ChartPoint(label: 'N', value: 21),
        ChartPoint(label: 'D', value: 24),
      ],
      workoutCount: 142,
      totalTimeLabel: '96.5 h',
      streakDays: 12,
    ),
  };
}

/// One earned badge on the Progress dashboard.
class AchievementItem {
  const AchievementItem({required this.name, required this.iconName});

  final String name;

  /// Stable key so the UI can map to a Material icon without storing IconData.
  final String iconName;
}

const List<AchievementItem> mockAchievements = [
  AchievementItem(name: 'Beginner', iconName: 'military_tech'),
  AchievementItem(name: 'Consistency', iconName: 'workspace_premium'),
  AchievementItem(name: 'Stronger', iconName: 'emoji_events'),
];

/// Mock recap used by the Weekly / Monthly / Yearly summary screens.
class PeriodSummaryData {
  const PeriodSummaryData({
    required this.completedWorkouts,
    required this.targetWorkouts,
    required this.slotLabels,
    required this.completedSlots,
    required this.workoutTimeValue,
    required this.workoutTimeTarget,
    required this.workoutTimeUnit,
    required this.nutritionPercent,
  });

  final int completedWorkouts;
  final int targetWorkouts;

  /// Day, week, or month labels shown above the completion marks.
  final List<String> slotLabels;

  /// Length matches [slotLabels]; `true` means that slot met its workout goal.
  final List<bool> completedSlots;

  final double workoutTimeValue;
  final double workoutTimeTarget;

  /// Display unit, e.g. `min` or `h`.
  final String workoutTimeUnit;
  final int nutritionPercent;

  String get workoutTimeLabel {
    String format(double value) {
      return value == value.roundToDouble()
          ? value.toInt().toString()
          : value.toStringAsFixed(1);
    }

    return '${format(workoutTimeValue)} / ${format(workoutTimeTarget)} '
        '$workoutTimeUnit';
  }

  double get workoutTimeProgress {
    if (workoutTimeTarget == 0) return 0;
    return workoutTimeValue / workoutTimeTarget;
  }
}

/// Kept so existing Weekly Summary call sites stay readable.
typedef WeeklySummaryData = PeriodSummaryData;

const PeriodSummaryData mockWeeklySummary = PeriodSummaryData(
  completedWorkouts: 4,
  targetWorkouts: 5,
  slotLabels: ['M', 'T', 'W', 'T', 'F', 'S', 'S'],
  completedSlots: [true, true, false, true, true, false, false],
  workoutTimeValue: 120,
  workoutTimeTarget: 150,
  workoutTimeUnit: 'min',
  nutritionPercent: 80,
);

const PeriodSummaryData mockMonthlySummary = PeriodSummaryData(
  completedWorkouts: 16,
  targetWorkouts: 20,
  slotLabels: ['W1', 'W2', 'W3', 'W4'],
  completedSlots: [true, true, true, false],
  workoutTimeValue: 18,
  workoutTimeTarget: 22.5,
  workoutTimeUnit: 'h',
  nutritionPercent: 75,
);

const PeriodSummaryData mockYearlySummary = PeriodSummaryData(
  completedWorkouts: 142,
  targetWorkouts: 156,
  slotLabels: [
    'J',
    'F',
    'M',
    'A',
    'M',
    'J',
    'J',
    'A',
    'S',
    'O',
    'N',
    'D',
  ],
  completedSlots: [
    true,
    true,
    true,
    false,
    true,
    true,
    true,
    true,
    true,
    false,
    true,
    true,
  ],
  workoutTimeValue: 96.5,
  workoutTimeTarget: 120,
  workoutTimeUnit: 'h',
  nutritionPercent: 82,
);
