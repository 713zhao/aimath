import 'dart:async';
import 'package:aimath/models/achievement.dart';
import 'package:aimath/models/student_profile.dart';
import 'package:aimath/services/storage_service.dart';
import 'package:aimath/utils/enums.dart';

/// Manages achievement tracking and unlocking
/// 
/// Achievements:
/// - 100 Points, 500 Points, 1000 Points
/// - 5-Streak, 10-Streak
/// - Week Warrior (7 days practice)
/// - Math Genius (90%+ accuracy)
/// - Operation mastery achievements
class AchievementManager {
  final StorageService _storageService;
  
  // Track unlocked achievements
  final Set<String> _unlockedAchievements = {};
  
  // Track daily practice for week warrior
  final Set<DateTime> _practiceDays = {};
  
  // Callbacks
  Function(Achievement)? onAchievementUnlocked;

  AchievementManager({
    required StorageService storageService,
    this.onAchievementUnlocked,
  }) : _storageService = storageService;

  /// Get all unlocked achievement IDs
  Set<String> get unlockedAchievements => Set.from(_unlockedAchievements);

  /// Get count of unlocked achievements
  int get unlockedCount => _unlockedAchievements.length;

  /// Get total achievements available
  int get totalAchievements => AchievementDefinitions.allAchievements.length;

  /// Get completion percentage
  double get completionPercentage => 
      totalAchievements > 0 ? (unlockedCount / totalAchievements) * 100 : 0;

  /// Check if a specific achievement is unlocked
  bool isUnlocked(String achievementId) => 
      _unlockedAchievements.contains(achievementId);

  /// Initialize from stored data
  Future<void> initialize(String studentId) async {
    try {
      final achievements = await _storageService.getAchievements(studentId);
      _unlockedAchievements.clear();
      for (final achievement in achievements) {
        _unlockedAchievements.add(achievement.id);
      }
      
      // Load practice days from practice sessions
      final sessions = await _storageService.getPracticeSessions(studentId);
      _practiceDays.clear();
      for (final session in sessions) {
        final day = DateTime(session.startedAt.year, session.startedAt.month, session.startedAt.day);
        _practiceDays.add(day);
      }
    } catch (e) {
      // Silently fail - start fresh
    }
  }

  /// Record a practice session and check for achievements
  Future<List<Achievement>> recordSessionAndCheckAchievements({
    required String studentId,
    required int totalPoints,
    required int currentStreak,
    required int longestStreak,
    required int totalProblems,
    required int correctAnswers,
    required Map<Operation, double> operationAccuracy,
    required int currentLevel,
  }) async {
    final newAchievements = <Achievement>[];
    
    // Record today's practice
    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);
    _practiceDays.add(normalizedToday);
    
    // Check points achievements
    newAchievements.addAll(await _checkPointsAchievements(studentId, totalPoints));
    
    // Check streak achievements
    newAchievements.addAll(await _checkStreakAchievements(studentId, longestStreak));
    
    // Check first correct answer
    if (correctAnswers >= 1) {
      final firstCorrect = await _tryUnlockAchievement(studentId, 'first_correct');
      if (firstCorrect != null) newAchievements.add(firstCorrect);
    }
    
    // Check week warrior
    final weekWarrior = await _checkWeekWarrior(studentId);
    if (weekWarrior != null) newAchievements.add(weekWarrior);
    
    // Check math genius (90%+ accuracy with 50+ problems)
    if (totalProblems >= 50) {
      final accuracy = correctAnswers / totalProblems * 100;
      if (accuracy >= 90) {
        final genius = await _tryUnlockAchievement(studentId, 'math_genius');
        if (genius != null) newAchievements.add(genius);
      }
    }
    
    // Check level mastery
    newAchievements.addAll(await _checkLevelMastery(studentId, currentLevel, operationAccuracy));
    
    // Check operation mastery
    newAchievements.addAll(await _checkOperationMastery(studentId, operationAccuracy));
    
    // Check problem count achievements
    newAchievements.addAll(await _checkProblemCountAchievements(studentId, totalProblems));
    
    // Notify and save
    for (final achievement in newAchievements) {
      onAchievementUnlocked?.call(achievement);
    }
    
    return newAchievements;
  }

  /// Check points-based achievements
  Future<List<Achievement>> _checkPointsAchievements(String studentId, int points) async {
    final achievements = <Achievement>[];
    
    if (points >= 100) {
      final a = await _tryUnlockAchievement(studentId, '100_points');
      if (a != null) achievements.add(a);
    }
    if (points >= 500) {
      final a = await _tryUnlockAchievement(studentId, '500_points');
      if (a != null) achievements.add(a);
    }
    if (points >= 1000) {
      final a = await _tryUnlockAchievement(studentId, '1000_points');
      if (a != null) achievements.add(a);
    }
    
    return achievements;
  }

  /// Check streak-based achievements
  Future<List<Achievement>> _checkStreakAchievements(String studentId, int streak) async {
    final achievements = <Achievement>[];
    
    if (streak >= 5) {
      final a = await _tryUnlockAchievement(studentId, 'streak_5');
      if (a != null) achievements.add(a);
    }
    if (streak >= 10) {
      final a = await _tryUnlockAchievement(studentId, 'streak_10');
      if (a != null) achievements.add(a);
    }
    
    return achievements;
  }

  /// Check week warrior achievement (7 consecutive days)
  Future<Achievement?> _checkWeekWarrior(String studentId) async {
    // Check if practiced 7 days in the last 7 days
    final now = DateTime.now();
    int consecutiveDays = 0;
    
    for (int i = 0; i < 7; i++) {
      final checkDate = DateTime(now.year, now.month, now.day - i);
      if (_practiceDays.any((d) => 
          d.year == checkDate.year && 
          d.month == checkDate.month && 
          d.day == checkDate.day)) {
        consecutiveDays++;
      } else {
        break;
      }
    }
    
    if (consecutiveDays >= 7) {
      return await _tryUnlockAchievement(studentId, 'week_warrior');
    }
    
    return null;
  }

  /// Check level mastery achievements
  Future<List<Achievement>> _checkLevelMastery(
    String studentId, 
    int level, 
    Map<Operation, double> accuracy,
  ) async {
    final achievements = <Achievement>[];
    
    // Calculate overall accuracy
    if (accuracy.isEmpty) return achievements;
    
    final avgAccuracy = accuracy.values.reduce((a, b) => a + b) / accuracy.length;
    
    if (avgAccuracy >= 85) {
      String? achievementId;
      switch (level) {
        case 1:
          achievementId = 'master_level_1';
          break;
        case 2:
          achievementId = 'master_level_2';
          break;
        case 3:
          achievementId = 'master_level_3';
          break;
        case 4:
          achievementId = 'master_level_4';
          break;
      }
      
      if (achievementId != null) {
        final a = await _tryUnlockAchievement(studentId, achievementId);
        if (a != null) achievements.add(a);
      }
    }
    
    return achievements;
  }

  /// Check operation mastery achievements
  Future<List<Achievement>> _checkOperationMastery(
    String studentId,
    Map<Operation, double> accuracy,
  ) async {
    final achievements = <Achievement>[];
    
    for (final entry in accuracy.entries) {
      if (entry.value >= 85) {
        String? achievementId;
        switch (entry.key) {
          case Operation.add:
            achievementId = 'addition_master';
            break;
          case Operation.subtract:
            achievementId = 'subtraction_master';
            break;
          case Operation.multiply:
            achievementId = 'multiplication_master';
            break;
          case Operation.divide:
            achievementId = 'division_master';
            break;
        }
        
        if (achievementId != null) {
          final a = await _tryUnlockAchievement(studentId, achievementId);
          if (a != null) achievements.add(a);
        }
      }
    }
    
    return achievements;
  }

  /// Check problem count achievements
  Future<List<Achievement>> _checkProblemCountAchievements(
    String studentId,
    int problemCount,
  ) async {
    final achievements = <Achievement>[];
    
    if (problemCount >= 100) {
      final a = await _tryUnlockAchievement(studentId, '100_problems');
      if (a != null) achievements.add(a);
    }
    if (problemCount >= 1000) {
      final a = await _tryUnlockAchievement(studentId, '1000_problems');
      if (a != null) achievements.add(a);
    }
    
    return achievements;
  }

  /// Try to unlock an achievement if not already unlocked
  Future<Achievement?> _tryUnlockAchievement(String studentId, String achievementId) async {
    if (_unlockedAchievements.contains(achievementId)) {
      return null; // Already unlocked
    }
    
    final definition = AchievementDefinitions.getById(achievementId);
    if (definition == null) return null;
    
    final achievement = Achievement(
      id: achievementId,
      studentId: studentId,
      title: definition.title,
      description: definition.description,
      icon: definition.icon,
      unlockedAt: DateTime.now(),
      points: definition.points,
    );
    
    // Save and track
    await _storageService.saveAchievement(achievement);
    _unlockedAchievements.add(achievementId);
    
    return achievement;
  }

  /// Get all achievements with unlock status
  List<AchievementStatus> getAllAchievementsWithStatus() {
    return AchievementDefinitions.allAchievements.map((def) {
      return AchievementStatus(
        definition: def,
        isUnlocked: _unlockedAchievements.contains(def.id),
      );
    }).toList();
  }

  /// Get recently unlocked achievements (from current session)
  Future<List<Achievement>> getRecentAchievements(String studentId, {int limit = 3}) async {
    try {
      final achievements = await _storageService.getAchievements(studentId);
      // Sort by unlock date descending
      achievements.sort((a, b) => b.unlockedAt.compareTo(a.unlockedAt));
      return achievements.take(limit).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get total bonus points from achievements
  int getTotalAchievementPoints() {
    int total = 0;
    for (final achievementId in _unlockedAchievements) {
      final def = AchievementDefinitions.getById(achievementId);
      if (def != null) {
        total += def.points;
      }
    }
    return total;
  }

  /// Reset all achievements (for testing or data reset)
  Future<void> reset(String studentId) async {
    _unlockedAchievements.clear();
    _practiceDays.clear();
    // Note: Individual achievement deletion would require iterating and deleting
    // For now, clearing local state is sufficient for app restart behavior
  }
}

/// Achievement with unlock status
class AchievementStatus {
  final AchievementDef definition;
  final bool isUnlocked;

  AchievementStatus({
    required this.definition,
    required this.isUnlocked,
  });
}
