/// Configuration for difficulty levels in the Math Practice App
/// 
/// Defines 4 difficulty levels with specific number ranges and point values
/// Auto-progression occurs when student reaches 85% accuracy
class DifficultyConfig {
  /// All available difficulty levels
  static const List<DifficultyLevel> allLevels = [
    DifficultyLevel(
      id: 1,
      name: 'Level 1: Easy',
      displayName: 'Easy (1-9)',
      minNumber: 1,
      maxNumber: 9,
      pointsPerCorrect: 10,
      description: 'Practice with single-digit numbers',
      icon: '🟢',
    ),
    DifficultyLevel(
      id: 2,
      name: 'Level 2: Medium',
      displayName: 'Medium (10-99)',
      minNumber: 10,
      maxNumber: 99,
      pointsPerCorrect: 15,
      description: 'Practice with two-digit numbers',
      icon: '🟡',
    ),
    DifficultyLevel(
      id: 3,
      name: 'Level 3: Hard',
      displayName: 'Hard (100-999)',
      minNumber: 100,
      maxNumber: 999,
      pointsPerCorrect: 20,
      description: 'Practice with three-digit numbers',
      icon: '🔴',
    ),
    DifficultyLevel(
      id: 4,
      name: 'Level 4: Expert',
      displayName: 'Expert (1000+)',
      minNumber: 1000,
      maxNumber: 9999,
      pointsPerCorrect: 25,
      description: 'Challenge yourself with large numbers',
      icon: '⭐',
    ),
  ];

  /// Get difficulty level by ID
  static DifficultyLevel? getLevelById(int id) {
    try {
      return allLevels.firstWhere((level) => level.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get the next difficulty level
  static DifficultyLevel? getNextLevel(int currentLevelId) {
    if (currentLevelId >= 4) return null;
    return getLevelById(currentLevelId + 1);
  }

  /// Get the previous difficulty level
  static DifficultyLevel? getPreviousLevel(int currentLevelId) {
    if (currentLevelId <= 1) return null;
    return getLevelById(currentLevelId - 1);
  }

  /// Accuracy threshold for auto-progression (%)
  static const int autoProgressionThreshold = 85;

  /// Minimum accuracy to maintain level (%)
  static const int minimumMaintainThreshold = 60;

  /// Number of problems to generate per session
  static const int problemsPerSession = 10;
}

/// Represents a single difficulty level configuration
class DifficultyLevel {
  final int id;
  final String name;
  final String displayName;
  final int minNumber;
  final int maxNumber;
  final int pointsPerCorrect;
  final String description;
  final String icon;

  const DifficultyLevel({
    required this.id,
    required this.name,
    required this.displayName,
    required this.minNumber,
    required this.maxNumber,
    required this.pointsPerCorrect,
    required this.description,
    required this.icon,
  });

  /// Get the number range as a string (e.g., "1 - 9")
  String get numberRangeDisplay => '$minNumber - $maxNumber';

  /// Check if a number is within this difficulty level's range
  bool isNumberInRange(int number) {
    return number >= minNumber && number <= maxNumber;
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'displayName': displayName,
      'minNumber': minNumber,
      'maxNumber': maxNumber,
      'pointsPerCorrect': pointsPerCorrect,
      'description': description,
      'icon': icon,
    };
  }

  /// Create from JSON
  factory DifficultyLevel.fromJson(Map<String, dynamic> json) {
    return DifficultyLevel(
      id: json['id'] as int,
      name: json['name'] as String,
      displayName: json['displayName'] as String,
      minNumber: json['minNumber'] as int,
      maxNumber: json['maxNumber'] as int,
      pointsPerCorrect: json['pointsPerCorrect'] as int,
      description: json['description'] as String,
      icon: json['icon'] as String,
    );
  }

  @override
  String toString() {
    return 'DifficultyLevel(id: $id, name: $name, range: $numberRangeDisplay)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DifficultyLevel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
