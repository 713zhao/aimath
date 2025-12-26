/// Student profile and progress tracking
class StudentProfile {
  final String id;
  final String name;
  final int age;
  final DateTime createdAt;
  final DateTime lastActiveAt;
  final int totalPoints;
  final int currentStreak;
  final int longestStreak;
  final int totalProblemsCompleted;
  final int totalCorrectAnswers;
  final int currentDifficultyLevel;
  final List<String> achievementIds;

  StudentProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.createdAt,
    required this.lastActiveAt,
    required this.totalPoints,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalProblemsCompleted,
    required this.totalCorrectAnswers,
    required this.currentDifficultyLevel,
    required this.achievementIds,
  });

  /// Get overall accuracy percentage
  double get overallAccuracyPercentage {
    if (totalProblemsCompleted == 0) return 0;
    return (totalCorrectAnswers / totalProblemsCompleted) * 100;
  }

  /// Check if student is active today
  bool get isActiveToday {
    final now = DateTime.now();
    return lastActiveAt.day == now.day &&
        lastActiveAt.month == now.month &&
        lastActiveAt.year == now.year;
  }

  /// Get achievement count
  int get achievementCount => achievementIds.length;

  /// Update streak after a session
  StudentProfile updateStreak({required bool sessionCompleted, required double sessionAccuracy}) {
    int newStreak = currentStreak;
    int newLongestStreak = longestStreak;

    if (sessionCompleted && sessionAccuracy >= 85) {
      newStreak = currentStreak + 1;
      if (newStreak > newLongestStreak) {
        newLongestStreak = newStreak;
      }
    } else if (sessionCompleted && sessionAccuracy < 60) {
      newStreak = 0;
    }

    return StudentProfile(
      id: id,
      name: name,
      age: age,
      createdAt: createdAt,
      lastActiveAt: DateTime.now(),
      totalPoints: totalPoints,
      currentStreak: newStreak,
      longestStreak: newLongestStreak,
      totalProblemsCompleted: totalProblemsCompleted,
      totalCorrectAnswers: totalCorrectAnswers,
      currentDifficultyLevel: currentDifficultyLevel,
      achievementIds: achievementIds,
    );
  }

  /// Update after completing a session
  StudentProfile afterSessionCompletion({
    required int sessionPoints,
    required int sessionProblems,
    required int sessionCorrectAnswers,
  }) {
    return StudentProfile(
      id: id,
      name: name,
      age: age,
      createdAt: createdAt,
      lastActiveAt: DateTime.now(),
      totalPoints: totalPoints + sessionPoints,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      totalProblemsCompleted: totalProblemsCompleted + sessionProblems,
      totalCorrectAnswers: totalCorrectAnswers + sessionCorrectAnswers,
      currentDifficultyLevel: currentDifficultyLevel,
      achievementIds: achievementIds,
    );
  }

  /// Unlock next difficulty level
  StudentProfile unlockNextLevel() {
    return StudentProfile(
      id: id,
      name: name,
      age: age,
      createdAt: createdAt,
      lastActiveAt: lastActiveAt,
      totalPoints: totalPoints,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      totalProblemsCompleted: totalProblemsCompleted,
      totalCorrectAnswers: totalCorrectAnswers,
      currentDifficultyLevel: (currentDifficultyLevel + 1).clamp(1, 4),
      achievementIds: achievementIds,
    );
  }

  /// Add achievement
  StudentProfile addAchievement(String achievementId) {
    if (achievementIds.contains(achievementId)) {
      return this;
    }
    return StudentProfile(
      id: id,
      name: name,
      age: age,
      createdAt: createdAt,
      lastActiveAt: lastActiveAt,
      totalPoints: totalPoints,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      totalProblemsCompleted: totalProblemsCompleted,
      totalCorrectAnswers: totalCorrectAnswers,
      currentDifficultyLevel: currentDifficultyLevel,
      achievementIds: [...achievementIds, achievementId],
    );
  }

  /// Create a copy with modified fields
  StudentProfile copyWith({
    String? id,
    String? name,
    int? age,
    DateTime? createdAt,
    DateTime? lastActiveAt,
    int? totalPoints,
    int? currentStreak,
    int? longestStreak,
    int? totalProblemsCompleted,
    int? totalCorrectAnswers,
    int? currentDifficultyLevel,
    List<String>? achievementIds,
  }) {
    return StudentProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      totalPoints: totalPoints ?? this.totalPoints,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      totalProblemsCompleted: totalProblemsCompleted ?? this.totalProblemsCompleted,
      totalCorrectAnswers: totalCorrectAnswers ?? this.totalCorrectAnswers,
      currentDifficultyLevel: currentDifficultyLevel ?? this.currentDifficultyLevel,
      achievementIds: achievementIds ?? this.achievementIds,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'createdAt': createdAt.toIso8601String(),
      'lastActiveAt': lastActiveAt.toIso8601String(),
      'totalPoints': totalPoints,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'totalProblemsCompleted': totalProblemsCompleted,
      'totalCorrectAnswers': totalCorrectAnswers,
      'currentDifficultyLevel': currentDifficultyLevel,
      'achievementIds': achievementIds,
    };
  }

  /// Create from JSON
  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    return StudentProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      age: json['age'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastActiveAt: DateTime.parse(json['lastActiveAt'] as String),
      totalPoints: json['totalPoints'] as int,
      currentStreak: json['currentStreak'] as int,
      longestStreak: json['longestStreak'] as int,
      totalProblemsCompleted: json['totalProblemsCompleted'] as int,
      totalCorrectAnswers: json['totalCorrectAnswers'] as int,
      currentDifficultyLevel: json['currentDifficultyLevel'] as int,
      achievementIds: List<String>.from(json['achievementIds'] as List),
    );
  }

  @override
  String toString() {
    return 'StudentProfile(id: $id, name: $name, level: $currentDifficultyLevel, accuracy: ${overallAccuracyPercentage.toStringAsFixed(1)}%)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StudentProfile && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
