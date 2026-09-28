/// A single exercise row of a generated workout.
class Exercise {
  const Exercise(this.name, this.detail);

  final String name;

  /// Reps or time, e.g. `3 × 10` or `30 sec`.
  final String detail;
}

/// One mock workout the planner can "generate".
class WorkoutVariation {
  const WorkoutVariation({
    required this.name,
    required this.exercises,
    required this.summary,
  });

  final String name;
  final List<Exercise> exercises;

  /// Opening line of the "Why this plan?" card.
  final String summary;
}

/// Mock variations cycled through by Regenerate until a real generator exists.
const List<WorkoutVariation> workoutVariations = [
  WorkoutVariation(
    name: 'Full Body',
    summary: 'Build strength and improve core stability.',
    exercises: [
      Exercise('Squats', '3 × 10'),
      Exercise('Push-ups', '3 × 8'),
      Exercise('Lunges', '3 × 10'),
      Exercise('Plank', '30 sec'),
    ],
  ),
  WorkoutVariation(
    name: 'Full Body Circuit',
    summary: 'Build strength and improve core stability.',
    exercises: [
      Exercise('Bodyweight Squats', '3 × 12'),
      Exercise('Incline Push-ups', '3 × 10'),
      Exercise('Reverse Lunges', '3 × 8'),
      Exercise('Mountain Climbers', '30 sec'),
    ],
  ),
];

/// The planner selections plus the workout they produced.
///
/// Held in memory for the current session only; nothing is persisted.
class WorkoutPlan {
  const WorkoutPlan({
    required this.goal,
    required this.level,
    required this.duration,
    required this.equipment,
    required this.limitations,
    this.variationIndex = 0,
  });

  final String goal;
  final String level;
  final String duration;
  final String equipment;
  final String limitations;

  /// Index into [workoutVariations].
  final int variationIndex;

  WorkoutVariation get workout => workoutVariations[variationIndex];

  /// Label used by summary cards, e.g. `Full Body · 20 min`.
  String get headline => '${workout.name} · $duration';

  /// Explanation sentence built from the selections.
  String get rationale {
    final adjustment = limitations == 'None'
        ? ''
        : ' Adjusted for ${limitations.toLowerCase()}.';
    return 'Matched to your ${goal.toLowerCase()} goal at '
        '${level.toLowerCase()} level using ${equipment.toLowerCase()} '
        'equipment.$adjustment';
  }

  /// Advances to the next mock variation, wrapping around.
  WorkoutPlan regenerated() {
    return copyWith(
      variationIndex: (variationIndex + 1) % workoutVariations.length,
    );
  }

  WorkoutPlan copyWith({int? variationIndex}) {
    return WorkoutPlan(
      goal: goal,
      level: level,
      duration: duration,
      equipment: equipment,
      limitations: limitations,
      variationIndex: variationIndex ?? this.variationIndex,
    );
  }
}
