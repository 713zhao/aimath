import 'package:flutter/foundation.dart';
import '../models/operation_stats.dart';
import '../models/practice_session.dart';
import '../utils/enums.dart';
import '../services/storage_service.dart';

/// Manages statistics and analytics state
class StatisticsProvider extends ChangeNotifier {
  static final StatisticsProvider _instance = StatisticsProvider._internal();

  factory StatisticsProvider() {
    return _instance;
  }

  StatisticsProvider._internal();

  final StorageService _storageService = StorageService();

  List<OperationStats> _studentStats = [];
  List<PracticeSession> _studentSessions = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<OperationStats> get studentStats => _studentStats;
  List<PracticeSession> get studentSessions => _studentSessions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load all statistics for a student
  Future<void> loadStudentStats(String studentId) async {
    _setLoading(true);
    _error = null;

    try {
      _studentStats = await _storageService.getStudentStats(studentId);
      _studentSessions = await _storageService.getPracticeSessions(studentId);
      print('Loaded ${_studentStats.length} stat records and ${_studentSessions.length} sessions');
    } catch (e) {
      _error = 'Error loading statistics: $e';
      print(_error);
    } finally {
      _setLoading(false);
    }
  }

  /// Get or create stats for an operation/level
  Future<OperationStats> getOrCreateStats({
    required String studentId,
    required Operation operation,
    required int difficultyLevelId,
  }) async {
    try {
      var stats = await _storageService.getOperationStats(
        studentId: studentId,
        operation: operation.toString().split('.').last,
        difficultyLevelId: difficultyLevelId,
      );

      if (stats == null) {
        stats = OperationStats(
          id: _generateId('stats'),
          studentId: studentId,
          operation: operation,
          difficultyLevelId: difficultyLevelId,
          totalAttempts: 0,
          correctAttempts: 0,
          totalPoints: 0,
          lastPracticedAt: DateTime.now(),
          createdAt: DateTime.now(),
        );
        
        await _storageService.saveOperationStats(stats);
        _studentStats.add(stats);
        notifyListeners();
      }

      return stats;
    } catch (e) {
      print('Error getting stats: $e');
      rethrow;
    }
  }

  /// Update stats after session
  Future<void> updateStatsAfterSession({
    required String studentId,
    required List<Map<String, dynamic>> attempts,
    required int difficultyLevelId,
  }) async {
    try {
      // Group attempts by operation
      final Map<String, List<Map<String, dynamic>>> byOperation = {};
      
      for (final attempt in attempts) {
        final operation = attempt['operation'] as String;
        byOperation.putIfAbsent(operation, () => []).add(attempt);
      }

      // Update stats for each operation
      for (final entry in byOperation.entries) {
        final operation = Operation.values.firstWhere(
          (op) => op.toString().split('.').last == entry.key,
        );
        
        var stats = await getOrCreateStats(
          studentId: studentId,
          operation: operation,
          difficultyLevelId: difficultyLevelId,
        );

        int correctCount = 0;
        int pointsEarned = 0;

        for (final attempt in entry.value) {
          if (attempt['isCorrect'] as bool) {
            correctCount++;
          }
          pointsEarned += attempt['points'] as int? ?? 0;
        }

        stats = stats.copyWith(
          totalAttempts: stats.totalAttempts + entry.value.length,
          correctAttempts: stats.correctAttempts + correctCount,
          totalPoints: stats.totalPoints + pointsEarned,
          lastPracticedAt: DateTime.now(),
        );

        await _storageService.saveOperationStats(stats);
      }

      // Reload to reflect changes
      await loadStudentStats(studentId);
    } catch (e) {
      _error = 'Error updating stats: $e';
      print(_error);
    }
  }

  /// Get accuracy for a specific operation across all levels
  double getOperationAccuracy(Operation operation) {
    final opStats = _studentStats
        .where((s) => s.operation == operation)
        .toList();

    if (opStats.isEmpty) return 0;

    int totalAttempts = 0;
    int totalCorrect = 0;

    for (final stat in opStats) {
      totalAttempts += stat.totalAttempts;
      totalCorrect += stat.correctAttempts;
    }

    if (totalAttempts == 0) return 0;
    return (totalCorrect / totalAttempts) * 100;
  }

  /// Get accuracy for a specific level across all operations
  double getLevelAccuracy(int levelId) {
    final levelStats = _studentStats
        .where((s) => s.difficultyLevelId == levelId)
        .toList();

    if (levelStats.isEmpty) return 0;

    int totalAttempts = 0;
    int totalCorrect = 0;

    for (final stat in levelStats) {
      totalAttempts += stat.totalAttempts;
      totalCorrect += stat.correctAttempts;
    }

    if (totalAttempts == 0) return 0;
    return (totalCorrect / totalAttempts) * 100;
  }

  /// Get statistics breakdown for UI display
  Map<String, double> getAccuracyBreakdown() {
    return {
      'addition': getOperationAccuracy(Operation.add),
      'subtraction': getOperationAccuracy(Operation.subtract),
      'multiplication': getOperationAccuracy(Operation.multiply),
      'division': getOperationAccuracy(Operation.divide),
    };
  }

  /// Get total statistics
  Map<String, int> getTotalStats() {
    int totalAttempts = 0;
    int totalCorrect = 0;
    int totalPoints = 0;

    for (final stat in _studentStats) {
      totalAttempts += stat.totalAttempts;
      totalCorrect += stat.correctAttempts;
      totalPoints += stat.totalPoints;
    }

    return {
      'totalAttempts': totalAttempts,
      'totalCorrect': totalCorrect,
      'totalPoints': totalPoints,
      'sessions': _studentSessions.length,
    };
  }

  /// Get statistics for a specific operation/level
  OperationStats? getStats({
    required Operation operation,
    required int levelId,
  }) {
    try {
      return _studentStats.firstWhere(
        (s) => s.operation == operation && s.difficultyLevelId == levelId,
      );
    } catch (e) {
      return null;
    }
  }

  /// Get list of mastered operations at a level
  List<Operation> getMasteredOperations(int levelId) {
    return _studentStats
        .where((s) => s.difficultyLevelId == levelId && s.isMastered)
        .map((s) => s.operation)
        .toList();
  }

  /// Get list of operations needing practice at a level
  List<Operation> getNeedsPracticeOperations(int levelId) {
    return _studentStats
        .where((s) => s.difficultyLevelId == levelId && !s.isMastered && s.totalAttempts > 0)
        .map((s) => s.operation)
        .toList();
  }

  /// Calculate average accuracy
  double getAverageAccuracy() {
    if (_studentStats.isEmpty) return 0;

    int totalAttempts = 0;
    int totalCorrect = 0;

    for (final stat in _studentStats) {
      totalAttempts += stat.totalAttempts;
      totalCorrect += stat.correctAttempts;
    }

    if (totalAttempts == 0) return 0;
    return (totalCorrect / totalAttempts) * 100;
  }

  /// Get best performance metric
  String getBestPerformance() {
    if (_studentStats.isEmpty) return 'No data yet';

    final best = _studentStats
        .where((s) => s.totalAttempts > 0)
        .reduce((a, b) => a.accuracyPercentage > b.accuracyPercentage ? a : b);

    return '${best.operation.symbol} (${best.accuracyPercentage.toStringAsFixed(1)}%)';
  }

  /// Get area needing most practice
  String getAreaNeedingPractice() {
    if (_studentStats.isEmpty) return 'No data yet';

    final worst = _studentStats
        .where((s) => s.totalAttempts > 0)
        .reduce((a, b) => a.accuracyPercentage < b.accuracyPercentage ? a : b);

    return '${worst.operation.symbol} Level ${worst.difficultyLevelId}';
  }

  /// Get streak information
  Map<String, int> getSessionStats() {
    int longestSession = 0;
    int averageAccuracy = 0;
    int bestAccuracy = 0;
    
    for (final session in _studentSessions) {
      if (session.problemCount > longestSession) {
        longestSession = session.problemCount;
      }
      if (session.accuracyPercentage > bestAccuracy) {
        bestAccuracy = session.accuracyPercentage.toInt();
      }
    }

    averageAccuracy = _studentSessions.isEmpty
        ? 0
        : (_studentSessions.fold<double>(0, (sum, s) => sum + s.accuracyPercentage) /
                _studentSessions.length)
            .toInt();

    return {
      'totalSessions': _studentSessions.length,
      'longestSession': longestSession,
      'averageAccuracy': averageAccuracy,
      'bestAccuracy': bestAccuracy,
    };
  }

  /// Get progress trend (improvement or decline)
  String getProgressTrend() {
    if (_studentSessions.length < 2) return 'Insufficient data';

    final recent = _studentSessions.take(5).toList();
    if (recent.length < 2) return 'Insufficient data';

    final oldest = recent.last.accuracyPercentage;
    final newest = recent.first.accuracyPercentage;
    final difference = newest - oldest;

    if (difference > 10) return '📈 Great improvement!';
    if (difference > 0) return '📈 Improving';
    if (difference < -10) return '📉 Needs attention';
    if (difference < 0) return '📉 Declining';
    return '➡️ Stable';
  }

  /// Clear statistics (reset all data)
  Future<void> clearStatistics(String studentId) async {
    try {
      _studentStats.clear();
      _studentSessions.clear();
      notifyListeners();
      print('Statistics cleared');
    } catch (e) {
      _error = 'Error clearing statistics: $e';
      print(_error);
    }
  }

  /// Internal loading state setter
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Generate unique ID
  String _generateId(String prefix) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${prefix}_$timestamp';
  }

  /// Get provider status for debugging
  Map<String, dynamic> getStatus() {
    return {
      'statsLoaded': _studentStats.length,
      'sessionsLoaded': _studentSessions.length,
      'averageAccuracy': '${getAverageAccuracy().toStringAsFixed(1)}%',
      'bestOperation': getBestPerformance(),
      'needsPractice': getAreaNeedingPractice(),
    };
  }
}
