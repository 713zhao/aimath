import 'package:flutter_test/flutter_test.dart';
import 'package:aimath/controllers/streak_tracker.dart';

void main() {
  late StreakTracker streakTracker;

  setUp(() {
    streakTracker = StreakTracker();
  });

  group('StreakTracker - Streak Recording', () {
    test('starts with zero streak', () {
      expect(streakTracker.currentStreak, equals(0));
    });

    test('increments streak on correct answer', () {
      streakTracker.recordCorrect();
      expect(streakTracker.currentStreak, equals(1));
    });

    test('increments streak on consecutive correct answers', () {
      streakTracker.recordCorrect();
      streakTracker.recordCorrect();
      streakTracker.recordCorrect();

      expect(streakTracker.currentStreak, equals(3));
    });

    test('resets streak on incorrect answer', () {
      streakTracker.recordCorrect();
      streakTracker.recordCorrect();
      expect(streakTracker.currentStreak, equals(2));

      streakTracker.recordIncorrect();
      expect(streakTracker.currentStreak, equals(0));
    });

    test('maintains streak across multiple correct answers', () {
      for (int i = 0; i < 8; i++) {
        streakTracker.recordCorrect();
      }

      expect(streakTracker.currentStreak, equals(8));
    });

    test('can rebuild streak after breaking it', () {
      // Build initial streak
      for (int i = 0; i < 5; i++) {
        streakTracker.recordCorrect();
      }

      expect(streakTracker.currentStreak, equals(5));

      // Break streak
      streakTracker.recordIncorrect();
      expect(streakTracker.currentStreak, equals(0));

      // Rebuild
      streakTracker.recordCorrect();
      expect(streakTracker.currentStreak, equals(1));
    });
  });

  group('StreakTracker - Longest Streak Tracking', () {
    test('starts with zero longest streak', () {
      expect(streakTracker.longestStreak, equals(0));
    });

    test('updates longest streak when exceeded', () {
      for (int i = 0; i < 3; i++) {
        streakTracker.recordCorrect();
      }

      expect(streakTracker.longestStreak, equals(3));
    });

    test('maintains longest streak record', () {
      // Build first streak of 5
      for (int i = 0; i < 5; i++) {
        streakTracker.recordCorrect();
      }

      expect(streakTracker.longestStreak, equals(5));

      // Break it
      streakTracker.recordIncorrect();

      // Build smaller streak of 3
      for (int i = 0; i < 3; i++) {
        streakTracker.recordCorrect();
      }

      // Longest should still be 5
      expect(streakTracker.longestStreak, equals(5));
      expect(streakTracker.currentStreak, equals(3));
    });

    test('creates new longest streak record', () {
      // First streak of 3
      for (int i = 0; i < 3; i++) {
        streakTracker.recordCorrect();
      }

      expect(streakTracker.longestStreak, equals(3));

      // Break and build longer streak of 7
      streakTracker.recordIncorrect();

      for (int i = 0; i < 7; i++) {
        streakTracker.recordCorrect();
      }

      expect(streakTracker.longestStreak, equals(7));
      expect(streakTracker.currentStreak, equals(7));
    });
  });

  group('StreakTracker - Session Streak Tracking', () {
    test('starts new session with zero session streak', () {
      streakTracker.recordCorrect();
      expect(streakTracker.sessionStreak, equals(1));

      streakTracker.startNewSession();
      expect(streakTracker.sessionStreak, equals(0));
    });

    test('tracks session streak independently', () {
      // Record some streak
      for (int i = 0; i < 5; i++) {
        streakTracker.recordCorrect();
      }

      expect(streakTracker.sessionStreak, equals(5));
      expect(streakTracker.currentStreak, equals(5));

      // Start new session
      streakTracker.startNewSession();

      expect(streakTracker.sessionStreak, equals(0));
      expect(streakTracker.currentStreak, equals(5)); // Overall unchanged
    });

    test('session streak independent of breaks', () {
      for (int i = 0; i < 3; i++) {
        streakTracker.recordCorrect();
      }

      expect(streakTracker.sessionStreak, equals(3));

      // Break the streak
      streakTracker.recordIncorrect();

      expect(streakTracker.currentStreak, equals(0));
      expect(streakTracker.sessionStreak, equals(3)); // Session count preserved
    });
  });

  group('StreakTracker - Streak Multiplier', () {
    test('base multiplier is 1.0 for no streak', () {
      final multiplier = streakTracker.getStreakMultiplier();
      expect(multiplier, equals(1.0));
    });

    test('multiplier is 1.0 for streak of 1', () {
      streakTracker.recordCorrect();
      final multiplier = streakTracker.getStreakMultiplier();
      expect(multiplier, equals(1.0));
    });

    test('multiplier is 1.5 for streak of 2-4', () {
      for (int i = 0; i < 2; i++) {
        streakTracker.recordCorrect();
      }

      expect(streakTracker.getStreakMultiplier(), equals(1.5));

      streakTracker.recordCorrect();
      expect(streakTracker.getStreakMultiplier(), equals(1.5));
    });

    test('multiplier is 2.0 for streak of 5-9', () {
      for (int i = 0; i < 5; i++) {
        streakTracker.recordCorrect();
      }

      expect(streakTracker.getStreakMultiplier(), equals(2.0));

      for (int i = 0; i < 4; i++) {
        streakTracker.recordCorrect();
      }

      expect(streakTracker.getStreakMultiplier(), equals(2.0));
    });

    test('multiplier is 2.5 for streak of 10-24', () {
      for (int i = 0; i < 10; i++) {
        streakTracker.recordCorrect();
      }

      expect(streakTracker.getStreakMultiplier(), equals(2.5));
    });

    test('multiplier is 3.0 for streak of 25+', () {
      for (int i = 0; i < 25; i++) {
        streakTracker.recordCorrect();
      }

      expect(streakTracker.getStreakMultiplier(), equals(3.0));
    });
  });

  group('StreakTracker - Bonus Points Calculation', () {
    test('no bonus for no streak', () {
      final bonus = streakTracker.getStreakBonusPoints(10);
      expect(bonus, equals(0));
    });

    test('bonus increases with streak', () {
      // Streak of 2
      streakTracker.recordCorrect();
      streakTracker.recordCorrect();
      final bonus2 = streakTracker.getStreakBonusPoints(10);

      // Streak of 5
      streakTracker = StreakTracker();
      for (int i = 0; i < 5; i++) {
        streakTracker.recordCorrect();
      }
      final bonus5 = streakTracker.getStreakBonusPoints(10);

      expect(bonus5, greaterThan(bonus2));
    });

    test('bonus calculation is correct', () {
      // Streak of 2 (1.5x multiplier)
      streakTracker.recordCorrect();
      streakTracker.recordCorrect();

      // Base 10 points, 1.5x multiplier = 15 total, 5 bonus
      final bonus = streakTracker.getStreakBonusPoints(10);
      expect(bonus, equals(5));
    });
  });

  group('StreakTracker - Milestone Tracking', () {
    test('no milestone for no streak', () {
      expect(streakTracker.getStreakMilestone(), equals(0));
    });

    test('milestone for streak of 2', () {
      streakTracker.recordCorrect();
      streakTracker.recordCorrect();
      expect(streakTracker.getStreakMilestone(), equals(2));
    });

    test('milestone for streak of 5', () {
      for (int i = 0; i < 5; i++) {
        streakTracker.recordCorrect();
      }
      expect(streakTracker.getStreakMilestone(), equals(5));
    });

    test('milestone for streak of 10', () {
      for (int i = 0; i < 10; i++) {
        streakTracker.recordCorrect();
      }
      expect(streakTracker.getStreakMilestone(), equals(10));
    });

    test('milestone for streak of 25', () {
      for (int i = 0; i < 25; i++) {
        streakTracker.recordCorrect();
      }
      expect(streakTracker.getStreakMilestone(), equals(25));
    });
  });

  group('StreakTracker - Messages and Emojis', () {
    test('empty message for no streak', () {
      expect(streakTracker.getStreakMessage(), isEmpty);
    });

    test('generates message for streak of 2', () {
      streakTracker.recordCorrect();
      streakTracker.recordCorrect();
      expect(streakTracker.getStreakMessage(), contains('2'));
    });

    test('generates message for streak of 5', () {
      for (int i = 0; i < 5; i++) {
        streakTracker.recordCorrect();
      }
      expect(streakTracker.getStreakMessage(), contains('5'));
    });

    test('emoji for no streak', () {
      expect(streakTracker.getStreakEmoji(), isEmpty);
    });

    test('emoji for streak of 2+', () {
      streakTracker.recordCorrect();
      streakTracker.recordCorrect();
      expect(streakTracker.getStreakEmoji(), isNotEmpty);
    });

    test('emoji progression with streak', () {
      // Streak of 2-4: ✨
      streakTracker.recordCorrect();
      streakTracker.recordCorrect();
      final emoji2 = streakTracker.getStreakEmoji();
      expect(emoji2, isNotEmpty);

      // Streak of 5+: ⚡
      for (int i = 0; i < 3; i++) {
        streakTracker.recordCorrect();
      }
      final emoji5 = streakTracker.getStreakEmoji();
      expect(emoji5, isNotEmpty);
    });
  });

  group('StreakTracker - Reset', () {
    test('reset clears all streaks', () {
      for (int i = 0; i < 10; i++) {
        streakTracker.recordCorrect();
      }

      expect(streakTracker.currentStreak, equals(10));
      expect(streakTracker.longestStreak, equals(10));

      streakTracker.reset();

      expect(streakTracker.currentStreak, equals(0));
      expect(streakTracker.longestStreak, equals(0));
      expect(streakTracker.sessionStreak, equals(0));
    });
  });

  group('StreakTracker - Edge Cases', () {
    test('handles very long streaks', () {
      for (int i = 0; i < 100; i++) {
        streakTracker.recordCorrect();
      }

      expect(streakTracker.currentStreak, equals(100));
      expect(streakTracker.longestStreak, equals(100));
      expect(streakTracker.getStreakMultiplier(), equals(3.0));
    });

    test('handles rapid streak-breaking', () {
      for (int i = 0; i < 5; i++) {
        streakTracker.recordCorrect();
        streakTracker.recordIncorrect();
      }

      expect(streakTracker.currentStreak, equals(0));
      expect(streakTracker.longestStreak, equals(1));
    });

    test('streak of exactly boundary values', () {
      // Test boundary between 1.0 and 1.5 (at streak 2)
      streakTracker.recordCorrect();
      expect(streakTracker.getStreakMultiplier(), equals(1.0));

      streakTracker.recordCorrect();
      expect(streakTracker.getStreakMultiplier(), equals(1.5));

      // Test boundary between 1.5 and 2.0 (at streak 5)
      streakTracker = StreakTracker();
      for (int i = 0; i < 4; i++) {
        streakTracker.recordCorrect();
      }
      expect(streakTracker.getStreakMultiplier(), equals(1.5));

      streakTracker.recordCorrect();
      expect(streakTracker.getStreakMultiplier(), equals(2.0));

      // Test boundary between 2.0 and 2.5 (at streak 10)
      streakTracker = StreakTracker();
      for (int i = 0; i < 9; i++) {
        streakTracker.recordCorrect();
      }
      expect(streakTracker.getStreakMultiplier(), equals(2.0));

      streakTracker.recordCorrect();
      expect(streakTracker.getStreakMultiplier(), equals(2.5));
    });
  });
}
