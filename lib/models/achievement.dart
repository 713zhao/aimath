/// Represents an achievement/badge the student has earned
class Achievement {
  final String id;
  final String studentId;
  final String title;
  final String description;
  final String icon;
  final DateTime unlockedAt;
  final int points;

  Achievement({
    required this.id,
    required this.studentId,
    required this.title,
    required this.description,
    required this.icon,
    required this.unlockedAt,
    required this.points,
  });

  /// Create a copy with modified fields
  Achievement copyWith({
    String? id,
    String? studentId,
    String? title,
    String? description,
    String? icon,
    DateTime? unlockedAt,
    int? points,
  }) {
    return Achievement(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      points: points ?? this.points,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'title': title,
      'description': description,
      'icon': icon,
      'unlockedAt': unlockedAt.toIso8601String(),
      'points': points,
    };
  }

  /// Create from JSON
  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      studentId: json['studentId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      unlockedAt: DateTime.parse(json['unlockedAt'] as String),
      points: json['points'] as int,
    );
  }

  @override
  String toString() {
    return 'Achievement(id: $id, title: $title, icon: $icon)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Achievement && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Predefined achievement definitions
class AchievementDefinitions {
  /// Get all predefined achievements
  static const List<AchievementDef> allAchievements = [
    AchievementDef(
      id: 'first_correct',
      title: 'First Step',
      description: 'Answer your first question correctly',
      icon: '🌟',
      points: 5,
    ),
    AchievementDef(
      id: 'streak_5',
      title: 'On Fire!',
      description: 'Get 5 correct answers in a row',
      icon: '🔥',
      points: 25,
    ),
    AchievementDef(
      id: 'streak_10',
      title: 'Unstoppable',
      description: 'Get 10 correct answers in a row',
      icon: '⚡',
      points: 50,
    ),
    AchievementDef(
      id: 'master_level_1',
      title: 'Easy Master',
      description: 'Reach 85% accuracy on Level 1',
      icon: '🟢',
      points: 50,
    ),
    AchievementDef(
      id: 'master_level_2',
      title: 'Medium Master',
      description: 'Reach 85% accuracy on Level 2',
      icon: '🟡',
      points: 75,
    ),
    AchievementDef(
      id: 'master_level_3',
      title: 'Hard Master',
      description: 'Reach 85% accuracy on Level 3',
      icon: '🔴',
      points: 100,
    ),
    AchievementDef(
      id: 'master_level_4',
      title: 'Expert Master',
      description: 'Reach 85% accuracy on Level 4',
      icon: '⭐',
      points: 150,
    ),
    AchievementDef(
      id: 'addition_master',
      title: 'Addition Master',
      description: 'Master addition across all levels',
      icon: '➕',
      points: 100,
    ),
    AchievementDef(
      id: 'subtraction_master',
      title: 'Subtraction Master',
      description: 'Master subtraction across all levels',
      icon: '➖',
      points: 100,
    ),
    AchievementDef(
      id: 'multiplication_master',
      title: 'Multiplication Master',
      description: 'Master multiplication across all levels',
      icon: '✖️',
      points: 150,
    ),
    AchievementDef(
      id: 'division_master',
      title: 'Division Master',
      description: 'Master division across all levels',
      icon: '➗',
      points: 150,
    ),
    AchievementDef(
      id: '100_problems',
      title: 'Century',
      description: 'Solve 100 problems',
      icon: '💯',
      points: 100,
    ),
    AchievementDef(
      id: '1000_problems',
      title: 'Legend',
      description: 'Solve 1000 problems',
      icon: '👑',
      points: 250,
    ),
    AchievementDef(
      id: 'pizza_master',
      title: 'Pizza Master',
      description: 'Get a perfect score in Pizza Slices',
      icon: '🍕',
      points: 50,
    ),
    AchievementDef(
      id: 'fraction_fan',
      title: 'Fraction Fan',
      description: 'Solve 50 fraction questions in Pizza Slices',
      icon: '🥧',
      points: 75,
    ),
    AchievementDef(
      id: '1000_points',
      title: 'Point Collector',
      description: 'Earn 1000 points',
      icon: '💎',
      points: 100,
    ),
  ];

  /// Get achievement by ID
  static AchievementDef? getById(String id) {
    try {
      return allAchievements.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }
}

/// Definition for a predefined achievement
class AchievementDef {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int points;

  const AchievementDef({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.points,
  });

  @override
  String toString() => 'AchievementDef(id: $id, title: $title)';
}
