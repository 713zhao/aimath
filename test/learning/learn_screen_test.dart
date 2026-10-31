import 'dart:math';

import 'package:aimath/learning/core/learner_model_store.dart';
import 'package:aimath/providers/learning_provider.dart';
import 'package:aimath/providers/student_provider.dart';
import 'package:aimath/screens/learning/learn_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// Reads "a + b = ?" off the screen and returns the right answer.
int solveOnScreen(WidgetTester tester) {
  final text = tester
      .widgetList<Text>(find.byType(Text))
      .map((t) => t.data ?? '')
      .firstWhere((s) => s.endsWith(' = ?'));
  final parts = text.replaceAll(' = ?', '').split(' ');
  final a = int.parse(parts[0]), b = int.parse(parts[2]);
  switch (parts[1]) {
    case '+':
      return a + b;
    case '−':
      return a - b;
    case '×':
      return a * b;
    default:
      return a ~/ b;
  }
}

Future<void> typeAnswer(WidgetTester tester, int n) async {
  for (final d in n.toString().split('')) {
    await tester.tap(find.widgetWithText(ElevatedButton, d));
  }
  await tester.tap(find.widgetWithText(ElevatedButton, '✓'));
  await tester.pump();
}

void main() {
  testWidgets('placement test from the Learn tab places the child on the map', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);

    final learning = LearningProvider(store: MemoryLearnerModelStore(), rng: Random(2));
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: StudentProvider()),
        ChangeNotifierProvider.value(value: learning),
      ],
      child: const MaterialApp(home: LearnScreen()),
    ));
    await tester.pumpAndSettle();

    expect(find.text('🔢 Math'), findsWidgets);
    expect(find.text('Find my level'), findsOneWidget);
    expect(find.text('0 of 16 skills mastered'), findsOneWidget);

    await tester.tap(find.text('Find my level'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();

    // Answer everything correctly: the child should be placed at the top.
    var guard = 0;
    while (find.text('All done!').evaluate().isEmpty && guard++ < 40) {
      await typeAnswer(tester, solveOnScreen(tester));
      await tester.pumpAndSettle();
    }
    expect(find.text('You already know 16 skills!'), findsOneWidget);

    await tester.tap(find.text('See my skill map'));
    await tester.pumpAndSettle();
    expect(find.text('Every skill mastered!'), findsOneWidget);
    expect(find.text('16 of 16 skills mastered'), findsOneWidget);
  });

  testWidgets('practising a skill shows a targeted hint after a mistake', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);

    final learning = LearningProvider(store: MemoryLearnerModelStore(), rng: Random(4));
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: StudentProvider()),
        ChangeNotifierProvider.value(value: learning),
      ],
      child: const MaterialApp(home: LearnScreen()),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Skip — start from the beginning'));
    await tester.pumpAndSettle();
    expect(find.text('Add within 5'), findsOneWidget);

    final answer = solveOnScreen(tester);
    await typeAnswer(tester, answer + 1);
    await tester.pumpAndSettle();
    expect(find.text('The answer is $answer'), findsOneWidget);
    expect(find.textContaining('Just 1 away'), findsOneWidget);

    // Keep answering correctly until mastered.
    await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
    await tester.pumpAndSettle();
    var guard = 0;
    while (find.textContaining('You mastered').evaluate().isEmpty && guard++ < 20) {
      await typeAnswer(tester, solveOnScreen(tester));
      await tester.pumpAndSettle(const Duration(seconds: 1));
    }
    expect(find.textContaining('You mastered'), findsOneWidget);
    expect(find.text('Next: Add within 10'), findsOneWidget);
  });
}
