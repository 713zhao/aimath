import 'dart:async';
import '../config/difficulty_config.dart';
import '../models/math_problem.dart';
import '../models/practice_session.dart';
import '../models/problem_attempt.dart';
import '../utils/enums.dart';
import 'problem_generator.dart';
import 'streak_tracker.dart';

/// Main controller for game logic and practice session management
class GameController {
  // Session data
  late String _studentId;
  late int _difficultyLevel;
  late List<Operation> _selectedOperations;
  late List<MathProblem> _sessionProblems;
  late List<ProblemAttempt> _sessionAttempts;
  late StreakTracker _streakTracker;
  
  int _currentProblemIndex = 0;
  int _totalSessionPoints = 0;
  bool _sessionActive = false;

  // Timing
  late Stopwatch _sessionTimer;
  late Timer _problemTimer;
  int _secondsRemaining = 0;
  final int _problemTimeLimit = 120; // 2 minutes per problem

  // Callbacks
  Function()? _onSessionStarted;
  Function()? _onSessionEnded;
  Function(MathProblem)? _onNewProblem;
  Function(int)? _onTimeUpdate;
  Function(bool, int)? _onAnswerSubmitted;
  Function(Map<String, dynamic>)? _onSessionSummary;

  bool get isSessionActive => _sessionActive;
  bool get hasMoreProblems => _currentProblemIndex < _sessionProblems.length;
  int get currentProblemIndex => _currentProblemIndex;
  int get totalProblems => _sessionProblems.length;
  List<Operation> get selectedOperations => _selectedOperations;
  String get studentId => _studentId;
  MathProblem? get currentProblem {
    if (_currentProblemIndex < _sessionProblems.length) {
      return _sessionProblems[_currentProblemIndex];
    }
    return null;
  }

  int get sessionPoints => _totalSessionPoints;
  int get secondsRemaining => _secondsRemaining;
  bool get isTimeWarning => _secondsRemaining <= 30 && _secondsRemaining > 0;

  /// Initialize a new practice session
  void initializeSession({
    required String studentId,
    required int difficultyLevel,
    required List<Operation> selectedOperations,
  }) {
    _studentId = studentId;
    _difficultyLevel = difficultyLevel;
    _selectedOperations = selectedOperations;
    
    // Generate problems for the session
    _sessionProblems = ProblemGenerator.generateSessionProblems(
      difficultyLevelId: difficultyLevel,
      operations: selectedOperations,
      problemCount: DifficultyConfig.problemsPerSession,
    );

    _sessionAttempts = [];
    _streakTracker = StreakTracker();
    _currentProblemIndex = 0;
    _totalSessionPoints = 0;
    _sessionTimer = Stopwatch();
  }

  /// Start the practice session
  void startSession() {
    if (_sessionProblems.isEmpty) {
      throw Exception('Session not initialized. Call initializeSession first.');
    }

    _sessionActive = true;
    _sessionTimer.start();
    _onSessionStarted?.call();
    
    // Load first problem
    _loadNextProblem();
  }

  /// Load the next problem and start timer
  void _loadNextProblem() {
    if (!hasMoreProblems) {
      endSession();
      return;
    }

    _secondsRemaining = _problemTimeLimit;
    _startProblemTimer();
    _onNewProblem?.call(currentProblem!);
  }

  /// Start countdown timer for current problem
  void _startProblemTimer() {
    _problemTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      _secondsRemaining--;
      _onTimeUpdate?.call(_secondsRemaining);

      if (_secondsRemaining <= 0) {
        _problemTimer.cancel();
        // Auto-submit with wrong answer (0) on timeout
        submitAnswer(0, isTimeout: true);
      }
    });
  }

  /// Submit an answer for the current problem
  Future<void> submitAnswer(int userAnswer, {bool isTimeout = false}) async {
    if (!_sessionActive || currentProblem == null) return;

    _problemTimer.cancel();
    
    final problem = currentProblem!;
    final isCorrect = problem.isAnswerCorrect(userAnswer);
    final timeSpent = _problemTimeLimit - _secondsRemaining;

    // Create attempt record
    final attempt = ProblemAttempt(
      id: _generateId('attempt'),
      problemId: problem.id,
      sessionId: _generateId('session'), // Will be replaced when saving
      userAnswer: userAnswer,
      correctAnswer: problem.correctAnswer,
      timeSpentSeconds: timeSpent,
      attemptedAt: DateTime.now(),
    );

    _sessionAttempts.add(attempt);

    // Update streak
    if (isCorrect) {
      _streakTracker.recordCorrect();
    } else {
      _streakTracker.recordIncorrect();
    }

    // Calculate points
    int pointsEarned = 0;
    if (isCorrect) {
      final difficulty = DifficultyConfig.getLevelById(_difficultyLevel);
      pointsEarned = difficulty?.pointsPerCorrect ?? 10;

      // Add time bonus
      if (timeSpent <= 5) {
        pointsEarned = (pointsEarned * 1.5).toInt();
      } else if (timeSpent <= 10) {
        pointsEarned = (pointsEarned * 1.25).toInt();
      }

      // Apply streak bonus
      pointsEarned = (pointsEarned * _streakTracker.getStreakMultiplier()).toInt();
    }

    _totalSessionPoints += pointsEarned;

    // Notify about answer
    _onAnswerSubmitted?.call(isCorrect, pointsEarned);

    // Move to next problem or end session
    await Future.delayed(Duration(milliseconds: 500));
    _currentProblemIndex++;

    if (hasMoreProblems) {
      _loadNextProblem();
    } else {
      endSession();
    }
  }

  /// End the practice session
  void endSession() {
    _sessionActive = false;
    _sessionTimer.stop();
    _problemTimer.cancel();

    // Calculate final statistics
    final correctAnswers = _sessionAttempts.where((a) => a.isCorrect).length;
    final accuracy = (correctAnswers / _sessionAttempts.length) * 100;

    final summary = {
      'totalProblems': _sessionProblems.length,
      'correctAnswers': correctAnswers,
      'totalPoints': _totalSessionPoints,
      'accuracy': accuracy,
      'durationSeconds': _sessionTimer.elapsed.inSeconds,
      'currentStreak': _streakTracker.currentStreak,
      'longestStreak': _streakTracker.longestStreak,
      'attempts': _sessionAttempts,
      'shouldAutoProgress': accuracy >= DifficultyConfig.autoProgressionThreshold,
    };

    _onSessionSummary?.call(summary);
    _onSessionEnded?.call();
  }

  /// Get current session summary
  Map<String, dynamic> getSessionSummary() {
    if (_sessionAttempts.isEmpty) {
      return {};
    }

    final correctAnswers = _sessionAttempts.where((a) => a.isCorrect).length;
    final accuracy = (correctAnswers / _sessionAttempts.length) * 100;
    final duration = _sessionTimer.elapsed.inSeconds;

    return {
      'totalProblems': _sessionProblems.length,
      'correctAnswers': correctAnswers,
      'totalPoints': _totalSessionPoints,
      'accuracy': accuracy,
      'durationSeconds': duration,
      'averageTimePerProblem': duration / _sessionProblems.length,
      'currentStreak': _streakTracker.currentStreak,
      'longestStreak': _streakTracker.longestStreak,
      'performanceLevel': _getPerformanceLevel(accuracy),
    };
  }

  /// Skip current problem (counts as incorrect)
  Future<void> skipProblem() async {
    await submitAnswer(0, isTimeout: true);
  }

  /// Cancel the session
  void cancelSession() {
    _sessionActive = false;
    _sessionTimer.stop();
    _problemTimer.cancel();
    ProblemGenerator.clearSession();
  }

  /// Register callback for session started
  void onSessionStarted(Function() callback) {
    _onSessionStarted = callback;
  }

  /// Register callback for session ended
  void onSessionEnded(Function() callback) {
    _onSessionEnded = callback;
  }

  /// Register callback for new problem
  void onNewProblem(Function(MathProblem) callback) {
    _onNewProblem = callback;
  }

  /// Register callback for time update
  void onTimeUpdate(Function(int) callback) {
    _onTimeUpdate = callback;
  }

  /// Register callback for answer submitted
  void onAnswerSubmitted(Function(bool, int) callback) {
    _onAnswerSubmitted = callback;
  }

  /// Register callback for session summary
  void onSessionSummary(Function(Map<String, dynamic>) callback) {
    _onSessionSummary = callback;
  }

  /// Get performance level based on accuracy
  String _getPerformanceLevel(double accuracy) {
    if (accuracy >= 85) return 'Excellent';
    if (accuracy >= 71) return 'Good';
    if (accuracy >= 51) return 'Average';
    return 'Poor';
  }

  /// Generate unique ID
  String _generateId(String prefix) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${prefix}_$timestamp';
  }

  /// Get session details for saving
  PracticeSession createSessionRecord(String sessionId, String studentId) {
    final correctAnswers = _sessionAttempts.where((a) => a.isCorrect).length;
    final accuracy = _sessionAttempts.isEmpty 
        ? 0.0 
        : (correctAnswers / _sessionAttempts.length) * 100;

    return PracticeSession(
      id: sessionId,
      studentId: studentId,
      difficultyLevelId: _difficultyLevel,
      problemIds: _sessionProblems.map((p) => p.id).toList(),
      attemptIds: _sessionAttempts.map((a) => a.id).toList(),
      totalPoints: _totalSessionPoints,
      accuracyPercentage: accuracy,
      startedAt: DateTime.now().subtract(_sessionTimer.elapsed),
      completedAt: DateTime.now(),
    );
  }

  /// Get all session attempts
  List<ProblemAttempt> getAttempts() => _sessionAttempts;

  /// Dispose resources
  void dispose() {
    _problemTimer.cancel();
    _sessionTimer.stop();
    ProblemGenerator.clearSession();
  }
}
