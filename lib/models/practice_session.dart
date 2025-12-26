/// Represents a single practice session
class PracticeSession {
  final String id;
  final String studentId;
  final int difficultyLevelId;
  final List<String> problemIds;
  final List<String> attemptIds;
  final int totalPoints;
  final double accuracyPercentage;
  final DateTime startedAt;
  final DateTime? completedAt;

  PracticeSession({
    required this.id,
    required this.studentId,
    required this.difficultyLevelId,
    required this.problemIds,
    required this.attemptIds,
    required this.totalPoints,
    required this.accuracyPercentage,
    required this.startedAt,
    this.completedAt,
  });

  /// Check if session is completed
  bool get isCompleted => completedAt != null;

  /// Get session duration in seconds
  int get durationSeconds {
    final end = completedAt ?? DateTime.now();
    return end.difference(startedAt).inSeconds;
  }

  /// Get session duration as formatted string (e.g., "2:35")
  String get durationDisplay {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Get average time per problem in seconds
  double get averageTimePerProblem {
    if (problemIds.isEmpty) return 0;
    return durationSeconds / problemIds.length;
  }

  /// Get number of problems in this session
  int get problemCount => problemIds.length;

  /// Get number of attempts (should match problemIds count)
  int get attemptCount => attemptIds.length;

  /// Create a copy with modified fields
  PracticeSession copyWith({
    String? id,
    String? studentId,
    int? difficultyLevelId,
    List<String>? problemIds,
    List<String>? attemptIds,
    int? totalPoints,
    double? accuracyPercentage,
    DateTime? startedAt,
    DateTime? completedAt,
  }) {
    return PracticeSession(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      difficultyLevelId: difficultyLevelId ?? this.difficultyLevelId,
      problemIds: problemIds ?? this.problemIds,
      attemptIds: attemptIds ?? this.attemptIds,
      totalPoints: totalPoints ?? this.totalPoints,
      accuracyPercentage: accuracyPercentage ?? this.accuracyPercentage,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'difficultyLevelId': difficultyLevelId,
      'problemIds': problemIds,
      'attemptIds': attemptIds,
      'totalPoints': totalPoints,
      'accuracyPercentage': accuracyPercentage,
      'startedAt': startedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  /// Create from JSON
  factory PracticeSession.fromJson(Map<String, dynamic> json) {
    return PracticeSession(
      id: json['id'] as String,
      studentId: json['studentId'] as String,
      difficultyLevelId: json['difficultyLevelId'] as int,
      problemIds: List<String>.from(json['problemIds'] as List),
      attemptIds: List<String>.from(json['attemptIds'] as List),
      totalPoints: json['totalPoints'] as int,
      accuracyPercentage: (json['accuracyPercentage'] as num).toDouble(),
      startedAt: DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }

  @override
  String toString() {
    return 'PracticeSession(id: $id, problems: $problemCount, accuracy: ${accuracyPercentage.toStringAsFixed(1)}%)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PracticeSession && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
