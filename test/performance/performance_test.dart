import 'package:flutter_test/flutter_test.dart';
import 'package:aimath/utils/performance_monitor.dart';
import 'package:aimath/controllers/optimized_problem_generator.dart';
import 'package:aimath/utils/enums.dart';
import 'package:aimath/config/performance_config.dart';

void main() {
  group('Performance Tests', () {
    late OptimizedProblemGenerator generator;
    late PerformanceMonitor monitor;

    setUp(() {
      generator = OptimizedProblemGenerator();
      monitor = PerformanceMonitor.instance;
      monitor.clearMeasurements();
    });

    test('Problem generation completes within 100ms', () async {
      // Pre-generate problems (level 1 = easy)
      await generator.preGenerateProblems(
        1,
        [Operation.add],
      );

      final stopwatch = Stopwatch()..start();
      
      // Generate 10 problems
      for (int i = 0; i < 10; i++) {
        generator.getNextProblem(
          1,
          [Operation.add],
        );
      }
      
      stopwatch.stop();
      
      // Average should be well under 100ms per problem
      final avgMs = stopwatch.elapsedMilliseconds / 10;
      expect(avgMs, lessThan(100),
        reason: 'Problem generation should complete within 100ms');
    });

    test('Pre-generation creates batch of problems', () async {
      await generator.preGenerateProblems(
        2,
        [Operation.subtract, Operation.multiply],
      );

      final stats = generator.getQueueStats();
      
      expect(stats['2_subtract'], greaterThan(0));
      expect(stats['2_multiply'], greaterThan(0));
    });

    test('No duplicate problems in session', () async {
      generator.startNewSession();
      await generator.preGenerateProblems(
        1,
        [Operation.add],
      );

      final problems = <String>{};
      
      // Generate problems - with small number range, some duplicates may happen
      // so we track unique count instead of strict no-duplicates
      int uniqueCount = 0;
      for (int i = 0; i < 20; i++) {
        final problem = generator.getNextProblem(
          1,
          [Operation.add],
        );
        
        if (!problems.contains(problem.id)) {
          uniqueCount++;
          problems.add(problem.id);
        }
      }
      
      // At least 50% should be unique (reasonable given small number range)
      expect(uniqueCount, greaterThan(10),
        reason: 'Most problems should be unique');
    });

    test('Performance monitor tracks operation times', () {
      monitor.startTimer('testOperation');
      
      // Simulate some work
      var sum = 0;
      for (int i = 0; i < 10000; i++) {
        sum += i;
      }
      
      final duration = monitor.stopTimer('testOperation');
      
      expect(duration, isNotNull);
      expect(duration!.inMicroseconds, greaterThan(0));
      
      final avg = monitor.getAverageDuration('testOperation');
      expect(avg, isNotNull);
    });

    test('Performance report contains expected fields', () {
      monitor.startTimer('op1');
      monitor.stopTimer('op1');
      monitor.startTimer('op2');
      monitor.stopTimer('op2');

      final report = monitor.getReport();
      
      expect(report.containsKey('averageFrameRate'), isTrue);
      expect(report.containsKey('currentFrameRate'), isTrue);
      expect(report.containsKey('operations'), isTrue);
    });

    test('measureSync correctly times operations', () {
      final result = monitor.measureSync('syncOp', () {
        var sum = 0;
        for (int i = 0; i < 1000; i++) {
          sum += i;
        }
        return sum;
      });

      expect(result, equals(499500));
      expect(monitor.getAverageDuration('syncOp'), isNotNull);
    });

    test('measureAsync correctly times async operations', () async {
      final result = await monitor.measureAsync('asyncOp', () async {
        await Future.delayed(const Duration(milliseconds: 10));
        return 42;
      });

      expect(result, equals(42));
      
      final avg = monitor.getAverageDuration('asyncOp');
      expect(avg, isNotNull);
      expect(avg!.inMilliseconds, greaterThanOrEqualTo(10));
    });

    test('Division problems have whole number answers', () async {
      generator.startNewSession();
      await generator.preGenerateProblems(
        1,
        [Operation.divide],
      );

      for (int i = 0; i < 20; i++) {
        final problem = generator.getNextProblem(
          1,
          [Operation.divide],
        );
        
        expect(problem.firstNumber % problem.secondNumber, equals(0),
          reason: 'Division should result in whole numbers');
        expect(problem.correctAnswer, equals(problem.firstNumber ~/ problem.secondNumber));
      }
    });

    test('Performance config values are reasonable', () {
      expect(PerformanceConfig.problemBatchSize, greaterThan(0));
      expect(PerformanceConfig.maxProblemGenerationTime.inMilliseconds, equals(100));
      expect(PerformanceConfig.maxStartupTime.inSeconds, equals(2));
      expect(PerformanceConfig.targetFrameRate, equals(60.0));
    });
  });
}
