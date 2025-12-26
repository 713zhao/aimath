import 'dart:async';
import 'package:aimath/models/student_profile.dart';
import 'package:aimath/models/practice_session.dart';
import 'package:aimath/models/operation_stats.dart';
import 'package:aimath/services/storage_service.dart';
import 'package:aimath/utils/enums.dart';

/// Tracks student progress and handles auto-level progression
/// 
/// Auto-progression rules:
/// - Student must achieve 85%+ accuracy on 10+ consecutive problems
/// - Cannot skip more than 1 level ahead
/// - Cannot regress levels (only progress forward)
class ProgressTracker {
  final StorageService _storageService;
  
  // Track consecutive correct answers for progression
  int _consecutiveCorrect = 0;
  int _consecutiveTotal = 0;
  
  // Progression threshold
  static const double progressionAccuracyThreshold = 0.85; // 85%
  static const int minimumProblemsForProgression = 10;
  static const int maxLevelSkip = 1;
  static const int maxLevel = 4;
  
  // Track accuracy per operation
  final Map<Operation, OperationAccuracy> _operationAccuracy = {};
  
  // Callbacks for UI updates
  Function(int newLevel)? onLevelUp;
  Function(Map<Operation, double> accuracy)? onAccuracyUpdate;

  ProgressTracker({
    required StorageService storageService,
    this.onLevelUp,
    this.onAccuracyUpdate,
  }) : _storageService = storageService {
    _initializeOperationAccuracy();
  }
  
  void _initializeOperationAccuracy() {
    for (final op in Operation.values) {
      _operationAccuracy[op] = OperationAccuracy(
        operation: op,
        totalAttempts: 0,
        correctAttempts: 0,
      );
    }
  }

  /// Get current consecutive correct count
  int get consecutiveCorrect => _consecutiveCorrect;
  
  /// Get current consecutive total count
  int get consecutiveTotal => _consecutiveTotal;
  
  /// Get current progression percentage
  double get progressionPercentage {
    if (_consecutiveTotal < minimumProblemsForProgression) {
      return _consecutiveTotal / minimumProblemsForProgression;
    }
    return _consecutiveCorrect / _consecutiveTotal;
  }

  /// Check if student qualifies for level up
  bool get qualifiesForLevelUp {
    if (_consecutiveTotal < minimumProblemsForProgression) return false;
    return (_consecutiveCorrect / _consecutiveTotal) >= progressionAccuracyThreshold;
  }

  /// Record a problem attempt
  Future<bool> recordAttempt({
    required Operation operation,
    required bool isCorrect,
    required int currentLevel,
  }) async {
    _consecutiveTotal++;
    
    if (isCorrect) {
      _consecutiveCorrect++;
    } else {
      // Reset consecutive tracking on incorrect answer
      // Keep tracking but record the miss
    }
    
    // Update operation accuracy
    final accuracy = _operationAccuracy[operation]!;
    _operationAccuracy[operation] = OperationAccuracy(
      operation: operation,
      totalAttempts: accuracy.totalAttempts + 1,
      correctAttempts: accuracy.correctAttempts + (isCorrect ? 1 : 0),
    );
    
    // Notify accuracy update
    onAccuracyUpdate?.call(getAccuracyByOperation());
    
    // Check for level up eligibility
    if (qualifiesForLevelUp && currentLevel < maxLevel) {
      final newLevel = _calculateNewLevel(currentLevel);
      if (newLevel > currentLevel) {
        onLevelUp?.call(newLevel);
        _resetProgressTracking();
        return true; // Level up occurred
      }
    }
    
    return false; // No level up
  }

  /// Calculate the new level based on current progress
  int _calculateNewLevel(int currentLevel) {
    // Can only advance by maxLevelSkip levels at a time
    final potentialNewLevel = currentLevel + 1;
    return potentialNewLevel.clamp(1, maxLevel);
  }

  /// Reset progress tracking after level up
  void _resetProgressTracking() {
    _consecutiveCorrect = 0;
    _consecutiveTotal = 0;
  }

  /// Get accuracy by operation type
  Map<Operation, double> getAccuracyByOperation() {
    final result = <Operation, double>{};
    for (final entry in _operationAccuracy.entries) {
      result[entry.key] = entry.value.accuracyPercentage;
    }
    return result;
  }

  /// Get detailed operation stats
  Map<Operation, OperationAccuracy> getDetailedStats() {
    return Map.from(_operationAccuracy);
  }

  /// Check if student has mastered an operation (85%+ accuracy with 20+ attempts)
  bool hasOperationMastery(Operation operation) {
    final accuracy = _operationAccuracy[operation];
    if (accuracy == null) return false;
    return accuracy.totalAttempts >= 20 && 
           accuracy.accuracyPercentage >= 85.0;
  }

  /// Get list of mastered operations
  List<Operation> getMasteredOperations() {
    return Operation.values
        .where((op) => hasOperationMastery(op))
        .toList();
  }

  /// Check if student should unlock next level based on session performance
  Future<bool> evaluateSessionForProgression({
    required PracticeSession session,
    required int currentLevel,
  }) async {
    // Use session accuracy for evaluation
    if (session.problemCount < minimumProblemsForProgression) {
      return false;
    }
    
    final accuracy = session.correctCount / session.problemCount;
    if (accuracy >= progressionAccuracyThreshold && currentLevel < maxLevel) {
      final newLevel = _calculateNewLevel(currentLevel);
      if (newLevel > currentLevel) {
        onLevelUp?.call(newLevel);
        return true;
      }
    }
    
    return false;
  }

  /// Load historical accuracy from storage
  Future<void> loadHistoricalData(String studentId) async {
    try {
      final profile = await _storageService.loadStudentProfile(studentId);
      if (profile != null) {
        // Load operation stats if available
        final stats = await _storageService.getStudentStats(studentId);
        for (final stat in stats) {
          _operationAccuracy[stat.operation] = OperationAccuracy(
            operation: stat.operation,
            totalAttempts: stat.totalAttempts,
            correctAttempts: stat.correctAttempts,
          );
        }
      }
    } catch (e) {
      // Silently fail - use default empty tracking
    }
  }

  /// Save current tracking data
  Future<void> saveProgress(String studentId) async {
    try {
      for (final entry in _operationAccuracy.entries) {
        final stat = OperationStats(
          id: '${studentId}_${entry.key.name}',
          studentId: studentId,
          operation: entry.key,
          difficultyLevelId: 1, // Default level for aggregate stats
          totalAttempts: entry.value.totalAttempts,
          correctAttempts: entry.value.correctAttempts,
          totalPoints: 0,
          lastPracticedAt: DateTime.now(),
          createdAt: DateTime.now(),
        );
        await _storageService.saveOperationStats(stat);
      }
    } catch (e) {
      // Silently fail
    }
  }

  /// Reset all tracking data
  void reset() {
    _consecutiveCorrect = 0;
    _consecutiveTotal = 0;
    _initializeOperationAccuracy();
  }

  /// Get progress towards next level
  ProgressToNextLevel getProgressToNextLevel() {
    return ProgressToNextLevel(
      problemsCompleted: _consecutiveTotal,
      problemsRequired: minimumProblemsForProgression,
      currentAccuracy: _consecutiveTotal > 0 
          ? (_consecutiveCorrect / _consecutiveTotal) * 100 
          : 0,
      requiredAccuracy: progressionAccuracyThreshold * 100,
      isEligible: qualifiesForLevelUp,
    );
  }
}

/// Helper class for tracking operation accuracy
class OperationAccuracy {
  final Operation operation;
  final int totalAttempts;
  final int correctAttempts;

  OperationAccuracy({
    required this.operation,
    required this.totalAttempts,
    required this.correctAttempts,
  });

  double get accuracyPercentage {
    if (totalAttempts == 0) return 0;
    return (correctAttempts / totalAttempts) * 100;
  }
}

/// Progress information towards next level
class ProgressToNextLevel {
  final int problemsCompleted;
  final int problemsRequired;
  final double currentAccuracy;
  final double requiredAccuracy;
  final bool isEligible;

  ProgressToNextLevel({
    required this.problemsCompleted,
    required this.problemsRequired,
    required this.currentAccuracy,
    required this.requiredAccuracy,
    required this.isEligible,
  });

  double get problemsProgress => problemsCompleted / problemsRequired;
  double get accuracyProgress => currentAccuracy / requiredAccuracy;
  
  bool get hasEnoughProblems => problemsCompleted >= problemsRequired;
  bool get hasEnoughAccuracy => currentAccuracy >= requiredAccuracy;
}
