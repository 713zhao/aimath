import 'package:hive_flutter/hive_flutter.dart';
import '../models/student_profile.dart';
import '../services/storage_service.dart';

/// Handles first-run initialization and app setup
class AppInitializer {
  final StorageService _storageService = StorageService();
  
  // Store the current student ID for quick access
  static const String _currentStudentKey = 'current_student_id';

  /// Check if this is the first run of the app
  /// First run is determined by whether any student profile exists
  Future<bool> isFirstRun() async {
    try {
      // Use storage service to check for existing profiles
      final students = await _storageService.getAllStudents();
      return students.isEmpty;
    } catch (e) {
      // If error, assume first run
      return true;
    }
  }

  /// Check if user profile exists
  Future<bool> hasUserProfile() async {
    try {
      final students = await _storageService.getAllStudents();
      return students.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Initialize app on first run
  /// Returns the newly created student profile
  Future<StudentProfile?> initializeApp({
    required String studentName,
    required int studentAge,
  }) async {
    try {
      final newProfile = StudentProfile(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: studentName,
        age: studentAge,
        currentDifficultyLevel: 1,
        totalPoints: 0,
        totalProblemsCompleted: 0,
        totalCorrectAnswers: 0,
        currentStreak: 0,
        longestStreak: 0,
        achievementIds: [],
        createdAt: DateTime.now(),
        lastActiveAt: DateTime.now(),
      );

      // Save the profile
      await _storageService.saveStudentProfile(newProfile);
      
      // Save current student ID for future app launches
      await _saveCurrentStudentId(newProfile.id);
      
      return newProfile;
    } catch (e) {
      print('Error initializing app: $e');
      return null;
    }
  }

  /// Initialize all services
  /// Call this during app startup to ensure all services are ready
  Future<void> initializeServices() async {
    // Initialize the storage service first
    await _storageService.initialize();
  }

  /// Load existing user profile if it exists
  Future<StudentProfile?> loadExistingProfile() async {
    try {
      // First try to load the last used student
      final currentId = await _getCurrentStudentId();
      if (currentId != null) {
        final profile = await _storageService.loadStudentProfile(currentId);
        if (profile != null) return profile;
      }
      
      // Fallback: load the first available student
      final students = await _storageService.getAllStudents();
      if (students.isNotEmpty) {
        final profile = students.first;
        await _saveCurrentStudentId(profile.id);
        return profile;
      }
      return null;
    } catch (e) {
      print('Error loading existing profile: $e');
      return null;
    }
  }
  
  /// Save current student ID to preferences
  Future<void> _saveCurrentStudentId(String studentId) async {
    try {
      final box = await Hive.openBox('app_settings');
      await box.put(_currentStudentKey, studentId);
    } catch (e) {
      print('Error saving current student ID: $e');
    }
  }
  
  /// Get current student ID from preferences
  Future<String?> _getCurrentStudentId() async {
    try {
      final box = await Hive.openBox('app_settings');
      return box.get(_currentStudentKey) as String?;
    } catch (e) {
      print('Error getting current student ID: $e');
      return null;
    }
  }
}
