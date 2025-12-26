import 'package:flutter_test/flutter_test.dart';
import 'package:aimath/controllers/problem_generator.dart';
import 'package:aimath/utils/enums.dart';

void main() {
  setUp(() {
    ProblemGenerator.clearSession();
  });

  group('ProblemGenerator - Problem Generation', () {
    test('generates problem with valid operands for difficulty 1', () {
      ProblemGenerator.clearSession();

      for (int i = 0; i < 20; i++) {
        final problem = ProblemGenerator.generateProblem(
          difficultyLevelId: 1,
          operation: Operation.add,
        );

        expect(problem.firstNumber, greaterThanOrEqualTo(0));
        expect(problem.secondNumber, greaterThanOrEqualTo(0));
      }
    });

    test('generates problem with valid operands for difficulty 2', () {
      ProblemGenerator.clearSession();

      for (int i = 0; i < 20; i++) {
        final problem = ProblemGenerator.generateProblem(
          difficultyLevelId: 2,
          operation: Operation.add,
        );

        expect(problem.firstNumber, greaterThanOrEqualTo(0));
        expect(problem.secondNumber, greaterThanOrEqualTo(0));
      }
    });

    test('generates problems without duplicates', () {
      ProblemGenerator.clearSession();

      final problems = ProblemGenerator.generateSessionProblems(
        difficultyLevelId: 1,
        operations: [Operation.add],
        problemCount: 10,
      );

      expect(problems, hasLength(10));

      // Check for duplicates
      final problemSet = <String>{};
      for (final problem in problems) {
        final key =
            '${problem.operation}_${problem.firstNumber}_${problem.secondNumber}';
        expect(
          problemSet.contains(key),
          false,
          reason:
              'Duplicate problem found: ${problem.firstNumber} ${problem.operation.symbol} ${problem.secondNumber}',
        );
        problemSet.add(key);
      }
    });

    test('division problems produce whole number results', () {
      ProblemGenerator.clearSession();

      for (int i = 0; i < 20; i++) {
        final problem = ProblemGenerator.generateProblem(
          difficultyLevelId: 2,
          operation: Operation.divide,
        );

        // firstNumber should be divisible by secondNumber
        expect(
          problem.firstNumber % problem.secondNumber,
          equals(0),
          reason:
              '${problem.firstNumber} should be divisible by ${problem.secondNumber}',
        );
      }
    });

    test('generateSessionProblems creates requested number', () {
      ProblemGenerator.clearSession();

      final problems = ProblemGenerator.generateSessionProblems(
        difficultyLevelId: 2,
        operations: [Operation.add, Operation.subtract],
        problemCount: 15,
      );

      expect(problems, hasLength(15));
    });

    test('generateSessionProblems uses specified operations', () {
      ProblemGenerator.clearSession();

      final operations = [
        Operation.add,
        Operation.subtract,
        Operation.multiply,
      ];

      final problems = ProblemGenerator.generateSessionProblems(
        difficultyLevelId: 2,
        operations: operations,
        problemCount: 30,
      );

      final usedOperations = <Operation>{};
      for (final problem in problems) {
        usedOperations.add(problem.operation);
      }

      // Check that used operations are from the specified list
      for (final op in usedOperations) {
        expect(operations.contains(op), true,
            reason: 'Unexpected operation $op in generated problems');
      }
    });

    test('invalid difficulty level throws exception', () {
      ProblemGenerator.clearSession();

      expect(
        () => ProblemGenerator.generateProblem(
          difficultyLevelId: 99,
          operation: Operation.add,
        ),
        throwsException,
      );
    });
  });

  group('ProblemGenerator - Session Management', () {
    test('clear session resets problem cache', () {
      ProblemGenerator.clearSession();

      final problems1 = ProblemGenerator.generateSessionProblems(
        difficultyLevelId: 1,
        operations: [Operation.add],
        problemCount: 5,
      );

      ProblemGenerator.clearSession();

      final problems2 = ProblemGenerator.generateSessionProblems(
        difficultyLevelId: 1,
        operations: [Operation.add],
        problemCount: 5,
      );

      // After clear, we should be able to generate similar problems again
      expect(problems1.length, equals(5));
      expect(problems2.length, equals(5));
    });

    test('multiple problems in session are unique', () {
      ProblemGenerator.clearSession();

      final problems = ProblemGenerator.generateSessionProblems(
        difficultyLevelId: 2,
        operations: [Operation.add, Operation.subtract],
        problemCount: 20,
      );

      final uniqueProblems = <String>{};
      for (final problem in problems) {
        final key =
            '${problem.operation}_${problem.firstNumber}_${problem.secondNumber}';
        uniqueProblems.add(key);
      }

      expect(uniqueProblems.length, equals(problems.length),
          reason: 'Session contains duplicate problems');
    });
  });

  group('ProblemGenerator - Problem IDs', () {
    test('each problem has unique ID', () {
      ProblemGenerator.clearSession();

      final problems = ProblemGenerator.generateSessionProblems(
        difficultyLevelId: 1,
        operations: [Operation.add],
        problemCount: 10,
      );

      final ids = <String>{};
      for (final problem in problems) {
        expect(
          ids.contains(problem.id),
          false,
          reason: 'Duplicate problem ID: ${problem.id}',
        );
        ids.add(problem.id);
      }
    });

    test('problem ID format is valid', () {
      ProblemGenerator.clearSession();

      final problem = ProblemGenerator.generateProblem(
        difficultyLevelId: 1,
        operation: Operation.add,
      );

      expect(problem.id, startsWith('problem_'));
      expect(problem.id, isNotEmpty);
    });
  });

  group('ProblemGenerator - Edge Cases', () {
    test('handles single problem request', () {
      ProblemGenerator.clearSession();

      final problems = ProblemGenerator.generateSessionProblems(
        difficultyLevelId: 1,
        operations: [Operation.add],
        problemCount: 1,
      );

      expect(problems, hasLength(1));
    });

    test('handles large problem count', () {
      ProblemGenerator.clearSession();

      final problems = ProblemGenerator.generateSessionProblems(
        difficultyLevelId: 2,
        operations: [Operation.add, Operation.subtract, Operation.multiply],
        problemCount: 50,
      );

      expect(problems.length, greaterThan(0));
      expect(problems.length, lessThanOrEqualTo(50));
    });

    test('problem creation timestamp is recent', () {
      ProblemGenerator.clearSession();

      final now = DateTime.now();
      final problem = ProblemGenerator.generateProblem(
        difficultyLevelId: 1,
        operation: Operation.add,
      );

      expect(problem.createdAt.isBefore(now.add(const Duration(seconds: 1))),
          true);
      expect(problem.createdAt.isAfter(now.subtract(const Duration(seconds: 1))),
          true);
    });

    test('all operations are supported', () {
      ProblemGenerator.clearSession();

      final operations = [
        Operation.add,
        Operation.subtract,
        Operation.multiply,
        Operation.divide,
      ];

      for (final op in operations) {
        final problem = ProblemGenerator.generateProblem(
          difficultyLevelId: 2,
          operation: op,
        );

        expect(problem.operation, equals(op));
      }
    });
  });
}
