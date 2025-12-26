import 'package:flutter/animation.dart';

/// Application-wide constants for animations, timing, and thresholds
class AppConstants {
  // Animation Durations
  static const Duration quickAnimationDuration = Duration(milliseconds: 200);
  static const Duration standardAnimationDuration = Duration(milliseconds: 300);
  static const Duration slowAnimationDuration = Duration(milliseconds: 500);
  static const Duration verySlowAnimationDuration = Duration(milliseconds: 1000);

  // Practice Session Timing
  static const int problemsPerSession = 10;
  static const int timeoutPerProblemSeconds = 120;
  static const int warningTimeThresholdSeconds = 30;

  // Points System
  static const int streakBonusMultiplier = 2;
  static const int speedBonusThresholdSeconds = 5;
  static const int speedBonusPoints = 5;

  // Accuracy Thresholds
  static const int autoProgressionThreshold = 85;
  static const int masteringThreshold = 85;
  static const int maintainThreshold = 60;
  static const int poorPerformanceThreshold = 50;

  // Streak System
  static const int streakSessionMinAccuracy = 85;
  static const int streakLossThreshold = 60;

  // Achievement Thresholds
  static const int streakLengthForAchievement = 5;
  static const int streakLengthForUltimateAchievement = 10;
  static const int problemCountForCentury = 100;
  static const int problemCountForLegend = 1000;
  static const int pointsForPointCollector = 1000;

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double largePadding = 24.0;
  static const double smallPadding = 8.0;
  static const double tinyPadding = 4.0;

  static const double defaultBorderRadius = 12.0;
  static const double largeBorderRadius = 24.0;
  static const double smallBorderRadius = 8.0;

  static const double defaultIconSize = 24.0;
  static const double largeIconSize = 48.0;
  static const double smallIconSize = 16.0;

  // Animation Curve
  static final animationCurve = Cubic(0.4, 0.0, 0.2, 1.0);
}

/// Helper functions for common calculations and utilities
class HelperFunctions {
  /// Calculate points for a given difficulty level
  static int pointsForLevel(int levelId) {
    switch (levelId) {
      case 1:
        return 10;
      case 2:
        return 15;
      case 3:
        return 20;
      case 4:
        return 25;
      default:
        return 10;
    }
  }

  /// Calculate streak multiplier based on current streak
  static double streakMultiplier(int streakLength) {
    if (streakLength < 5) return 1.0;
    if (streakLength < 10) return 1.5;
    if (streakLength < 25) return 2.0;
    return 2.5;
  }

  /// Get next level after mastering current one
  static int? levelProgression(int currentLevel) {
    if (currentLevel >= 4) return null;
    return currentLevel + 1;
  }

  /// Calculate bonus points based on time taken
  static int timeBonus(int secondsTaken, int pointsPerCorrect) {
    if (secondsTaken <= 5) {
      return (pointsPerCorrect * 0.5).toInt();
    } else if (secondsTaken <= 10) {
      return (pointsPerCorrect * 0.25).toInt();
    }
    return 0;
  }

  /// Calculate streak bonus multiplier
  static double calculateStreakBonus(int currentStreak) {
    return 1.0 + (currentStreak * 0.1).clamp(0.0, 2.0);
  }

  /// Determine if performance qualifies for accuracy bonus
  static bool qualifiesForAccuracyBonus(double accuracyPercentage) {
    return accuracyPercentage >= 90;
  }

  /// Calculate total points with all bonuses
  static int calculateTotalPoints({
    required int basePoints,
    required int timeSpentSeconds,
    required int currentStreak,
    required double sessionAccuracy,
  }) {
    int total = basePoints;

    // Time bonus
    total += timeBonus(timeSpentSeconds, basePoints);

    // Streak bonus (multiply by streak multiplier)
    if (currentStreak > 0) {
      total = (total * streakMultiplier(currentStreak)).toInt();
    }

    // Accuracy bonus
    if (qualifiesForAccuracyBonus(sessionAccuracy)) {
      total = (total * 1.25).toInt();
    }

    return total;
  }

  /// Format time duration as string
  static String formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    if (minutes == 0) {
      return '${seconds}s';
    }
    return '${minutes}m ${seconds}s';
  }

  /// Format accuracy percentage
  static String formatAccuracy(double accuracy) {
    return '${accuracy.toStringAsFixed(1)}%';
  }

  /// Generate a unique ID
  static String generateId({String? prefix}) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecond;
    final id = '${prefix ?? 'item'}_${timestamp}_$random';
    return id;
  }

  /// Get emoji for level
  static String getLevelEmoji(int levelId) {
    switch (levelId) {
      case 1:
        return '🟢';
      case 2:
        return '🟡';
      case 3:
        return '🔴';
      case 4:
        return '⭐';
      default:
        return '•';
    }
  }

  /// Get performance emoji
  static String getPerformanceEmoji(double accuracyPercentage) {
    if (accuracyPercentage >= 85) return '🌟';
    if (accuracyPercentage >= 71) return '😊';
    if (accuracyPercentage >= 51) return '😐';
    return '😕';
  }

  /// Check if student should auto-progress
  static bool shouldAutoProgress(double accuracyPercentage) {
    return accuracyPercentage >= AppConstants.autoProgressionThreshold;
  }

  /// Calculate achievement progress percentage
  static double calculateAchievementProgress({
    required int currentValue,
    required int targetValue,
  }) {
    return (currentValue / targetValue).clamp(0.0, 1.0);
  }

  /// Get level-up message
  static String getLevelUpMessage(int newLevel) {
    switch (newLevel) {
      case 2:
        return 'Great job! You unlocked Level 2!';
      case 3:
        return 'Awesome! You unlocked Level 3!';
      case 4:
        return 'Incredible! You reached Expert level!';
      default:
        return 'Congratulations on unlocking the next level!';
    }
  }

  /// Get encouragement message
  static String getEncouragementMessage(double accuracyPercentage, int streak) {
    if (streak >= 10) {
      return 'You\'re on fire! Keep it up! 🔥';
    } else if (streak >= 5) {
      return 'Great streak! You\'re doing amazing! 💪';
    } else if (accuracyPercentage >= 90) {
      return 'Excellent work! Keep practicing! ⭐';
    } else if (accuracyPercentage >= 75) {
      return 'Good job! Keep going! 👍';
    } else if (accuracyPercentage >= 60) {
      return 'Nice try! Practice makes perfect! 📚';
    } else {
      return 'Don\'t give up! You\'ll get better! 💪';
    }
  }
}
