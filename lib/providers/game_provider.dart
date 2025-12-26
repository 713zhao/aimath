import 'package:flutter/foundation.dart';
import '../controllers/game_controller.dart';
import '../models/math_problem.dart';
import '../models/practice_session.dart';
import '../models/problem_attempt.dart';
import '../utils/enums.dart';
import '../services/storage_service.dart';

/// Manages game session state and provides reactive updates to UI
class GameProvider extends ChangeNotifier {
  static final GameProvider _instance = GameProvider._internal();

  factory GameProvider() {
    return _instance;
  }

  GameProvider._internal();

  final GameController _gameController = GameController();
  final StorageService _storageService = StorageService();

  PracticeSession? _currentSession;
  MathProblem? _currentProblem;
  bool _isSessionActive = false;
  int _secondsRemaining = 0;
  int _currentStreak = 0;
  int _sessionPoints = 0;

  // Getters
  bool get isSessionActive => _isSessionActive;
  MathProblem? get currentProblem => _currentProblem;
  PracticeSession? get currentSession => _currentSession;
  int get secondsRemaining => _secondsRemaining;
  int get currentStreak => _currentStreak;
  int get sessionPoints => _sessionPoints;
  int get currentProblemIndex => _gameController.currentProblemIndex + 1;
  int get totalProblems => _gameController.totalProblems;

  // Convenience getters
  bool get hasCurrentProblem => _currentProblem != null;
  bool get isTimeWarning => _secondsRemaining <= 30 && _secondsRemaining > 0;
  bool get isTimeCritical => _secondsRemaining <= 5;
  double get progressPercentage {
    if (totalProblems == 0) return 0;
    return currentProblemIndex / totalProblems;
  }

  String get problemDisplay => _currentProblem?.displayEquation ?? '';

  /// Initialize and start a new practice session
  Future<void> startNewSession({
    required String studentId,
    required int difficultyLevel,
    required List<Operation> selectedOperations,
  }) async {
    try {
      // Initialize game controller
      _gameController.initializeSession(
        studentId: studentId,
        difficultyLevel: difficultyLevel,
        selectedOperations: selectedOperations,
      );

      // Set up callbacks
      _setupGameControllerCallbacks();

      // Start the session
      _gameController.startSession();

      _isSessionActive = true;
      notifyListeners();
    } catch (e) {
      print('Error starting session: $e');
    }
  }

  /// Set up all game controller callbacks
  void _setupGameControllerCallbacks() {
    _gameController.onSessionStarted(() {
      _isSessionActive = true;
      notifyListeners();
    });

    _gameController.onNewProblem((problem) {
      _currentProblem = problem;
      _secondsRemaining = _gameController.secondsRemaining;
      notifyListeners();
    });

    _gameController.onTimeUpdate((seconds) {
      _secondsRemaining = seconds;
      notifyListeners();
    });

    _gameController.onAnswerSubmitted((isCorrect, points) {
      if (isCorrect) {
        _currentStreak++;
      } else {
        _currentStreak = 0;
      }
      _sessionPoints += points;
      notifyListeners();
    });

    _gameController.onSessionEnded(() {
      _isSessionActive = false;
      _currentProblem = null;
      notifyListeners();
    });
  }

  /// Submit an answer for the current problem
  Future<void> submitAnswer(int userAnswer) async {
    await _gameController.submitAnswer(userAnswer);
  }

  /// Skip the current problem
  Future<void> skipProblem() async {
    await _gameController.skipProblem();
  }

  /// End the current session
  Future<Map<String, dynamic>?> endSession(String studentId) async {
    try {
      _gameController.endSession();
      
      // Get session summary
      final summary = _gameController.getSessionSummary();
      
      // Create session record
      final sessionId = _generateId('session');
      final session = _gameController.createSessionRecord(sessionId, studentId);
      
      // Save session and attempts
      await _storageService.savePracticeSession(session);
      
      final attempts = _gameController.getAttempts();
      for (final attempt in attempts) {
        final updatedAttempt = attempt.copyWith(sessionId: sessionId);
        await _storageService.saveProblemAttempt(updatedAttempt);
      }

      _currentSession = session;
      _isSessionActive = false;
      notifyListeners();

      return summary;
    } catch (e) {
      print('Error ending session: $e');
      return null;
    }
  }

  /// Cancel the current session without saving
  void cancelSession() {
    _gameController.cancelSession();
    _isSessionActive = false;
    _currentProblem = null;
    _currentStreak = 0;
    _sessionPoints = 0;
    _secondsRemaining = 0;
    notifyListeners();
  }

  /// Get current session summary
  Map<String, dynamic> getSessionSummary() {
    return _gameController.getSessionSummary();
  }

  /// Load previous session results
  Future<PracticeSession?> loadSession(String sessionId) async {
    try {
      final session = await _storageService.loadPracticeSession(sessionId);
      if (session != null) {
        _currentSession = session;
        notifyListeners();
      }
      return session;
    } catch (e) {
      print('Error loading session: $e');
      return null;
    }
  }

  /// Get attempts for a session
  Future<List<ProblemAttempt>> getSessionAttempts(String sessionId) async {
    try {
      return await _storageService.getSessionAttempts(sessionId);
    } catch (e) {
      print('Error getting attempts: $e');
      return [];
    }
  }

  /// Check if session qualifies for level up
  bool shouldLevelUp(double accuracy) {
    return accuracy >= 85 && totalProblems >= 10;
  }

  /// Get performance feedback
  String getPerformanceFeedback(double accuracy) {
    if (accuracy >= 90) return 'Outstanding! 🌟';
    if (accuracy >= 80) return 'Excellent work! ⭐';
    if (accuracy >= 70) return 'Great job! 👍';
    if (accuracy >= 60) return 'Good effort! 💪';
    return 'Keep practicing! 📚';
  }

  /// Get streak milestone message
  String getStreakMessage() {
    if (_currentStreak >= 10) return '🔥 Amazing Streak! 🔥';
    if (_currentStreak >= 5) return '🔥 Great Streak! 🔥';
    if (_currentStreak >= 3) return '✨ Nice Streak!';
    if (_currentStreak >= 1) return '👍 Good Going!';
    return '';
  }

  /// Get emoji based on streak length
  String getStreakEmoji() {
    if (_currentStreak >= 25) return '🌟';
    if (_currentStreak >= 10) return '🔥';
    if (_currentStreak >= 5) return '⚡';
    if (_currentStreak >= 2) return '✨';
    return '';
  }

  /// Reset session state
  void resetSession() {
    _currentSession = null;
    _currentProblem = null;
    _isSessionActive = false;
    _secondsRemaining = 0;
    _currentStreak = 0;
    _sessionPoints = 0;
    notifyListeners();
  }

  /// Get game status for debugging
  Map<String, dynamic> getStatus() {
    return {
      'isActive': _isSessionActive,
      'currentProblem': _currentProblem?.displayEquation,
      'streak': _currentStreak,
      'points': _sessionPoints,
      'timeRemaining': _secondsRemaining,
      'progress': '$currentProblemIndex/$totalProblems',
    };
  }

  /// Generate unique ID
  String _generateId(String prefix) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${prefix}_$timestamp';
  }

  @override
  void dispose() {
    _gameController.dispose();
    super.dispose();
  }
}
