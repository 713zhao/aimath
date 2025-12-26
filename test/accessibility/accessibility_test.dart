import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aimath/utils/accessibility_helpers.dart';
import 'package:aimath/utils/colors.dart';

void main() {
  group('Accessibility - Color Contrast Tests', () {
    test('Primary color on white background meets WCAG AA', () {
      const primary = Color(0xFF2196F3); // Bright Blue
      const background = Colors.white;
      
      final ratio = AccessibilityHelpers.calculateContrastRatio(primary, background);
      expect(ratio, greaterThanOrEqualTo(3.0), 
        reason: 'Primary color should meet WCAG AA for large text (3:1)');
    });

    test('Success color on white background meets WCAG AA', () {
      // Using darker green (#388E3C) that meets WCAG AA
      const success = Color(0xFF388E3C); // Dark Green (Material Green 700)
      const background = Colors.white;
      
      final ratio = AccessibilityHelpers.calculateContrastRatio(success, background);
      expect(ratio, greaterThanOrEqualTo(3.0),
        reason: 'Success color should meet WCAG AA for large text');
    });

    test('Error color on white background meets WCAG AA', () {
      const error = Color(0xFFF44336); // Red
      const background = Colors.white;
      
      final ratio = AccessibilityHelpers.calculateContrastRatio(error, background);
      expect(ratio, greaterThanOrEqualTo(3.0),
        reason: 'Error color should meet WCAG AA for large text');
    });

    test('Black text on white background meets WCAG AAA', () {
      const text = Colors.black;
      const background = Colors.white;
      
      final ratio = AccessibilityHelpers.calculateContrastRatio(text, background);
      expect(ratio, greaterThanOrEqualTo(7.0),
        reason: 'Black text on white should meet WCAG AAA (7:1)');
    });

    test('White text on primary color meets WCAG AA', () {
      const text = Colors.white;
      const primary = Color(0xFF2196F3);
      
      final ratio = AccessibilityHelpers.calculateContrastRatio(text, primary);
      expect(ratio, greaterThanOrEqualTo(3.0),
        reason: 'White text on primary should meet WCAG AA for large text');
    });

    test('White text on success color meets WCAG AA for large text', () {
      const text = Colors.white;
      // Using darker green that meets WCAG AA
      const success = Color(0xFF388E3C); // Dark Green (Material Green 700)
      
      final ratio = AccessibilityHelpers.calculateContrastRatio(text, success);
      expect(ratio, greaterThanOrEqualTo(3.0),
        reason: 'White text on success should meet WCAG AA for large text');
    });

    test('Dark text color on background meets WCAG AA', () {
      const text = Color(0xFF212121); // Dark gray
      const background = Colors.white;
      
      final ratio = AccessibilityHelpers.calculateContrastRatio(text, background);
      expect(ratio, greaterThanOrEqualTo(4.5),
        reason: 'Dark text should meet WCAG AA for normal text (4.5:1)');
    });
  });

  group('Accessibility - Touch Target Tests', () {
    testWidgets('Buttons meet minimum touch target size', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(48, 48),
                ),
                child: const Text('Test'),
              ),
            ),
          ),
        ),
      );

      final button = tester.getSize(find.byType(ElevatedButton));
      expect(button.width, greaterThanOrEqualTo(48.0),
        reason: 'Button width should be at least 48dp');
      expect(button.height, greaterThanOrEqualTo(48.0),
        reason: 'Button height should be at least 48dp');
    });

    testWidgets('Icon buttons meet minimum touch target size', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.settings),
                constraints: const BoxConstraints(
                  minWidth: 48,
                  minHeight: 48,
                ),
              ),
            ),
          ),
        ),
      );

      final button = tester.getSize(find.byType(IconButton));
      expect(button.width, greaterThanOrEqualTo(48.0));
      expect(button.height, greaterThanOrEqualTo(48.0));
    });
  });

  group('Accessibility - Semantics Tests', () {
    testWidgets('Buttons have semantic labels', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Semantics(
              label: 'Start practice session',
              button: true,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Start Practice'),
              ),
            ),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(ElevatedButton));
      expect(semantics.label, contains('Start'));
    });

    testWidgets('Images have semantic descriptions', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Semantics(
              label: 'Achievement badge for completing 100 problems',
              image: true,
              child: const Icon(Icons.stars, size: 48),
            ),
          ),
        ),
      );

      expect(find.bySemanticsLabel(RegExp('Achievement')), findsOneWidget);
    });

    testWidgets('Form fields have labels', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Semantics(
              label: 'Enter your answer',
              textField: true,
              child: const TextField(
                decoration: InputDecoration(
                  labelText: 'Answer',
                  hintText: 'Type your answer here',
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.bySemanticsLabel('Enter your answer'), findsOneWidget);
    });
  });

  group('Accessibility - Text Scaling Tests', () {
    testWidgets('UI adapts to large text scale factor', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaleFactor: 2.0),
          child: MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  const Text('Large Text Test'),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Button'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Just verify it renders without overflow
      expect(find.text('Large Text Test'), findsOneWidget);
      expect(find.text('Button'), findsOneWidget);
    });

    testWidgets('Content remains visible at 200% text scale', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaleFactor: 2.0),
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    const Text('Problem: 5 + 3 = ?'),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: const InputDecoration(labelText: 'Answer'),
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text('Submit'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Problem: 5 + 3 = ?'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Submit'), findsOneWidget);
    });
  });

  group('Accessibility - Focus Navigation Tests', () {
    testWidgets('Tab navigation follows logical order', (tester) async {
      final focusNode1 = FocusNode();
      final focusNode2 = FocusNode();
      final focusNode3 = FocusNode();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FocusTraversalGroup(
              policy: OrderedTraversalPolicy(),
              child: Column(
                children: [
                  FocusTraversalOrder(
                    order: const NumericFocusOrder(1),
                    child: TextField(
                      focusNode: focusNode1,
                      decoration: const InputDecoration(labelText: 'First'),
                    ),
                  ),
                  FocusTraversalOrder(
                    order: const NumericFocusOrder(2),
                    child: ElevatedButton(
                      focusNode: focusNode2,
                      onPressed: () {},
                      child: const Text('Second'),
                    ),
                  ),
                  FocusTraversalOrder(
                    order: const NumericFocusOrder(3),
                    child: ElevatedButton(
                      focusNode: focusNode3,
                      onPressed: () {},
                      child: const Text('Third'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Request focus on first element
      focusNode1.requestFocus();
      await tester.pump();
      expect(focusNode1.hasFocus, isTrue);

      // Move to next
      focusNode1.nextFocus();
      await tester.pump();
      expect(focusNode2.hasFocus, isTrue);

      // Move to next
      focusNode2.nextFocus();
      await tester.pump();
      expect(focusNode3.hasFocus, isTrue);

      // Cleanup
      focusNode1.dispose();
      focusNode2.dispose();
      focusNode3.dispose();
    });
  });

  group('Accessibility - Reduced Motion Tests', () {
    testWidgets('Animations respect reduced motion preference', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                final reduceMotion = MediaQuery.of(context).disableAnimations;
                return Scaffold(
                  body: Center(
                    child: Text(
                      reduceMotion ? 'Reduced Motion' : 'Normal Motion',
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Reduced Motion'), findsOneWidget);
    });
  });
}
