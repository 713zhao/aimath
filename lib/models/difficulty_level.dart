import '../utils/enums.dart';

/// Student's progress tracking for a specific difficulty level
class DifficultyLevelProgress {
  final String id;
  final String studentId;
  final int levelId;
  final int totalAttempts;
  final int correctAttempts;
  final int totalPoints;
  final bool isUnlocked;
  final bool isMastered;
  final DateTime firstAttemptAt;
  final DateTime? masteredAt;
  final DateTime lastAttemptAt;

  DifficultyLevelProgress({
    required this.id,
    required this.studentId,
    required this.levelId,
    required this.totalAttempts,
    required this.correctAttempts,
    required this.totalPoints,
    required this.isUnlocked,
    required this.isMastered,
    required this.firstAttemptAt,
    this.masteredAt,
    required this.lastAttemptAt,
  });

  /// Get accuracy percentage for this level
  double get accuracyPercentage {
    if (totalAttempts == 0) return 0;
    return (correctAttempts / totalAttempts) * 100;
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

  /// Get progress to mastery (0.0 to 1.0)
  double get progressToMastery {
    return (accuracyPercentage / 100).clamp(0, 1);
  }

  /// Update progress with new attempt
  DifficultyLevelProgress withNewAttempt({
    required bool isCorrect,
    required int pointsEarned,
  }) {
    final newCorrect = correctAttempts + (isCorrect ? 1 : 0);
    final newTotal = totalAttempts + 1;
    final newAccuracy = (newCorrect / newTotal) * 100;
    final newIsMastered = isMastered || newAccuracy >= 85;
    final newMasteredAt = !isMastered && newIsMastered ? DateTime.now() : masteredAt;

    return DifficultyLevelProgress(
      id: id,
      studentId: studentId,
      levelId: levelId,
      totalAttempts: newTotal,
      correctAttempts: newCorrect,
      totalPoints: totalPoints + pointsEarned,
      isUnlocked: isUnlocked,
      isMastered: newIsMastered,
      firstAttemptAt: firstAttemptAt,
      masteredAt: newMasteredAt,
      lastAttemptAt: DateTime.now(),
    );
  }

  /// Create a copy with modified fields
  DifficultyLevelProgress copyWith({
    String? id,
    String? studentId,
    int? levelId,
    int? totalAttempts,
    int? correctAttempts,
    int? totalPoints,
    bool? isUnlocked,
    bool? isMastered,
    DateTime? firstAttemptAt,
    DateTime? masteredAt,
    DateTime? lastAttemptAt,
  }) {
    return DifficultyLevelProgress(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      levelId: levelId ?? this.levelId,
      totalAttempts: totalAttempts ?? this.totalAttempts,
      correctAttempts: correctAttempts ?? this.correctAttempts,
      totalPoints: totalPoints ?? this.totalPoints,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      isMastered: isMastered ?? this.isMastered,
      firstAttemptAt: firstAttemptAt ?? this.firstAttemptAt,
      masteredAt: masteredAt ?? this.masteredAt,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'levelId': levelId,
      'totalAttempts': totalAttempts,
      'correctAttempts': correctAttempts,
      'totalPoints': totalPoints,
      'isUnlocked': isUnlocked,
      'isMastered': isMastered,
      'firstAttemptAt': firstAttemptAt.toIso8601String(),
      'masteredAt': masteredAt?.toIso8601String(),
      'lastAttemptAt': lastAttemptAt.toIso8601String(),
    };
  }

  /// Create from JSON
  factory DifficultyLevelProgress.fromJson(Map<String, dynamic> json) {
    return DifficultyLevelProgress(
      id: json['id'] as String,
      studentId: json['studentId'] as String,
      levelId: json['levelId'] as int,
      totalAttempts: json['totalAttempts'] as int,
      correctAttempts: json['correctAttempts'] as int,
      totalPoints: json['totalPoints'] as int,
      isUnlocked: json['isUnlocked'] as bool,
      isMastered: json['isMastered'] as bool,
      firstAttemptAt: DateTime.parse(json['firstAttemptAt'] as String),
      masteredAt: json['masteredAt'] != null
          ? DateTime.parse(json['masteredAt'] as String)
          : null,
      lastAttemptAt: DateTime.parse(json['lastAttemptAt'] as String),
    );
  }

  @override
  String toString() {
    return 'DifficultyLevelProgress(level: $levelId, accuracy: ${accuracyPercentage.toStringAsFixed(1)}%, unlocked: $isUnlocked, mastered: $isMastered)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DifficultyLevelProgress && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
