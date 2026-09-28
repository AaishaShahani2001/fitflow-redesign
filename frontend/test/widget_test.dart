import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/main.dart';
import 'package:frontend/screens/nutrition/nutrition_screen.dart';
import 'package:frontend/screens/progress/progress_screen.dart';
import 'package:frontend/screens/workout/ai_workout_planner_screen.dart';

void main() {
  testWidgets('Home dashboard renders its main sections', (tester) async {
    await tester.pumpWidget(const FitFlowApp());

    expect(find.text('FitFlow'), findsOneWidget);
    expect(
      find.textContaining('Good Morning, Shan!', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('Welcome back!'), findsOneWidget);
    expect(find.text("Today's Workout"), findsOneWidget);
    expect(find.text('75%'), findsOneWidget);
    expect(find.text('1,800'), findsOneWidget);
    expect(find.text('5 Day Streak'), findsOneWidget);
  });

  testWidgets('Start Workout shows a snack bar', (tester) async {
    await tester.pumpWidget(const FitFlowApp());

    await tester.tap(find.widgetWithText(ElevatedButton, 'Start Workout'));
    await tester.pumpAndSettle();

    expect(find.text("Starting today's workout..."), findsOneWidget);
  });

  testWidgets('Plan opens the AI Workout Planner', (tester) async {
    await tester.pumpWidget(const FitFlowApp());

    await tester.tap(find.text('Plan'));
    await tester.pumpAndSettle();

    expect(find.byType(AiWorkoutPlannerScreen), findsOneWidget);
    expect(find.text('Goal'), findsOneWidget);
    expect(find.text('Injuries / Limitations'), findsOneWidget);
  });

  testWidgets('Progress opens the Progress dashboard', (tester) async {
    await tester.pumpWidget(const FitFlowApp());

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Progress'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ProgressScreen), findsOneWidget);
    expect(find.text('Workouts'), findsWidgets);
  });

  testWidgets('Nutrition opens the Nutrition dashboard', (tester) async {
    await tester.pumpWidget(const FitFlowApp());

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Nutrition'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(NutritionScreen), findsOneWidget);
    expect(find.text("Today's Nutrition"), findsOneWidget);
    expect(find.text('1,450 / 2,000 kcal'), findsOneWidget);
  });

  testWidgets('Tapping a destination without a screen updates the selection', (
    tester,
  ) async {
    await tester.pumpWidget(const FitFlowApp());

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Community'),
      ),
    );
    await tester.pumpAndSettle();

    final navigationBar = tester.widget<NavigationBar>(
      find.byType(NavigationBar),
    );
    expect(navigationBar.selectedIndex, 3);
  });
}
