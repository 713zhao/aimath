import '../models/achievement.dart';
import '../models/operation_stats.dart';
import '../models/practice_session.dart';
import '../providers/statistics_provider.dart';
import '../providers/student_provider.dart';
import '../utils/enums.dart';
import 'storage_service.dart';

/// Attempts and correct answers for one operation within a game.
typedef OperationResult = ({int attempts, int correct});

/// Records the outcome of a mini-game so it counts toward the student's
/// points, streak, accuracy and the progress dashboard, like a practice
/// session does.
class GameResultRecorder {
  GameResultRecorder._();

  static const int pointsPerCorrect = 10;

  /// Saves a completed game as a [PracticeSession] and updates the student's
  /// profile. [problems] is how many questions/pairs were attempted and
  /// [correct] how many were answered correctly first time.
  /// [operations] optionally breaks the result down per operation so it also
  /// feeds the per-operation accuracy stats.
  ///
  /// Returns any achievements newly unlocked by this game. Does nothing (and
  /// returns an empty list) when there is no student or nothing was attempted.
  static Future<List<Achievement>> record({
    required String gameId,
    required int problems,
    required int correct,
    required DateTime startedAt,
    Map<Operation, OperationResult> operations = const {},
  }) async {
    final studentProvider = StudentProvider();
    final student = studentProvider.currentStudent;
    if (student == null || problems <= 0) return [];

    final safeCorrect = correct.clamp(0, problems);
    final accuracy = safeCorrect / problems * 100;
    final points = safeCorrect * pointsPerCorrect;
    final now = DateTime.now();
    final sessionId = 'game_${gameId}_${now.microsecondsSinceEpoch}';

    try {
      await StorageService().savePracticeSession(PracticeSession(
        id: sessionId,
        studentId: student.id,
        difficultyLevelId: student.currentDifficultyLevel,
        problemIds: List.generate(problems, (i) => '${sessionId}_$i'),
        attemptIds: const [],
        totalPoints: points,
        accuracyPercentage: accuracy,
        startedAt: startedAt,
        completedAt: now,
      ));

      await studentProvider.updateStudentStats(
        sessionPoints: points,
        sessionProblems: problems,
        sessionCorrectAnswers: safeCorrect,
        sessionAccuracy: accuracy,
      );

      for (final entry in operations.entries) {
        await _updateOperationStats(
          studentId: student.id,
          level: student.currentDifficultyLevel,
          operation: entry.key,
          result: entry.value,
          now: now,
        );
      }

      final unlocked = await _checkAchievements(
        studentId: student.id,
        gameId: gameId,
        problems: problems,
        correct: safeCorrect,
      );

      // Refresh the dashboard's session and stats lists.
      await StatisticsProvider().loadStudentStats(student.id);
      return unlocked;
    } catch (e) {
      print('Error recording game result: $e');
      return [];
    }
  }

  static Future<void> _updateOperationStats({
    required String studentId,
    required int level,
    required Operation operation,
    required OperationResult result,
    required DateTime now,
  }) async {
    if (result.attempts <= 0) return;
    final storage = StorageService();
    final existing = await storage.getOperationStats(
      studentId: studentId,
      operation: operation.name,
      difficultyLevelId: level,
    );
    final base = existing ??
        OperationStats(
          id: 'stats_${now.millisecondsSinceEpoch}_${operation.name}',
          studentId: studentId,
          operation: operation,
          difficultyLevelId: level,
          totalAttempts: 0,
          correctAttempts: 0,
          totalPoints: 0,
          lastPracticedAt: now,
          createdAt: now,
        );
    await storage.saveOperationStats(base.copyWith(
      totalAttempts: base.totalAttempts + result.attempts,
      correctAttempts: base.correctAttempts + result.correct,
      totalPoints: base.totalPoints + result.correct * pointsPerCorrect,
      lastPracticedAt: now,
    ));
  }

  static Future<List<Achievement>> _checkAchievements({
    required String studentId,
    required String gameId,
    required int problems,
    required int correct,
  }) async {
    final earned = <String>[];
    if (gameId == 'pizza_slices') {
      if (correct == problems) earned.add('pizza_master');

      final sessions = await StorageService().getPracticeSessions(studentId);
      final pizzaProblems = sessions
          .where((s) => s.id.startsWith('game_pizza_slices_'))
          .fold<int>(0, (sum, s) => sum + s.problemCount);
      if (pizzaProblems >= 50) earned.add('fraction_fan');
    }

    final unlocked = <Achievement>[];
    for (final id in earned) {
      final a = await _unlock(studentId, id);
      if (a != null) unlocked.add(a);
    }
    return unlocked;
  }

  static Future<Achievement?> _unlock(String studentId, String id) async {
    final storage = StorageService();
    if (await storage.hasAchievement(studentId, id)) return null;
    final def = AchievementDefinitions.getById(id);
    if (def == null) return null;
    final achievement = Achievement(
      id: id,
      studentId: studentId,
      title: def.title,
      description: def.description,
      icon: def.icon,
      unlockedAt: DateTime.now(),
      points: def.points,
    );
    await storage.saveAchievement(achievement);
    await StudentProvider().addAchievement(id);
    return achievement;
  }
}
