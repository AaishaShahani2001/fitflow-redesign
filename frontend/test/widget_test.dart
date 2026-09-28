import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/main.dart';

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

  testWidgets('Tapping a destination updates the selection', (tester) async {
    await tester.pumpWidget(const FitFlowApp());

    await tester.tap(find.text('Plan'));
    await tester.pumpAndSettle();

    final navigationBar = tester.widget<NavigationBar>(
      find.byType(NavigationBar),
    );
    expect(navigationBar.selectedIndex, 1);
  });
}
