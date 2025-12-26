# Math Practice App - Design

## Architecture Overview

### System Components

```
┌─────────────────────────────────────────────────────────┐
│                    Flutter App (Client)                  │
├─────────────────────────────────────────────────────────┤
│  ┌──────────────────────────────────────────────────┐   │
│  │           Presentation Layer (UI)                │   │
│  ├──────────────────────────────────────────────────┤   │
│  │ • HomeScreen                                     │   │
│  │ • DifficultySelector                             │   │
│  │ • PracticeSession                                │   │
│  │ • ResultsScreen                                  │   │
│  │ • ProgressDashboard                              │   │
│  │ • SettingsScreen                                 │   │
│  └──────────────────────────────────────────────────┘   │
│                          ↓                               │
│  ┌──────────────────────────────────────────────────┐   │
│  │      Business Logic Layer (State Management)     │   │
│  ├──────────────────────────────────────────────────┤   │
│  │ • GameController (Problem generation, scoring)  │   │
│  │ • ProgressTracker (Level, points, statistics)   │   │
│  │ • ProblemGenerator (Difficulty-based problems)  │   │
│  │ • StreakTracker (Consecutive correct answers)   │   │
│  │ • AchievementManager (Badges, milestones)       │   │
│  └──────────────────────────────────────────────────┘   │
│                          ↓                               │
│  ┌──────────────────────────────────────────────────┐   │
│  │       Data Layer (Local Storage & Models)        │   │
│  ├──────────────────────────────────────────────────┤   │
│  │ • StudentProfile (Level, points, preferences)   │   │
│  │ • PracticeSession (Problems, answers, times)    │   │
│  │ • StatisticsRepository (Accuracy, timing data)  │   │
│  │ • AchievementRepository (Earned badges)         │   │
│  │ • LocalDatabase (SQLite via Hive/GetStorage)    │   │
│  └──────────────────────────────────────────────────┘   │
│                          ↓                               │
│  ┌──────────────────────────────────────────────────┐   │
│  │    Cross-Cutting Concerns (Utilities)            │   │
│  ├──────────────────────────────────────────────────┤   │
│  │ • AudioManager (Sound effects, toggle)           │   │
│  │ • AnimationController (Celebrations, feedback)  │   │
│  │ • LocalizationManager (i18n support)             │   │
│  │ • ThemeManager (Light/dark mode, colors)        │   │
│  └──────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

## Technology Stack

### Frontend
- **Framework**: Flutter 3.0+ with Dart 3.0+
- **State Management**: Provider 6.0+ or Riverpod 2.0+
- **Local Storage**: GetStorage or Hive (key-value storage)
- **Animation**: Flutter built-in animations + Lottie for complex animations
- **Audio**: Just_audio or audioplayers package
- **UI Components**: Flutter's Material Design 3
- **Math Expressions**: expression_language or math_expressions for future support

### Development Tools
- **IDE**: VSCode or Android Studio
- **Version Control**: Git
- **Testing**: Flutter test, Mockito for unit/widget tests
- **CI/CD**: GitHub Actions or Codemagic

## Data Models

### StudentProfile
```dart
class StudentProfile {
  String id;
  String name;
  int currentLevel;
  int totalPoints;
  DateTime joinDate;
  DateTime lastPracticeDate;
  bool soundEnabled;
  bool darkModeEnabled;
  Map<String, OperationStats> operationStats; // per operation tracking
}
```

### DifficultyLevel
```dart
class DifficultyLevel {
  int levelNumber;
  String name;           // e.g., "Level 1: Single Digits"
  int minNumber;         // 1, 10, 100, 1000
  int maxNumber;         // 9, 99, 999, 9999
  int pointsPerCorrect;  // 10, 15, 20, 25
  int timeLimit;         // seconds per problem
  double progressThreshold; // 0.85 for 85%
}
```

### MathProblem
```dart
class MathProblem {
  String id;
  int operand1;
  int operand2;
  String operation;      // +, -, ×, ÷
  int correctAnswer;
  int difficultyLevel;
  DateTime createdAt;
}
```

### PracticeSession
```dart
class PracticeSession {
  String id;
  DateTime startTime;
  DateTime endTime;
  int difficultyLevel;
  List<String> operationTypes; // ['+', '-', '×', '÷']
  List<ProblemAttempt> attempts;
  int totalCorrect;
  int totalProblems;
  double accuracy;
  int streak;
  int pointsEarned;
}
```

### ProblemAttempt
```dart
class ProblemAttempt {
  String problemId;
  String studentAnswer;
  int correctAnswer;
  int timeTaken;         // milliseconds
  bool isCorrect;
  DateTime attemptedAt;
  int pointsAwarded;
}
```

### Achievement
```dart
class Achievement {
  String id;
  String name;           // e.g., "Hundred Points Club"
  String description;
  String badgeImagePath;
  int pointsThreshold;
  DateTime unlockedAt;
}
```

### OperationStats
```dart
class OperationStats {
  String operation;      // +, -, ×, ÷
  int problemsSolved;
  int correctAnswers;
  double accuracy;
  int totalTimeSpent;    // seconds
  DateTime lastPracticed;
}
```

## UI Layout Specifications

### Screen 1: Home Screen
```
┌─────────────────────────────┐
│  🎓 Math Master             │ [Settings ⚙️]
├─────────────────────────────┤
│                             │
│    Welcome, [Name]!         │
│    ⭐ Level 2              │
│    💰 1,250 Points         │
│                             │
├─────────────────────────────┤
│  [Start Practice] (Large)   │
├─────────────────────────────┤
│  📊 Your Stats              │
│  • Addition: 92%            │
│  • Subtraction: 88%         │
│  • Multiply: 75%            │
│  • Division: 80%            │
├─────────────────────────────┤
│  🏆 Achievements (3/12)     │
│  🥇 100 Points Club         │
│  🥈 5-Streak Master         │
│  🥉 Week Warrior            │
└─────────────────────────────┘
```

### Screen 2: Difficulty Selector
```
┌─────────────────────────────┐
│  Select Difficulty          │
├─────────────────────────────┤
│                             │
│  ☑️  Level 1 (Current)     │
│  Single Digits (1-9)       │
│  10 Points per answer      │
│                             │
│  ○  Level 2 (Unlocked)     │
│  Two Digits (10-99)        │
│  15 Points per answer      │
│                             │
│  ○  Level 3 (Locked)       │
│  Three Digits (100-999)    │
│  20 Points per answer      │
│  (Need 85% on Level 2)     │
│                             │
│  [Start Practice] [Cancel]  │
└─────────────────────────────┘
```

### Screen 3: Practice Session
```
┌─────────────────────────────┐
│  ⬅️  Problem 3/10  ⏱️ 0:30  │
│     🔥 3 Streak             │
├─────────────────────────────┤
│                             │
│              8              │
│            ×   2            │
│          ─────────          │
│          [ ? ]              │
│                             │
│  [16]  [14]  [10]           │
│                             │
│  [Submit]                   │
│                             │
└─────────────────────────────┘
```

### Screen 4: Answer Feedback (Correct)
```
┌─────────────────────────────┐
│  ✅ Correct!                 │
│  🎉 🎉 🎉 (Confetti)        │
├─────────────────────────────┤
│  You earned 18 points!      │
│  (15 base + 3 speed bonus)  │
│                             │
│  Your streak: 🔥4           │
│                             │
│  [Next Problem]             │
└─────────────────────────────┘
```

### Screen 5: Answer Feedback (Incorrect)
```
┌─────────────────────────────┐
│  ❌ Not Quite!               │
├─────────────────────────────┤
│  Your answer: 18            │
│  Correct answer: 16         │
│                             │
│  Your streak: 🔄 Reset     │
│                             │
│  8 × 2 = 16                 │
│                             │
│  [Try Again] [Skip]         │
└─────────────────────────────┘
```

### Screen 6: Session Results
```
┌─────────────────────────────┐
│  Session Complete! 🎓       │
├─────────────────────────────┤
│  Correct: 8/10 (80%)        │
│  Time Taken: 5:32           │
│  Points Earned: 142         │
│                             │
│  Performance:               │
│  ████████░░ 80%             │
│                             │
│  Best Streak: 🔥 4          │
│  Avg Time: 33 sec           │
│                             │
│  🏆 Level Up! (Not Yet)     │
│                             │
│  [Practice Again] [Home]    │
└─────────────────────────────┘
```

### Screen 7: Progress Dashboard
```
┌─────────────────────────────┐
│  📊 My Progress              │
├─────────────────────────────┤
│  This Week:                 │
│  💰 542 Points              │
│  📝 35 Problems Solved      │
│  ✅ 88% Average Accuracy    │
│                             │
│  By Operation:              │
│  ➕ 92% (12 prob)           │
│  ➖ 85% (9 prob)            │
│  ✖️  78% (8 prob)           │
│  ➗ 81% (6 prob)            │
│                             │
│  Level Progress:            │
│  Level 2: ██████████ 100%   │
│           (Ready to advance) │
│                             │
│  [Back to Home]             │
└─────────────────────────────┘
```

## Color Palette (Kids-Friendly)

| Element | Color | Hex Code | Usage |
|---------|-------|----------|-------|
| Primary | Bright Blue | #2196F3 | Buttons, accents |
| Success | Green | #4CAF50 | Correct answers |
| Error | Red | #F44336 | Incorrect answers |
| Warning | Orange | #FF9800 | Time warnings |
| Background | Light Gray | #F5F5F5 | Main background |
| Text | Dark Gray | #212121 | Primary text |
| Light Text | Medium Gray | #757575 | Secondary text |
| Accent Gold | Gold | #FFB81C | Points, achievements |
| Positive | Light Green | #E8F5E9 | Success feedback |
| Negative | Light Red | #FFEBEE | Error feedback |

## Typography

| Element | Font | Size | Weight |
|---------|------|------|--------|
| Title | Roboto | 28px | Bold |
| Large Display (Math) | Roboto | 48px | Bold |
| Button Text | Roboto | 18px | Medium |
| Body Text | Roboto | 16px | Regular |
| Small Text | Roboto | 14px | Regular |
| Hint Text | Roboto | 12px | Regular |

## Animation Specifications

### Correct Answer Animation
- **Duration**: 0.5s
- **Type**: Combination of:
  - Confetti particles (3-5 seconds)
  - Scale bounce: 1.0 → 1.1 → 1.0
  - Color flash: white → success color
  - Success checkmark draw animation

### Incorrect Answer Animation
- **Duration**: 0.4s
- **Type**: 
  - Shake: left ↔ right (3 times, 10px amplitude)
  - Color flash: error color
  - Sad emoji appearance

### Level Up Animation
- **Duration**: 2.0s
- **Type**:
  - Full-screen confetti burst
  - Star particle effects
  - Trophy icon animation
  - Sound effect (celebratory music)

### Streak Counter
- **Duration**: 0.3s per increment
- **Type**: Scale up from bottom + flame icon glow

## State Management Flow

```
User Input (Answer)
    ↓
GameController.submitAnswer()
    ↓
Validate Answer
    ↓
Calculate Points & Bonuses
    ↓
Update Streak & Statistics
    ↓
Check Level Progression (85% on 10 problems?)
    ↓
Check Achievement Unlocks
    ↓
Save to Local Storage
    ↓
Update UI State (Provider/Riverpod)
    ↓
Display Feedback (Correct/Incorrect)
    ↓
Either: Next Problem OR Session Complete
```

## File Structure

```
lib/
├── main.dart
├── models/
│   ├── student_profile.dart
│   ├── difficulty_level.dart
│   ├── math_problem.dart
│   ├── practice_session.dart
│   ├── problem_attempt.dart
│   ├── achievement.dart
│   └── operation_stats.dart
├── screens/
│   ├── home_screen.dart
│   ├── difficulty_selector_screen.dart
│   ├── practice_session_screen.dart
│   ├── answer_feedback_screen.dart
│   ├── session_results_screen.dart
│   ├── progress_dashboard_screen.dart
│   └── settings_screen.dart
├── controllers/
│   ├── game_controller.dart
│   ├── progress_tracker.dart
│   ├── problem_generator.dart
│   ├── streak_tracker.dart
│   └── achievement_manager.dart
├── services/
│   ├── storage_service.dart
│   ├── audio_service.dart
│   ├── analytics_service.dart
│   └── notification_service.dart
├── widgets/
│   ├── problem_display.dart
│   ├── answer_buttons.dart
│   ├── feedback_dialog.dart
│   ├── streak_indicator.dart
│   ├── progress_bar.dart
│   └── achievement_badge.dart
├── utils/
│   ├── constants.dart
│   ├── colors.dart
│   ├── theme.dart
│   └── helper_functions.dart
├── providers/ (or store/ for state management)
│   ├── student_provider.dart
│   ├── game_provider.dart
│   └── statistics_provider.dart
└── config/
    ├── difficulty_config.dart
    └── localization_config.dart

assets/
├── images/
│   ├── badges/
│   ├── icons/
│   └── illustrations/
├── sounds/
│   ├── correct.mp3
│   ├── incorrect.mp3
│   ├── levelup.mp3
│   └── click.mp3
└── animations/
    ├── confetti.json
    ├── celebration.json
    └── streak.json
```

## Integration Points

### Local Storage
- Use Hive or GetStorage for offline-first data persistence
- Store: StudentProfile, PracticeSessions, Achievements, OperationStats
- Auto-save after each problem attempt
- Backup/restore functionality for profile switching

### Audio System
- Background mute detection (respect device settings)
- Audio toggle in settings
- Different sound effects for: correct, incorrect, level up, click
- Volume control (system-wide)

### Analytics (Optional Future)
- Track: session duration, accuracy, level progression
- Aggregate stats for parent dashboard
- No PII collection (privacy-first)

## Performance Considerations

1. **Problem Generation**: Pre-generate batch of 10 problems to avoid UI freezes
2. **Animations**: Use GPU-accelerated transforms for 60 FPS
3. **Storage**: Lazy-load historical data, keep current session in memory
4. **Memory**: Dispose of unused assets after screens transition

## Accessibility Features

1. **Text Size**: Support system font scaling (100%-200%)
2. **Color Contrast**: 4.5:1 ratio for all text
3. **Touch Targets**: All buttons 48x48 dp minimum
4. **Screen Reader**: Semantic labels for all interactive elements
5. **High Contrast Mode**: Support for accessibility switches

## Error Handling

1. **Storage Errors**: Graceful fallback to in-memory storage
2. **Audio Errors**: Silent failure with visual feedback only
3. **Data Corruption**: Auto-recovery from backups
4. **Connection Errors** (future): Queue offline data for sync

## Testing Strategy

- **Unit Tests**: Game logic, calculations, streak tracking
- **Widget Tests**: UI components, navigation
- **Integration Tests**: End-to-end practice sessions
- **Performance Tests**: Problem generation speed, animation smoothness
