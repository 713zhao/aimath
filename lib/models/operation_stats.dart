import '../utils/enums.dart';

/// Statistics for a specific math operation at a given difficulty level
class OperationStats {
  final String id;
  final String studentId;
  final Operation operation;
  final int difficultyLevelId;
  final int totalAttempts;
  final int correctAttempts;
  final int totalPoints;
  final DateTime lastPracticedAt;
  final DateTime createdAt;

  OperationStats({
    required this.id,
    required this.studentId,
    required this.operation,
    required this.difficultyLevelId,
    required this.totalAttempts,
    required this.correctAttempts,
    required this.totalPoints,
    required this.lastPracticedAt,
    required this.createdAt,
  });

  /// Get the accuracy percentage for this operation/level combination
  double get accuracyPercentage {
    if (totalAttempts == 0) return 0;
    return (correctAttempts / totalAttempts) * 100;
  }

  /// Check if this operation/level is mastered (85%+ accuracy)
  bool get isMastered => accuracyPercentage >= 85;

  /// Get the average points per attempt
  double get averagePointsPerAttempt {
    if (totalAttempts == 0) return 0;
    return totalPoints / totalAttempts;
  }

  /// Get performance level based on accuracy
  PerformanceLevel get performanceLevel {
    final accuracy = accuracyPercentage;
    if (accuracy >= 85) {
      return PerformanceLevel.excellent;
    } else if (accuracy >= 71) {
      return PerformanceLevel.good;
    } else if (accuracy >= 51) {
      return PerformanceLevel.average;
    } else {
      return PerformanceLevel.poor;
    }
  }

  /// Get a progress indicator (0.0 to 1.0)
  double get progressToMastery {
    final accuracy = accuracyPercentage.clamp(0, 100);
    return accuracy / 100;
  }

  /// Update stats with new attempt result
  OperationStats withNewAttempt({
    required bool isCorrect,
    required int pointsEarned,
  }) {
    return OperationStats(
      id: id,
      studentId: studentId,
      operation: operation,
      difficultyLevelId: difficultyLevelId,
      totalAttempts: totalAttempts + 1,
      correctAttempts: correctAttempts + (isCorrect ? 1 : 0),
      totalPoints: totalPoints + pointsEarned,
      lastPracticedAt: DateTime.now(),
      createdAt: createdAt,
    );
  }

  /// Create a copy with modified fields
  OperationStats copyWith({
    String? id,
    String? studentId,
    Operation? operation,
    int? difficultyLevelId,
    int? totalAttempts,
    int? correctAttempts,
    int? totalPoints,
    DateTime? lastPracticedAt,
    DateTime? createdAt,
  }) {
    return OperationStats(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      operation: operation ?? this.operation,
      difficultyLevelId: difficultyLevelId ?? this.difficultyLevelId,
      totalAttempts: totalAttempts ?? this.totalAttempts,
      correctAttempts: correctAttempts ?? this.correctAttempts,
      totalPoints: totalPoints ?? this.totalPoints,
      lastPracticedAt: lastPracticedAt ?? this.lastPracticedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'operation': operation.toString().split('.').last,
      'difficultyLevelId': difficultyLevelId,
      'totalAttempts': totalAttempts,
      'correctAttempts': correctAttempts,
      'totalPoints': totalPoints,
      'lastPracticedAt': lastPracticedAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Create from JSON
  factory OperationStats.fromJson(Map<String, dynamic> json) {
    return OperationStats(
      id: json['id'] as String,
      studentId: json['studentId'] as String,
      operation: Operation.values.firstWhere(
        (e) => e.toString().split('.').last == json['operation'] as String,
      ),
      difficultyLevelId: json['difficultyLevelId'] as int,
      totalAttempts: json['totalAttempts'] as int,
      correctAttempts: json['correctAttempts'] as int,
      totalPoints: json['totalPoints'] as int,
      lastPracticedAt: DateTime.parse(json['lastPracticedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  String toString() {
    return 'OperationStats(op: ${operation.symbol}, level: $difficultyLevelId, accuracy: ${accuracyPercentage.toStringAsFixed(1)}%)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OperationStats && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
