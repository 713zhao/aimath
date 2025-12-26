import '../utils/enums.dart';

/// Represents a student's attempt to solve a math problem
class ProblemAttempt {
  final String id;
  final String problemId;
  final String sessionId;
  final int userAnswer;
  final int correctAnswer;
  final int timeSpentSeconds;
  final DateTime attemptedAt;

  ProblemAttempt({
    required this.id,
    required this.problemId,
    required this.sessionId,
    required this.userAnswer,
    required this.correctAnswer,
    required this.timeSpentSeconds,
    required this.attemptedAt,
  });

  /// Check if the attempt was correct
  bool get isCorrect => userAnswer == correctAnswer;

  /// Get points earned for this attempt
  int getPointsEarned(int pointsPerCorrect) {
    return isCorrect ? pointsPerCorrect : 0;
  }

  /// Get feedback message based on correctness
  String get feedbackMessage {
    if (isCorrect) {
      return '✓ Correct!';
    } else {
      return '✗ Incorrect. The answer is $correctAnswer';
    }
  }

  /// Get performance level for this attempt
  PerformanceLevel get performanceLevel {
    if (isCorrect) {
      // Faster responses are better
      if (timeSpentSeconds <= 5) {
        return PerformanceLevel.excellent;
      } else if (timeSpentSeconds <= 10) {
        return PerformanceLevel.good;
      } else {
        return PerformanceLevel.average;
      }
    } else {
      return PerformanceLevel.poor;
    }
  }

  /// Create a copy with modified fields
  ProblemAttempt copyWith({
    String? id,
    String? problemId,
    String? sessionId,
    int? userAnswer,
    int? correctAnswer,
    int? timeSpentSeconds,
    DateTime? attemptedAt,
  }) {
    return ProblemAttempt(
      id: id ?? this.id,
      problemId: problemId ?? this.problemId,
      sessionId: sessionId ?? this.sessionId,
      userAnswer: userAnswer ?? this.userAnswer,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      timeSpentSeconds: timeSpentSeconds ?? this.timeSpentSeconds,
      attemptedAt: attemptedAt ?? this.attemptedAt,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'problemId': problemId,
      'sessionId': sessionId,
      'userAnswer': userAnswer,
      'correctAnswer': correctAnswer,
      'timeSpentSeconds': timeSpentSeconds,
      'attemptedAt': attemptedAt.toIso8601String(),
    };
  }

  /// Create from JSON
  factory ProblemAttempt.fromJson(Map<String, dynamic> json) {
    return ProblemAttempt(
      id: json['id'] as String,
      problemId: json['problemId'] as String,
      sessionId: json['sessionId'] as String,
      userAnswer: json['userAnswer'] as int,
      correctAnswer: json['correctAnswer'] as int,
      timeSpentSeconds: json['timeSpentSeconds'] as int,
      attemptedAt: DateTime.parse(json['attemptedAt'] as String),
    );
  }

  @override
  String toString() {
    return 'ProblemAttempt(id: $id, correct: $isCorrect, time: ${timeSpentSeconds}s)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProblemAttempt && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
