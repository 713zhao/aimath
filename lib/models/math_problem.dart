import '../utils/enums.dart';
import '../config/difficulty_config.dart';

/// Represents a single math problem in the practice session
class MathProblem {
  final String id;
  final Operation operation;
  final int firstNumber;
  final int secondNumber;
  final int difficultyLevelId;
  final DateTime createdAt;

  MathProblem({
    required this.id,
    required this.operation,
    required this.firstNumber,
    required this.secondNumber,
    required this.difficultyLevelId,
    required this.createdAt,
  });

  /// Get the correct answer to this problem
  int get correctAnswer {
    switch (operation) {
      case Operation.add:
        return firstNumber + secondNumber;
      case Operation.subtract:
        return firstNumber - secondNumber;
      case Operation.multiply:
        return firstNumber * secondNumber;
      case Operation.divide:
        // Integer division for simplicity
        if (secondNumber == 0) return 0;
        return (firstNumber / secondNumber).round();
    }
  }

  /// Get the problem as a display string (e.g., "7 + 3")
  String get displayProblem => '$firstNumber ${operation.symbol} $secondNumber';

  /// Get the full equation (e.g., "7 + 3 = ?")
  String get displayEquation => '$displayProblem = ?';

  /// Check if a given answer is correct
  bool isAnswerCorrect(int answer) {
    return answer == correctAnswer;
  }

  /// Get the difficulty level for this problem
  DifficultyLevel? get difficultyLevel {
    return DifficultyConfig.getLevelById(difficultyLevelId);
  }

  /// Create a copy with modified fields
  MathProblem copyWith({
    String? id,
    Operation? operation,
    int? firstNumber,
    int? secondNumber,
    int? difficultyLevelId,
    DateTime? createdAt,
  }) {
    return MathProblem(
      id: id ?? this.id,
      operation: operation ?? this.operation,
      firstNumber: firstNumber ?? this.firstNumber,
      secondNumber: secondNumber ?? this.secondNumber,
      difficultyLevelId: difficultyLevelId ?? this.difficultyLevelId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'operation': operation.toString().split('.').last,
      'firstNumber': firstNumber,
      'secondNumber': secondNumber,
      'difficultyLevelId': difficultyLevelId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Create from JSON
  factory MathProblem.fromJson(Map<String, dynamic> json) {
    return MathProblem(
      id: json['id'] as String,
      operation: Operation.values.firstWhere(
        (e) => e.toString().split('.').last == json['operation'] as String,
      ),
      firstNumber: json['firstNumber'] as int,
      secondNumber: json['secondNumber'] as int,
      difficultyLevelId: json['difficultyLevelId'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  String toString() {
    return 'MathProblem(id: $id, problem: $displayEquation)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MathProblem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
