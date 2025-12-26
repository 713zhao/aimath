import 'package:hive_flutter/hive_flutter.dart';
import '../models/student_profile.dart';
import '../models/practice_session.dart';
import '../models/problem_attempt.dart';
import '../models/achievement.dart';
import '../models/operation_stats.dart';

/// Service for managing local data persistence using Hive
/// Implements singleton pattern for single instance across app
class StorageService {
  static final StorageService _instance = StorageService._internal();

  factory StorageService() {
    return _instance;
  }

  StorageService._internal();

  // Box names for organized data storage
  static const String _studentProfileBox = 'student_profiles';
  static const String _practiceSessions = 'practice_sessions';
  static const String _problemAttempts = 'problem_attempts';
  static const String _achievements = 'achievements';
  static const String _operationStats = 'operation_stats';
  static const String _backupBox = 'backup_data';

  // Lazy-initialized boxes
  late Box<Map> _studentBox;
  late Box<Map> _sessionBox;
  late Box<Map> _attemptBox;
  late Box<Map> _achievementBox;
  late Box<Map> _statsBox;
  late Box<Map> _backupBoxRef;

  bool _isInitialized = false;

  /// Initialize storage service - call this during app startup
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Open boxes
      _studentBox = await Hive.openBox<Map>(_studentProfileBox);
      _sessionBox = await Hive.openBox<Map>(_practiceSessions);
      _attemptBox = await Hive.openBox<Map>(_problemAttempts);
      _achievementBox = await Hive.openBox<Map>(_achievements);
      _statsBox = await Hive.openBox<Map>(_operationStats);
      _backupBoxRef = await Hive.openBox<Map>(_backupBox);

      _isInitialized = true;
      print('StorageService initialized successfully');
    } catch (e) {
      print('Error initializing StorageService: $e');
      rethrow;
    }
  }

  /// Verify service is initialized
  void _checkInitialized() {
    if (!_isInitialized) {
      throw Exception('StorageService not initialized. Call initialize() first.');
    }
  }

  // ==================== Student Profile Operations ====================

  /// Save or update a student profile
  Future<void> saveStudentProfile(StudentProfile profile) async {
    _checkInitialized();
    try {
      final jsonData = profile.toJson();
      await _studentBox.put(profile.id, jsonData);
      print('Saved student profile: ${profile.id}');
    } catch (e) {
      print('Error saving student profile: $e');
      rethrow;
    }
  }

  /// Load a student profile by ID
  Future<StudentProfile?> loadStudentProfile(String studentId) async {
    _checkInitialized();
    try {
      final data = _studentBox.get(studentId);
      if (data == null) return null;

      final jsonData = Map<String, dynamic>.from(data);
      return StudentProfile.fromJson(jsonData);
    } catch (e) {
      print('Error loading student profile: $e');
      return null;
    }
  }

  /// Get all student profiles
  Future<List<StudentProfile>> getAllStudents() async {
    _checkInitialized();
    try {
      final profiles = <StudentProfile>[];
      for (final data in _studentBox.values) {
        try {
          final jsonData = Map<String, dynamic>.from(data);
          profiles.add(StudentProfile.fromJson(jsonData));
        } catch (e) {
          print('Error parsing student profile: $e');
        }
      }
      return profiles;
    } catch (e) {
      print('Error getting all students: $e');
      return [];
    }
  }

  /// Delete a student profile
  Future<void> deleteStudentProfile(String studentId) async {
    _checkInitialized();
    try {
      await _studentBox.delete(studentId);
      print('Deleted student profile: $studentId');
    } catch (e) {
      print('Error deleting student profile: $e');
      rethrow;
    }
  }

  // ==================== Practice Session Operations ====================

  /// Save a practice session
  Future<void> savePracticeSession(PracticeSession session) async {
    _checkInitialized();
    try {
      final jsonData = session.toJson();
      await _sessionBox.put(session.id, jsonData);
      print('Saved practice session: ${session.id}');
    } catch (e) {
      print('Error saving practice session: $e');
      rethrow;
    }
  }

  /// Load a practice session by ID
  Future<PracticeSession?> loadPracticeSession(String sessionId) async {
    _checkInitialized();
    try {
      final data = _sessionBox.get(sessionId);
      if (data == null) return null;

      final jsonData = Map<String, dynamic>.from(data);
      return PracticeSession.fromJson(jsonData);
    } catch (e) {
      print('Error loading practice session: $e');
      return null;
    }
  }

  /// Get all sessions for a student
  Future<List<PracticeSession>> getPracticeSessions(String studentId) async {
    _checkInitialized();
    try {
      final sessions = <PracticeSession>[];
      for (final data in _sessionBox.values) {
        try {
          final jsonData = Map<String, dynamic>.from(data);
          final session = PracticeSession.fromJson(jsonData);
          if (session.studentId == studentId) {
            sessions.add(session);
          }
        } catch (e) {
          print('Error parsing practice session: $e');
        }
      }
      // Sort by date, newest first
      sessions.sort((a, b) => b.startedAt.compareTo(a.startedAt));
      return sessions;
    } catch (e) {
      print('Error getting practice sessions: $e');
      return [];
    }
  }

  /// Get completed sessions for a student
  Future<List<PracticeSession>> getCompletedSessions(String studentId) async {
    _checkInitialized();
    final sessions = await getPracticeSessions(studentId);
    return sessions.where((s) => s.isCompleted).toList();
  }

  /// Delete a practice session
  Future<void> deletePracticeSession(String sessionId) async {
    _checkInitialized();
    try {
      await _sessionBox.delete(sessionId);
      print('Deleted practice session: $sessionId');
    } catch (e) {
      print('Error deleting practice session: $e');
      rethrow;
    }
  }

  // ==================== Problem Attempt Operations ====================

  /// Save a problem attempt
  Future<void> saveProblemAttempt(ProblemAttempt attempt) async {
    _checkInitialized();
    try {
      final jsonData = attempt.toJson();
      await _attemptBox.put(attempt.id, jsonData);
    } catch (e) {
      print('Error saving problem attempt: $e');
      rethrow;
    }
  }

  /// Get all attempts for a session
  Future<List<ProblemAttempt>> getSessionAttempts(String sessionId) async {
    _checkInitialized();
    try {
      final attempts = <ProblemAttempt>[];
      for (final data in _attemptBox.values) {
        try {
          final jsonData = Map<String, dynamic>.from(data);
          final attempt = ProblemAttempt.fromJson(jsonData);
          if (attempt.sessionId == sessionId) {
            attempts.add(attempt);
          }
        } catch (e) {
          print('Error parsing problem attempt: $e');
        }
      }
      return attempts;
    } catch (e) {
      print('Error getting session attempts: $e');
      return [];
    }
  }

  /// Delete attempts for a session
  Future<void> deleteSessionAttempts(String sessionId) async {
    _checkInitialized();
    try {
      final attempts = await getSessionAttempts(sessionId);
      for (final attempt in attempts) {
        await _attemptBox.delete(attempt.id);
      }
    } catch (e) {
      print('Error deleting session attempts: $e');
      rethrow;
    }
  }

  // ==================== Achievement Operations ====================

  /// Save an achievement
  Future<void> saveAchievement(Achievement achievement) async {
    _checkInitialized();
    try {
      final jsonData = achievement.toJson();
      await _achievementBox.put(achievement.id, jsonData);
    } catch (e) {
      print('Error saving achievement: $e');
      rethrow;
    }
  }

  /// Get all achievements for a student
  Future<List<Achievement>> getAchievements(String studentId) async {
    _checkInitialized();
    try {
      final achievements = <Achievement>[];
      for (final data in _achievementBox.values) {
        try {
          final jsonData = Map<String, dynamic>.from(data);
          final achievement = Achievement.fromJson(jsonData);
          if (achievement.studentId == studentId) {
            achievements.add(achievement);
          }
        } catch (e) {
          print('Error parsing achievement: $e');
        }
      }
      // Sort by unlock date, newest first
      achievements.sort((a, b) => b.unlockedAt.compareTo(a.unlockedAt));
      return achievements;
    } catch (e) {
      print('Error getting achievements: $e');
      return [];
    }
  }

  /// Check if student has specific achievement
  Future<bool> hasAchievement(String studentId, String achievementId) async {
    _checkInitialized();
    final achievements = await getAchievements(studentId);
    return achievements.any((a) => a.id == achievementId);
  }

  // ==================== Operation Stats Operations ====================

  /// Save or update operation stats
  Future<void> saveOperationStats(OperationStats stats) async {
    _checkInitialized();
    try {
      final jsonData = stats.toJson();
      await _statsBox.put(stats.id, jsonData);
    } catch (e) {
      print('Error saving operation stats: $e');
      rethrow;
    }
  }

  /// Get stats for specific operation and level
  Future<OperationStats?> getOperationStats({
    required String studentId,
    required String operation,
    required int difficultyLevelId,
  }) async {
    _checkInitialized();
    try {
      for (final data in _statsBox.values) {
        try {
          final jsonData = Map<String, dynamic>.from(data);
          final stats = OperationStats.fromJson(jsonData);
          if (stats.studentId == studentId &&
              stats.operation.toString().split('.').last == operation &&
              stats.difficultyLevelId == difficultyLevelId) {
            return stats;
          }
        } catch (e) {
          print('Error parsing operation stats: $e');
        }
      }
      return null;
    } catch (e) {
      print('Error getting operation stats: $e');
      return null;
    }
  }

  /// Get all stats for a student
  Future<List<OperationStats>> getStudentStats(String studentId) async {
    _checkInitialized();
    try {
      final stats = <OperationStats>[];
      for (final data in _statsBox.values) {
        try {
          final jsonData = Map<String, dynamic>.from(data);
          final opStats = OperationStats.fromJson(jsonData);
          if (opStats.studentId == studentId) {
            stats.add(opStats);
          }
        } catch (e) {
          print('Error parsing operation stats: $e');
        }
      }
      return stats;
    } catch (e) {
      print('Error getting student stats: $e');
      return [];
    }
  }

  // ==================== Backup & Recovery Operations ====================

  /// Create a backup of all data
  Future<void> backupData(String backupKey) async {
    _checkInitialized();
    try {
      final backup = <String, dynamic>{
        'timestamp': DateTime.now().toIso8601String(),
        'students': _studentBox.toMap(),
        'sessions': _sessionBox.toMap(),
        'attempts': _attemptBox.toMap(),
        'achievements': _achievementBox.toMap(),
        'stats': _statsBox.toMap(),
      };
      await _backupBoxRef.put(backupKey, backup);
      print('Backup created: $backupKey');
    } catch (e) {
      print('Error creating backup: $e');
      rethrow;
    }
  }

  /// Restore data from backup
  Future<void> restoreData(String backupKey) async {
    _checkInitialized();
    try {
      final backup = _backupBoxRef.get(backupKey);
      if (backup == null) {
        throw Exception('Backup not found: $backupKey');
      }

      final backupData = Map<String, dynamic>.from(backup);

      // Restore each box
      await _studentBox.clear();
      await _sessionBox.clear();
      await _attemptBox.clear();
      await _achievementBox.clear();
      await _statsBox.clear();

      if (backupData['students'] is Map) {
        final students = Map<String, Map>.from(backupData['students']);
        for (final entry in students.entries) {
          await _studentBox.put(entry.key, entry.value);
        }
      }

      if (backupData['sessions'] is Map) {
        final sessions = Map<String, Map>.from(backupData['sessions']);
        for (final entry in sessions.entries) {
          await _sessionBox.put(entry.key, entry.value);
        }
      }

      if (backupData['attempts'] is Map) {
        final attempts = Map<String, Map>.from(backupData['attempts']);
        for (final entry in attempts.entries) {
          await _attemptBox.put(entry.key, entry.value);
        }
      }

      if (backupData['achievements'] is Map) {
        final achievements = Map<String, Map>.from(backupData['achievements']);
        for (final entry in achievements.entries) {
          await _achievementBox.put(entry.key, entry.value);
        }
      }

      if (backupData['stats'] is Map) {
        final stats = Map<String, Map>.from(backupData['stats']);
        for (final entry in stats.entries) {
          await _statsBox.put(entry.key, entry.value);
        }
      }

      print('Data restored from backup: $backupKey');
    } catch (e) {
      print('Error restoring data: $e');
      rethrow;
    }
  }

  /// Clear all data permanently
  Future<void> clearAllData() async {
    _checkInitialized();
    try {
      await _studentBox.clear();
      await _sessionBox.clear();
      await _attemptBox.clear();
      await _achievementBox.clear();
      await _statsBox.clear();
      print('All data cleared');
    } catch (e) {
      print('Error clearing all data: $e');
      rethrow;
    }
  }

  /// Delete all backups
  Future<void> clearAllBackups() async {
    _checkInitialized();
    try {
      await _backupBoxRef.clear();
      print('All backups cleared');
    } catch (e) {
      print('Error clearing backups: $e');
      rethrow;
    }
  }

  /// Get backup metadata
  Future<List<Map<String, dynamic>>> getBackupList() async {
    _checkInitialized();
    try {
      final backups = <Map<String, dynamic>>[];
      for (final data in _backupBoxRef.values) {
        final backupData = Map<String, dynamic>.from(data);
        backups.add({
          'timestamp': backupData['timestamp'],
          'size': backupData.toString().length,
        });
      }
      return backups;
    } catch (e) {
      print('Error getting backup list: $e');
      return [];
    }
  }

  // ==================== Diagnostics & Cleanup ====================

  /// Get storage statistics
  Future<Map<String, int>> getStorageStats() async {
    _checkInitialized();
    return {
      'studentProfiles': _studentBox.length,
      'practiceSessions': _sessionBox.length,
      'problemAttempts': _attemptBox.length,
      'achievements': _achievementBox.length,
      'operationStats': _statsBox.length,
      'backups': _backupBoxRef.length,
    };
  }

  /// Verify data integrity and attempt recovery
  Future<Map<String, dynamic>> verifyAndRepair() async {
    _checkInitialized();
    final report = <String, dynamic>{
      'timestamp': DateTime.now().toIso8601String(),
      'errors': <String>[],
      'repaired': <String>[],
    };

    try {
      // Verify student profiles
      final studentKeys = List<String>.from(_studentBox.keys);
      for (final key in studentKeys) {
        try {
          final data = _studentBox.get(key);
          if (data != null) {
            Map<String, dynamic>.from(data);
            StudentProfile.fromJson(Map<String, dynamic>.from(data));
          }
        } catch (e) {
          report['errors'].add('Student profile $key: $e');
          await _studentBox.delete(key);
          report['repaired'].add('Deleted corrupted student profile: $key');
        }
      }

      // Verify practice sessions
      final sessionKeys = List<String>.from(_sessionBox.keys);
      for (final key in sessionKeys) {
        try {
          final data = _sessionBox.get(key);
          if (data != null) {
            PracticeSession.fromJson(Map<String, dynamic>.from(data));
          }
        } catch (e) {
          report['errors'].add('Practice session $key: $e');
          await _sessionBox.delete(key);
          report['repaired'].add('Deleted corrupted practice session: $key');
        }
      }

      print('Data verification and repair complete');
      return report;
    } catch (e) {
      report['errors'].add('Verification process error: $e');
      return report;
    }
  }

  /// Close storage service (call on app shutdown)
  Future<void> close() async {
    try {
      await Hive.close();
      _isInitialized = false;
      print('StorageService closed');
    } catch (e) {
      print('Error closing StorageService: $e');
    }
  }
}
