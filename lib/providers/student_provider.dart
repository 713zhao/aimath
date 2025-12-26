import 'package:flutter/foundation.dart';
import '../models/student_profile.dart';
import '../services/storage_service.dart';

/// Manages student profile state and provides reactive updates to UI
class StudentProvider extends ChangeNotifier {
  static final StudentProvider _instance = StudentProvider._internal();

  factory StudentProvider() {
    return _instance;
  }

  StudentProvider._internal();

  final StorageService _storageService = StorageService();
  StudentProfile? _currentStudent;
  bool _isLoading = false;
  String? _error;

  // Getters
  StudentProfile? get currentStudent => _currentStudent;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasStudent => _currentStudent != null;

  // Convenience getters
  String? get studentName => _currentStudent?.name;
  int? get studentId => int.tryParse(_currentStudent?.id ?? '');
  int? get currentLevel => _currentStudent?.currentDifficultyLevel;
  int? get totalPoints => _currentStudent?.totalPoints;
  int? get currentStreak => _currentStudent?.currentStreak;
  int? get longestStreak => _currentStudent?.longestStreak;
  int? get totalProblems => _currentStudent?.totalProblemsCompleted;
  int? get totalCorrect => _currentStudent?.totalCorrectAnswers;
  double? get overallAccuracy => _currentStudent?.overallAccuracyPercentage;
  int? get achievementCount => _currentStudent?.achievementCount;

  /// Set current student and notify listeners
  void setCurrentStudent(StudentProfile student) {
    _currentStudent = student;
    notifyListeners();
  }

  /// Load student profile by ID
  Future<void> loadStudent(String studentId) async {
    _setLoading(true);
    _error = null;

    try {
      final student = await _storageService.loadStudentProfile(studentId);
      if (student != null) {
        _currentStudent = student;
        _error = null;
        print('Student loaded: ${student.name}');
      } else {
        _error = 'Student not found: $studentId';
      }
    } catch (e) {
      _error = 'Error loading student: $e';
      print(_error);
    } finally {
      _setLoading(false);
    }
  }

  /// Calculate initial difficulty level based on age
  /// Age 6 = P1 (Level 1), Age 7 = P2 (Level 2), Age 8 = P3 (Level 3), Age 9+ = P4 (Level 4)
  int _getInitialLevelFromAge(int age) {
    if (age <= 6) return 1;  // P1
    if (age == 7) return 2;  // P2
    if (age == 8) return 3;  // P3
    return 4;                // P4 (age 9+)
  }

  /// Create a new student profile
  Future<StudentProfile?> createStudent({
    required String id,
    required String name,
    required int age,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      if (!_isValidName(name)) {
        throw Exception('Invalid name: must be 2-50 characters');
      }
      if (age < 5 || age > 18) {
        throw Exception('Invalid age: must be between 5 and 18');
      }

      // Set initial level based on age
      final initialLevel = _getInitialLevelFromAge(age);

      final student = StudentProfile(
        id: id,
        name: name,
        age: age,
        createdAt: DateTime.now(),
        lastActiveAt: DateTime.now(),
        totalPoints: 0,
        currentStreak: 0,
        longestStreak: 0,
        totalProblemsCompleted: 0,
        totalCorrectAnswers: 0,
        currentDifficultyLevel: initialLevel,
        achievementIds: [],
      );

      await _storageService.saveStudentProfile(student);
      _currentStudent = student;
      _error = null;
      notifyListeners();

      print('Student created: ${student.name}');
      return student;
    } catch (e) {
      _error = 'Error creating student: $e';
      print(_error);
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Update student points and stats after session
  Future<void> updateStudentStats({
    required int sessionPoints,
    required int sessionProblems,
    required int sessionCorrectAnswers,
    required double sessionAccuracy,
  }) async {
    if (_currentStudent == null) return;

    try {
      var updated = _currentStudent!.afterSessionCompletion(
        sessionPoints: sessionPoints,
        sessionProblems: sessionProblems,
        sessionCorrectAnswers: sessionCorrectAnswers,
      );

      // Update streak based on performance
      updated = updated.updateStreak(
        sessionCompleted: true,
        sessionAccuracy: sessionAccuracy,
      );

      _currentStudent = updated;
      await _storageService.saveStudentProfile(updated);
      notifyListeners();

      print('Student stats updated');
    } catch (e) {
      _error = 'Error updating stats: $e';
      print(_error);
    }
  }

  /// Unlock next difficulty level
  Future<void> unlockNextLevel() async {
    if (_currentStudent == null || _currentStudent!.currentDifficultyLevel >= 4) {
      return;
    }

    try {
      final updated = _currentStudent!.unlockNextLevel();
      _currentStudent = updated;
      await _storageService.saveStudentProfile(updated);
      notifyListeners();

      print('Level unlocked: ${updated.currentDifficultyLevel}');
    } catch (e) {
      _error = 'Error unlocking level: $e';
      print(_error);
    }
  }

  /// Add achievement to student
  Future<void> addAchievement(String achievementId) async {
    if (_currentStudent == null) return;
    if (_currentStudent!.achievementIds.contains(achievementId)) {
      return; // Already has this achievement
    }

    try {
      final updated = _currentStudent!.addAchievement(achievementId);
      _currentStudent = updated;
      await _storageService.saveStudentProfile(updated);
      notifyListeners();

      print('Achievement added: $achievementId');
    } catch (e) {
      _error = 'Error adding achievement: $e';
      print(_error);
    }
  }

  /// Reset student progress (dangerous operation)
  Future<void> resetProgress() async {
    if (_currentStudent == null) return;

    try {
      final reset = StudentProfile(
        id: _currentStudent!.id,
        name: _currentStudent!.name,
        age: _currentStudent!.age,
        createdAt: _currentStudent!.createdAt,
        lastActiveAt: DateTime.now(),
        totalPoints: 0,
        currentStreak: 0,
        longestStreak: 0,
        totalProblemsCompleted: 0,
        totalCorrectAnswers: 0,
        currentDifficultyLevel: 1,
        achievementIds: [],
      );

      _currentStudent = reset;
      await _storageService.saveStudentProfile(reset);
      notifyListeners();

      print('Progress reset for student');
    } catch (e) {
      _error = 'Error resetting progress: $e';
      print(_error);
    }
  }

  /// Check if student should auto-progress
  bool shouldAutoProgress(double accuracy) {
    return accuracy >= 85 && (_currentStudent?.currentDifficultyLevel ?? 0) < 4;
  }

  /// Get student level name
  String getLevelName(int level) {
    switch (level) {
      case 1:
        return 'Beginner';
      case 2:
        return 'Intermediate';
      case 3:
        return 'Advanced';
      case 4:
        return 'Expert';
      default:
        return 'Unknown';
    }
  }

  /// Save current state
  Future<void> save() async {
    if (_currentStudent == null) return;

    try {
      await _storageService.saveStudentProfile(_currentStudent!);
      print('Student profile saved');
    } catch (e) {
      _error = 'Error saving student: $e';
      print(_error);
    }
  }

  /// Validate student name
  bool _isValidName(String name) {
    return name.isNotEmpty && name.length >= 2 && name.length <= 50;
  }

  /// Internal loading state setter
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Clear current student (logout)
  void clear() {
    _currentStudent = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Get user-friendly status
  Map<String, dynamic> getStatus() {
    if (_currentStudent == null) {
      return {'status': 'no_student', 'message': 'No student loaded'};
    }

    return {
      'status': 'loaded',
      'name': _currentStudent!.name,
      'level': _currentStudent!.currentDifficultyLevel,
      'points': _currentStudent!.totalPoints,
      'accuracy': '${_currentStudent!.overallAccuracyPercentage.toStringAsFixed(1)}%',
      'streak': _currentStudent!.currentStreak,
    };
  }
}
