/// Tracks consecutive correct answers and calculates streak bonuses
class StreakTracker {
  int _currentStreak = 0;
  int _longestStreak = 0;
  int _sessionStreak = 0;

  int get currentStreak => _currentStreak;
  int get longestStreak => _longestStreak;
  int get sessionStreak => _sessionStreak;

  /// Reset streaks at start of session
  void startNewSession() {
    _sessionStreak = 0;
  }

  /// Record a correct answer
  void recordCorrect() {
    _currentStreak++;
    _sessionStreak++;

    if (_currentStreak > _longestStreak) {
      _longestStreak = _currentStreak;
    }
  }

  /// Record an incorrect answer - breaks the streak
  void recordIncorrect() {
    _currentStreak = 0;
  }

  /// Get streak bonus multiplier
  double getStreakMultiplier() {
    if (_currentStreak < 2) return 1.0;
    if (_currentStreak < 5) return 1.5;
    if (_currentStreak < 10) return 2.0;
    if (_currentStreak < 25) return 2.5;
    return 3.0;
  }

  /// Calculate bonus points from streak
  int getStreakBonusPoints(int basePoints) {
    final multiplier = getStreakMultiplier();
    return ((basePoints * multiplier) - basePoints).toInt();
  }

  /// Check if streak achieved milestone
  int getStreakMilestone() {
    if (_currentStreak >= 25) return 25;
    if (_currentStreak >= 10) return 10;
    if (_currentStreak >= 5) return 5;
    if (_currentStreak >= 3) return 3;
    if (_currentStreak >= 2) return 2;
    return 0;
  }

  /// Get streak status message
  String getStreakMessage() {
    if (_currentStreak == 0) return '';
    if (_currentStreak == 2) return '2x Streak! 🔥';
    if (_currentStreak == 5) return '5x Streak! 🔥🔥';
    if (_currentStreak == 10) return '10x Streak! 🔥🔥🔥';
    if (_currentStreak == 25) return '25x Streak! 🌟';
    if (_currentStreak > 0) return '${_currentStreak}x Streak';
    return '';
  }

  /// Get streak emoji based on current streak
  String getStreakEmoji() {
    if (_currentStreak >= 25) return '🌟';
    if (_currentStreak >= 10) return '🔥';
    if (_currentStreak >= 5) return '⚡';
    if (_currentStreak >= 2) return '✨';
    return '';
  }

  /// Reset all streaks (typically on app restart)
  void reset() {
    _currentStreak = 0;
    _longestStreak = 0;
    _sessionStreak = 0;
  }

  /// Get streak statistics
  Map<String, int> getStats() {
    return {
      'current': _currentStreak,
      'longest': _longestStreak,
      'session': _sessionStreak,
    };
  }

  /// Check if current streak is record-breaking
  bool isNewRecord() {
    return _currentStreak == _longestStreak && _currentStreak > 0;
  }
}
