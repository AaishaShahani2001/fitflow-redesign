/// One macro shown on the daily nutrition card.
class MacroTarget {
  const MacroTarget({
    required this.label,
    required this.consumed,
    required this.target,
    this.unit = 'g',
  });

  final String label;
  final int consumed;
  final int target;
  final String unit;

  String get valueLabel => '$consumed/$target$unit';

  MacroTarget copyWith({int? consumed}) {
    return MacroTarget(
      label: label,
      consumed: consumed ?? this.consumed,
      target: target,
      unit: unit,
    );
  }
}

/// A logged meal on the Nutrition dashboard.
class MealEntry {
  const MealEntry({
    required this.mealType,
    required this.name,
    required this.kcal,
    this.proteinGrams = 0,
    this.carbsGrams = 0,
    this.fatGrams = 0,
  });

  final String mealType;
  final String name;
  final int kcal;
  final int proteinGrams;
  final int carbsGrams;
  final int fatGrams;
}

/// Mock daily nutrition. Swap these constants for live data later.
class DailyNutrition {
  const DailyNutrition({
    required this.caloriesConsumed,
    required this.caloriesTarget,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.meals,
  });

  final int caloriesConsumed;
  final int caloriesTarget;
  final MacroTarget protein;
  final MacroTarget carbs;
  final MacroTarget fat;
  final List<MealEntry> meals;

  double get calorieProgress {
    if (caloriesTarget == 0) return 0;
    return caloriesConsumed / caloriesTarget;
  }

  String get calorieLabel =>
      '${_withThousandsSeparator(caloriesConsumed)} / '
      '${_withThousandsSeparator(caloriesTarget)} kcal';

  DailyNutrition adding(MealEntry meal) {
    return DailyNutrition(
      caloriesConsumed: caloriesConsumed + meal.kcal,
      caloriesTarget: caloriesTarget,
      protein: protein.copyWith(
        consumed: protein.consumed + meal.proteinGrams,
      ),
      carbs: carbs.copyWith(consumed: carbs.consumed + meal.carbsGrams),
      fat: fat.copyWith(consumed: fat.consumed + meal.fatGrams),
      meals: [...meals, meal],
    );
  }
}

/// Day filter on the Nutrition app bar.
enum NutritionDay { today, yesterday }

const Map<NutritionDay, String> nutritionDayLabels = {
  NutritionDay.today: 'Today',
  NutritionDay.yesterday: 'Yesterday',
};

const DailyNutrition mockNutritionToday = DailyNutrition(
  caloriesConsumed: 1450,
  caloriesTarget: 2000,
  protein: MacroTarget(label: 'Protein', consumed: 72, target: 100),
  carbs: MacroTarget(label: 'Carbs', consumed: 180, target: 250),
  fat: MacroTarget(label: 'Fat', consumed: 45, target: 70),
  meals: [
    MealEntry(mealType: 'Breakfast', name: 'Oats & Banana', kcal: 420),
    MealEntry(mealType: 'Lunch', name: 'Rice & Chicken', kcal: 650),
  ],
);

const DailyNutrition mockNutritionYesterday = DailyNutrition(
  caloriesConsumed: 1680,
  caloriesTarget: 2000,
  protein: MacroTarget(label: 'Protein', consumed: 88, target: 100),
  carbs: MacroTarget(label: 'Carbs', consumed: 210, target: 250),
  fat: MacroTarget(label: 'Fat', consumed: 52, target: 70),
  meals: [
    MealEntry(mealType: 'Breakfast', name: 'Eggs & Toast', kcal: 380),
    MealEntry(mealType: 'Lunch', name: 'Grilled Fish', kcal: 540),
    MealEntry(mealType: 'Dinner', name: 'Veg Stir Fry', kcal: 510),
  ],
);

const Map<NutritionDay, DailyNutrition> mockNutritionByDay = {
  NutritionDay.today: mockNutritionToday,
  NutritionDay.yesterday: mockNutritionYesterday,
};

String _withThousandsSeparator(int value) {
  final digits = value.abs().toString();
  final buffer = StringBuffer(value.isNegative ? '-' : '');
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}

String formatKcal(int kcal) => '${_withThousandsSeparator(kcal)} kcal';
