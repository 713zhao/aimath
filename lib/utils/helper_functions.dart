import 'dart:math';
import '../config/difficulty_config.dart';
import '../utils/enums.dart';

/// Utility functions for generating and validating math problems
class MathProblemHelper {
  static final _random = Random();

  /// Generate a math problem for the given difficulty level and operation
  static Map<String, dynamic> generateProblem({
    required int difficultyLevelId,
    required Operation operation,
  }) {
    final level = DifficultyConfig.getLevelById(difficultyLevelId);
    if (level == null) {
      throw Exception('Invalid difficulty level: $difficultyLevelId');
    }

    final firstNumber = _generateNumber(level.minNumber, level.maxNumber);
    int secondNumber = _generateNumber(level.minNumber, level.maxNumber);

    // For division, ensure divisible for clean answers
    if (operation == Operation.divide) {
      secondNumber = _generateDivisor(firstNumber);
    }

    return {
      'firstNumber': firstNumber,
      'secondNumber': secondNumber,
      'operation': operation,
    };
  }

  /// Generate a number within the given range
  static int _generateNumber(int min, int max) {
    return min + _random.nextInt(max - min + 1);
  }

  /// Generate a divisor that evenly divides into the first number
  static int _generateDivisor(int firstNumber) {
    if (firstNumber == 0) return 1;

    // Find divisors of the first number
    final divisors = <int>[];
    for (int i = 1; i <= firstNumber && i <= 10; i++) {
      if (firstNumber % i == 0) {
        divisors.add(i);
      }
    }

    if (divisors.isEmpty) {
      return 1;
    }

    return divisors[_random.nextInt(divisors.length)];
  }

  /// Generate multiple problems for a session
  static List<Map<String, dynamic>> generateSessionProblems({
    required int difficultyLevelId,
    required List<Operation> operations,
    required int problemCount,
  }) {
    final problems = <Map<String, dynamic>>[];

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

  /// Validate if a pair of numbers is appropriate for division
  static bool isValidDivisionPair(int dividend, int divisor) {
    if (divisor == 0) return false;
    return dividend % divisor == 0;
  }

  /// Calculate the correct answer for a problem
  static int calculateAnswer({
    required int firstNumber,
    required int secondNumber,
    required Operation operation,
  }) {
    switch (operation) {
      case Operation.add:
        return firstNumber + secondNumber;
      case Operation.subtract:
        return firstNumber - secondNumber;
      case Operation.multiply:
        return firstNumber * secondNumber;
      case Operation.divide:
        if (secondNumber == 0) return 0;
        return (firstNumber / secondNumber).round();
    }
  }
}

/// Utility functions for analytics and statistics
class AnalyticsHelper {
  /// Calculate accuracy percentage
  static double calculateAccuracy({
    required int correct,
    required int total,
  }) {
    if (total == 0) return 0.0;
    return (correct / total) * 100;
  }

  /// Calculate average time per problem
  static double calculateAverageTime({
    required int totalSeconds,
    required int problemCount,
  }) {
    if (problemCount == 0) return 0.0;
    return totalSeconds / problemCount;
  }

  /// Determine performance level
  static PerformanceLevel determinePerformanceLevel(double accuracyPercentage) {
    if (accuracyPercentage >= 85) {
      return PerformanceLevel.excellent;
    } else if (accuracyPercentage >= 71) {
      return PerformanceLevel.good;
    } else if (accuracyPercentage >= 51) {
      return PerformanceLevel.average;
    } else {
      return PerformanceLevel.poor;
    }
  }

  /// Calculate progress to next milestone
  static double progressToMilestone({
    required int current,
    required int target,
  }) {
    if (target == 0) return 0.0;
    return (current / target).clamp(0.0, 1.0);
  }

  /// Get trending (improvement or decline)
  static String getTrending({
    required double previousAccuracy,
    required double currentAccuracy,
  }) {
    final difference = currentAccuracy - previousAccuracy;
    if (difference > 5) return '📈 Improving';
    if (difference < -5) return '📉 Declining';
    return '➡️ Stable';
  }
}

/// Utility functions for formatting and display
class DisplayHelper {
  /// Format points with separator
  static String formatPoints(int points) {
    return points.toString().replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (Match m) => ',',
        );
  }

  /// Format time as MM:SS
  static String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  /// Format accuracy with one decimal place
  static String formatAccuracy(double percentage) {
    return '${percentage.toStringAsFixed(1)}%';
  }

  /// Get level description
  static String getLevelDescription(int levelId) {
    switch (levelId) {
      case 1:
        return 'Practice with single-digit numbers (1-9)';
      case 2:
        return 'Practice with two-digit numbers (10-99)';
      case 3:
        return 'Practice with three-digit numbers (100-999)';
      case 4:
        return 'Challenge with large numbers (1000+)';
      default:
        return 'Unknown level';
    }
  }

  /// Get operation symbol
  static String getOperationSymbol(Operation operation) {
    return operation.symbol;
  }

  /// Get operation name
  static String getOperationName(Operation operation) {
    return operation.displayName;
  }

  /// Truncate text with ellipsis
  static String truncate(String text, {int maxLength = 20}) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
}

/// Utility functions for validation
class ValidationHelper {
  /// Validate student name
  static bool isValidName(String name) {
    return name.isNotEmpty && name.length >= 2 && name.length <= 50;
  }

  /// Validate student age
  static bool isValidAge(int age) {
    return age >= 5 && age <= 18;
  }

  /// Validate answer is reasonable (not too large)
  static bool isReasonableAnswer(int answer) {
    return answer >= -1000000 && answer <= 1000000;
  }

  /// Validate session accuracy
  static bool isValidAccuracy(double percentage) {
    return percentage >= 0 && percentage <= 100;
  }

  /// Check if streak should be maintained
  static bool shouldMaintainStreak(double sessionAccuracy) {
    return sessionAccuracy >= 85;
  }

  /// Check if streak should be broken
  static bool shouldBreakStreak(double sessionAccuracy) {
    return sessionAccuracy < 60;
  }
}

/// Utility functions for data validation and transformation
class DataHelper {
  /// Safe integer parsing
  static int? parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  /// Safe double parsing
  static double? parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  /// Safe list conversion
  static List<T> safeListCast<T>(dynamic list, {List<T>? defaultValue}) {
    try {
      if (list is List) {
        return List<T>.from(list);
      }
      return defaultValue ?? <T>[];
    } catch (e) {
      return defaultValue ?? <T>[];
    }
  }

  /// Generate unique ID with timestamp
  static String generateId(String prefix) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(10000);
    return '${prefix}_${timestamp}_$random';
  }

  /// Deep copy a map
  static Map<String, dynamic> deepCopyMap(Map<String, dynamic> source) {
    final result = <String, dynamic>{};
    source.forEach((key, value) {
      if (value is Map) {
        result[key] = deepCopyMap(Map<String, dynamic>.from(value));
      } else if (value is List) {
        result[key] = List.from(value);
      } else {
        result[key] = value;
      }
    });
    return result;
  }
}
