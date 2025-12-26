import 'dart:math';
import '../config/difficulty_config.dart';
import '../models/math_problem.dart';
import '../utils/enums.dart';

/// Generates random math problems based on difficulty level and operations
class ProblemGenerator {
  static final _random = Random();
  static final Set<String> _generatedProblems = {};

  /// Generate a single math problem
  /// Note: Negative numbers/answers are only allowed for level 4 (P4) and above
  static MathProblem generateProblem({
    required int difficultyLevelId,
    required Operation operation,
  }) {
    final level = DifficultyConfig.getLevelById(difficultyLevelId);
    if (level == null) {
      throw Exception('Invalid difficulty level: $difficultyLevelId');
    }

    // Check if negative numbers are allowed (only for level 4+ / P4+)
    final allowNegative = difficultyLevelId >= 4;

    String problemKey;
    int firstNumber, secondNumber;

    // Generate unique problem
    do {
      firstNumber = _generateNumber(level.minNumber, level.maxNumber);
      secondNumber = _generateNumber(level.minNumber, level.maxNumber);

      // For subtraction on P1/P2, ensure result is not negative
      if (operation == Operation.subtract && !allowNegative) {
        // Make sure firstNumber >= secondNumber to avoid negative result
        if (firstNumber < secondNumber) {
          final temp = firstNumber;
          firstNumber = secondNumber;
          secondNumber = temp;
        }
      }

      // For division, ensure clean integer result
      if (operation == Operation.divide) {
        secondNumber = _generateDivisor(firstNumber.abs());
        // For P1/P2, ensure firstNumber is positive
        if (!allowNegative) {
          firstNumber = firstNumber.abs();
        }
      }

      problemKey = '${operation.symbol}_${firstNumber}_${secondNumber}';
    } while (_generatedProblems.contains(problemKey) && _generatedProblems.length < 50);

    _generatedProblems.add(problemKey);

    return MathProblem(
      id: _generateId(),
      operation: operation,
      firstNumber: firstNumber,
      secondNumber: secondNumber,
      difficultyLevelId: difficultyLevelId,
      createdAt: DateTime.now(),
    );
  }

  /// Generate multiple problems for a session without repetition
  static List<MathProblem> generateSessionProblems({
    required int difficultyLevelId,
    required List<Operation> operations,
    required int problemCount,
  }) {
    _generatedProblems.clear(); // Clear for new session
    final problems = <MathProblem>[];

    for (int i = 0; i < problemCount; i++) {
      final operation = operations[i % operations.length];
      final problem = generateProblem(
        difficultyLevelId: difficultyLevelId,
        operation: operation,
      );
      problems.add(problem);
    }

    return problems;
  }
  
  /// Generate problems with custom number range (used by settings)
  static List<MathProblem> generateSessionProblemsWithRange({
    required int minNumber,
    required int maxNumber,
    required List<Operation> operations,
    required int problemCount,
  }) {
    _generatedProblems.clear();
    final problems = <MathProblem>[];
    
    for (int i = 0; i < problemCount; i++) {
      final operation = operations[i % operations.length];
      final problem = generateProblemWithRange(
        minNumber: minNumber,
        maxNumber: maxNumber,
        operation: operation,
      );
      problems.add(problem);
    }
    
    return problems;
  }
  
  /// Generate a single problem with custom number range
  static MathProblem generateProblemWithRange({
    required int minNumber,
    required int maxNumber,
    required Operation operation,
  }) {
    String problemKey;
    int firstNumber, secondNumber;
    
    // Generate unique problem
    do {
      firstNumber = _generateNumber(minNumber, maxNumber);
      secondNumber = _generateNumber(minNumber, maxNumber);
      
      // For subtraction, ensure result is not negative (swap if needed)
      if (operation == Operation.subtract && firstNumber < secondNumber) {
        final temp = firstNumber;
        firstNumber = secondNumber;
        secondNumber = temp;
      }
      
      // For division, ensure clean integer result
      if (operation == Operation.divide) {
        // Pick a divisor that gives clean result within range
        if (firstNumber == 0) firstNumber = maxNumber > 0 ? maxNumber : 1;
        secondNumber = _generateDivisor(firstNumber.abs());
        if (secondNumber == 0) secondNumber = 1;
      }
      
      problemKey = '${operation.symbol}_${firstNumber}_${secondNumber}';
    } while (_generatedProblems.contains(problemKey) && _generatedProblems.length < 100);
    
    _generatedProblems.add(problemKey);
    
    return MathProblem(
      id: _generateId(),
      operation: operation,
      firstNumber: firstNumber,
      secondNumber: secondNumber,
      difficultyLevelId: 1, // Not used with custom range
      createdAt: DateTime.now(),
    );
  }

  /// Generate number within range
  static int _generateNumber(int min, int max) {
    if (min == max) return min;
    return min + _random.nextInt(max - min + 1);
  }

  /// Generate divisor that divides evenly
  static int _generateDivisor(int dividend) {
    if (dividend == 0) return 1;

    // Find all divisors up to 10
    final divisors = <int>[];
    for (int i = 1; i <= min(dividend, 10); i++) {
      if (dividend % i == 0) {
        divisors.add(i);
      }
    }

    if (divisors.isEmpty) return 1;
    return divisors[_random.nextInt(divisors.length)];
  }

  /// Generate unique ID
  static String _generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = _random.nextInt(100000);
    return 'problem_${timestamp}_$random';
  }

  /// Clear session problems
  static void clearSession() {
    _generatedProblems.clear();
  }

  /// Get generated problem count in current session
  static int getGeneratedCount() => _generatedProblems.length;
}
