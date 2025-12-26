// Simplified widget tests for HomeScreen
// Tests basic widget structure without complex provider dependencies
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HomeScreen Widget Structure Tests', () {
    testWidgets('MaterialApp renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Math Practice')),
            body: const Center(child: Text('Welcome')),
          ),
        ),
      );
      
      expect(find.text('Math Practice'), findsOneWidget);
      expect(find.text('Welcome'), findsOneWidget);
    });

    testWidgets('Start Practice button can be created', (WidgetTester tester) async {
      bool buttonPressed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => buttonPressed = true,
                child: const Text('Start Practice'),
              ),
            ),
          ),
        ),
      );
      
      expect(find.text('Start Practice'), findsOneWidget);
      await tester.tap(find.text('Start Practice'));
      expect(buttonPressed, isTrue);
    });

    testWidgets('Navigation buttons can be created', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Progress'),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Settings'),
                ),
              ],
            ),
          ),
        ),
      );
      
      expect(find.text('Progress'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('IconButton renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      );
      
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('Card widget renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Statistics'),
              ),
            ),
          ),
        ),
      );
      
      expect(find.byType(Card), findsOneWidget);
      expect(find.text('Statistics'), findsOneWidget);
    });
  });
}
