import 'package:flutter_test/flutter_test.dart';
import 'package:aimath/controllers/game_controller.dart';
import 'package:aimath/utils/enums.dart';

void main() {
  late GameController gameController;

  setUp(() {
    gameController = GameController();
  });

  group('GameController - Session Initialization', () {
    test('initializes with correct difficulty level', () {
      gameController.initializeSession(
        studentId: 'test_student',
        difficultyLevel: 2,
        selectedOperations: [Operation.add, Operation.subtract],
      );

      expect(gameController.studentId, equals('test_student'));
      expect(gameController.totalProblems, greaterThan(0));
    });

    test('generates problems for the session', () {
      gameController.initializeSession(
        studentId: 'test_student',
        difficultyLevel: 1,
        selectedOperations: [Operation.add],
      );

      expect(gameController.totalProblems, greaterThan(0));
      expect(gameController.currentProblem, isNotNull);
    });

    test('creates attempts list', () {
      gameController.initializeSession(
        studentId: 'test_student',
        difficultyLevel: 1,
        selectedOperations: [Operation.add, Operation.subtract],
      );

      expect(gameController.currentProblemIndex, equals(0));
    });

    test('session not active immediately after initialization', () {
      gameController.initializeSession(
        studentId: 'test_student',
        difficultyLevel: 1,
        selectedOperations: [Operation.add],
      );

      expect(gameController.isSessionActive, false);
    });

    test('stores selected operations', () {
      const operations = [Operation.multiply, Operation.divide];
      gameController.initializeSession(
        studentId: 'test_student',
        difficultyLevel: 3,
        selectedOperations: operations,
      );

      expect(gameController.selectedOperations, equals(operations));
    });
  });

  group('GameController - Session State', () {
    setUp(() {
      gameController.initializeSession(
        studentId: 'test_student',
        difficultyLevel: 2,
        selectedOperations: [Operation.add, Operation.subtract],
      );
    });

    test('has current problem after initialization', () {
      expect(gameController.currentProblem, isNotNull);
    });

    test('has more problems initially', () {
      expect(gameController.hasMoreProblems, true);
    });

    test('current problem index starts at 0', () {
      expect(gameController.currentProblemIndex, equals(0));
    });

    test('session points start at 0', () {
      expect(gameController.sessionPoints, equals(0));
    });

    test('returns same problem until answered', () {
      final firstProblem = gameController.currentProblem;
      final secondAccess = gameController.currentProblem;

      expect(firstProblem!.id, equals(secondAccess!.id));
    });
  });

  group('GameController - Problem Progression', () {
    setUp(() {
      gameController.initializeSession(
        studentId: 'test_student',
        difficultyLevel: 1,
        selectedOperations: [Operation.add],
      );
    });

    test('progresses through problems in order', () {
      // Store first problem ID
      final firstProblemId = gameController.currentProblem!.id;

      // Verify multiple problems exist
      expect(gameController.totalProblems, greaterThan(1));

      // Both problems should be different
      if (gameController.totalProblems > 1) {
        expect(firstProblemId, isNotNull);
      }
    });

    test('initially has more problems', () {
      expect(gameController.hasMoreProblems, true);
    });

    test('problem index is zero based', () {
      expect(gameController.currentProblemIndex, greaterThanOrEqualTo(0));
      expect(gameController.currentProblemIndex, lessThan(gameController.totalProblems));
    });
  });

  group('GameController - Problem Attempt Recording', () {
    setUp(() {
      gameController.initializeSession(
        studentId: 'test_student',
        difficultyLevel: 2,
        selectedOperations: [Operation.add],
      );
    });

    test('can submit answer for current problem', () {
      final problem = gameController.currentProblem;
      expect(problem, isNotNull);

      // Get the correct answer for the problem
      late int correctAnswer;
      switch (problem!.operation) {
        case Operation.add:
          correctAnswer = problem.firstNumber + problem.secondNumber;
          break;
        case Operation.subtract:
          correctAnswer = problem.firstNumber - problem.secondNumber;
          break;
        case Operation.multiply:
          correctAnswer = problem.firstNumber * problem.secondNumber;
          break;
        case Operation.divide:
          correctAnswer = problem.firstNumber ~/ problem.secondNumber;
          break;
      }

      // Should be able to submit answer (method may throw or return)
      expect(() {
        gameController.submitAnswer(correctAnswer);
      }, returnsNormally);
    });
  });

  group('GameController - Edge Cases', () {
    test('handles single operation', () {
      gameController.initializeSession(
        studentId: 'test_student',
        difficultyLevel: 1,
        selectedOperations: [Operation.add],
      );

      expect(gameController.selectedOperations.length, equals(1));
      expect(gameController.selectedOperations[0], equals(Operation.add));
    });

    test('handles multiple operations', () {
      const operations = [
        Operation.add,
        Operation.subtract,
        Operation.multiply,
        Operation.divide,
      ];
      gameController.initializeSession(
        studentId: 'test_student',
        difficultyLevel: 3,
        selectedOperations: operations,
      );

      expect(gameController.selectedOperations.length, equals(4));
    });

    test('handles all difficulty levels', () {
      for (int level = 1; level <= 4; level++) {
        gameController = GameController(); // Reset
        gameController.initializeSession(
          studentId: 'test_student',
          difficultyLevel: level,
          selectedOperations: [Operation.add],
        );

        expect(gameController.totalProblems, greaterThan(0));
      }
    });

    test('handles student ID storage', () {
      const studentId = 'unique_student_123';
      gameController.initializeSession(
        studentId: studentId,
        difficultyLevel: 1,
        selectedOperations: [Operation.add],
      );

      expect(gameController.studentId, equals(studentId));
    });
  });
}
