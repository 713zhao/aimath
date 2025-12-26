# Math Practice App - Implementation Tasks

## Overview
This document breaks down the Math Practice App design into atomic implementation tasks. Each task is designed to be completed independently with minimal file modifications.

---

## Phase 1: Project Setup & Core Models

### Task 1.1: Flutter Project Initialization
- [x] Initialize Flutter project with proper structure
- **Files**: 
  - `pubspec.yaml`
  - `lib/main.dart`
  - `.gitignore`
- **Dependencies**: provider, hive, just_audio, lottie

**_Prompt**:
```
Role: Flutter Project Lead
Task: Set up a new Flutter project for the Math Practice App. Configure pubspec.yaml with all required dependencies (provider 6.0+, hive 2.0+, just_audio 0.13+, lottie 2.0+). Create main.dart with proper initialization and theme configuration. Set up directory structure as defined in design.md.
Restrictions: Do not implement any screens yet. Focus on project skeleton and dependency configuration.
_Leverage: Flutter best practices, Material Design 3 theming
_Requirements: NFR-001 (Platform Requirements), US-004 (Kid-Friendly UI)
Success: Flutter project builds successfully, pubspec.lock is generated, all directories exist per the file structure specification.
Instructions: Mark this task as in-progress [-] in tasks.md, then after implementation, use log-implementation to record what was done, then mark as completed [x].
```

### Task 1.2: Create Data Models
- [x] Implement all data models and enums
- **Files**:
  - `lib/models/student_profile.dart`
  - `lib/models/difficulty_level.dart`
  - `lib/models/math_problem.dart`
  - `lib/models/practice_session.dart`
  - `lib/models/problem_attempt.dart`
  - `lib/models/achievement.dart`
  - `lib/models/operation_stats.dart`
  - `lib/config/difficulty_config.dart`

**_Prompt**:
```
Role: Data Architect
Task: Create all data model classes defined in design.md. Include JSON serialization (toJson/fromJson) for Hive storage compatibility. Create a difficulty_config.dart that defines all 4 difficulty levels with specific number ranges and points per correct answer. Create an enums.dart file for operation types (+, -, ×, ÷).
Restrictions: Models should be immutable (use final fields). No business logic in models - data classes only. Do not implement UI or storage yet.
_Leverage: Flutter freezed package (optional), copyWith methods for immutability
_Requirements: All user stories for difficulty levels and points system
Success: All models instantiate correctly, JSON serialization works, DifficultyLevel configuration matches requirements (Level 1: 1-9, Level 2: 10-99, etc., with 10/15/20/25 points).
Instructions: Mark this task as in-progress [-] in tasks.md, then after implementation, use log-implementation to record model classes created, then mark as completed [x].
```

### Task 1.3: Create Theme & Utilities
- [x] Set up color palette, typography, and helper functions
- **Files**:
  - `lib/utils/colors.dart`
  - `lib/utils/theme.dart`
  - `lib/utils/constants.dart`
  - `lib/utils/helper_functions.dart`

**_Prompt**:
```
Role: UI/UX Engineer
Task: Create a complete theme system with the color palette from design.md (Bright Blue #2196F3, Green #4CAF50, Red #F44336, etc.). Define TextTheme with typography specifications (Roboto, sizes 12-48px). Create a ThemeData configuration for Material Design 3. Add helper functions for common operations (pointsForLevel, streakMultiplier, levelProgression). Create constants for animations durations, time limits, and thresholds.
Restrictions: Colors and fonts must match design specifications exactly. Helper functions should be pure (no side effects).
_Leverage: Material Design 3 guidelines, Flutter's built-in theming
_Requirements: US-004 (Kid-Friendly UI), NFR-002 (Accessibility)
Success: Theme is consistent, all colors have sufficient contrast (4.5:1 minimum), typography matches design spec, app builds with custom theme applied.
Instructions: Mark this task as in-progress [-] in tasks.md, then after implementation, use log-implementation to record theme creation, then mark as completed [x].
```

---

## Phase 2: State Management & Services

### Task 2.1: Storage Service (Hive/GetStorage)
- [x] Implement local data persistence layer
- **Files**:
  - `lib/services/storage_service.dart`

**_Prompt**:
```
Role: Backend Engineer
Task: Create a StorageService class that provides CRUD operations for all data models. Use Hive for key-value storage with automatic serialization. Implement methods: saveStudentProfile, loadStudentProfile, savePracticeSession, getPracticeSessions, saveAchievement, getAchievements, clearAllData, backupData, restoreData. Include error handling for corrupted data with auto-recovery.
Restrictions: StorageService should be a singleton. No UI logic in this service. Async operations with proper error handling.
_Leverage: Hive BoxCollection for organizing data, encrypting sensitive user data
_Requirements: US-007 (Performance Analytics), NFR-003 (Security & Privacy)
Success: Data persists across app restarts, CRUD operations work correctly, corruption recovery works, no data loss.
Instructions: Mark this task as in-progress [-] in tasks.md, then after implementation, use log-implementation to record storage service creation, then mark as completed [x].
```

### Task 2.2: Audio Service
- [x] Implement sound effects management
- **Files**:
  - `lib/services/audio_service.dart`

**_Prompt**:
```
Role: Audio Engineer
Task: Create an AudioService that handles all sound effects (correct answer, incorrect answer, level up, button click). Load audio assets from assets/sounds/ directory. Implement methods: playCorrectSound, playIncorrectSound, playLevelUpSound, playClickSound, toggleMute, setVolume. Auto-detect device mute status and respect system audio settings. Include fallback silent mode if audio fails.
Restrictions: Single instance (singleton). Audio must not block UI. All sounds should have configurable volume.
_Leverage: just_audio package with platform-specific optimizations
_Requirements: US-004 (Kid-Friendly UI)
Success: All sound effects play correctly, mute toggle works, app responds to system audio settings, silent mode fallback works.
Instructions: Mark this task as in-progress [-] in tasks.md, then after implementation, use log-implementation to record audio service creation, then mark as completed [x].
```

### Task 2.3: Game Controller (Core Logic)
- [x] Implement problem generation and answer validation
- **Files**:
  - `lib/controllers/game_controller.dart`
  - `lib/controllers/problem_generator.dart`
  - `lib/controllers/streak_tracker.dart`

**_Prompt**:
```
Role: Game Logic Engineer
Task: Create GameController that manages the practice session flow. Implement ProblemGenerator that creates random problems based on difficulty level and operation type. Generate problems that don't repeat within a session. Implement StreakTracker that counts consecutive correct answers and applies streak bonuses (2x = 1.1x, 3x = 1.2x, 5x = 1.5x). Create AnswerValidator that checks correctness and calculates points (base + speed bonus). Handle timer countdown and auto-submit after timeout.
Restrictions: Problem generation must be instant (<100ms). No duplicate problems in a session. Division problems must result in whole numbers. Streak must reset on incorrect answer.
_Leverage: Random number generation, time measurement utilities
_Requirements: US-005 (Multiple Operations), US-003 (Points System), US-006 (Practice Session)
Success: Problems generate correctly per difficulty, answer validation accurate, streak tracking correct, points calculated with all bonuses, timer works and auto-submits.
Instructions: Mark this task as in-progress [-] in tasks.md, then after implementation, use log-implementation to record game logic creation, then mark as completed [x].
```

### Task 2.4: Progress Tracker & Achievement Manager
- [x] Implement level progression and achievement system
- **Files**:
  - `lib/controllers/progress_tracker.dart`
  - `lib/controllers/achievement_manager.dart`

**_Prompt**:
```
Role: Game Designer
Task: Create ProgressTracker that monitors student performance and handles auto-leveling. Track accuracy per operation type. When student achieves 85%+ accuracy on 10+ consecutive problems, automatically unlock next level. Create AchievementManager that tracks and unlocks achievements: 100 Points, 500 Points, 1000 Points, 5-Streak, 10-Streak, Week Warrior (7 days practice), Math Genius (90%+ accuracy). Include badge image associations.
Restrictions: Progression threshold is exactly 85% on minimum 10 problems. Cannot skip more than 1 level ahead. Users cannot regress levels voluntarily.
_Leverage: DateTime for tracking practice patterns, achievement badge assets
_Requirements: US-002 (Auto-Progression), US-003 (Points System)
Success: Level progression accurate at 85% threshold, achievements unlock correctly, no skipped levels, progression persists.
Instructions: Mark this task as in-progress [-] in tasks.md, then after implementation, use log-implementation to record trackers creation, then mark as completed [x].
```

### Task 2.5: State Providers (Provider/Riverpod)
- [x] Create reactive state management
- **Files**:
  - `lib/providers/student_provider.dart`
  - `lib/providers/game_provider.dart`
  - `lib/providers/statistics_provider.dart`

**_Prompt**:
```
Role: State Management Architect
Task: Create provider classes using Flutter Provider package that expose reactive state streams: StudentProvider (current profile, points, level), GameProvider (current session, current problem, streak), StatisticsProvider (per-operation accuracy, historical data). Use ChangeNotifier or StateNotifier for state updates. Ensure UI automatically updates when state changes.
Restrictions: Providers should be singleton. State mutations only through defined methods. All async operations properly handled.
_Leverage: Provider package best practices, ChangeNotifier lifecycle management
_Requirements: All user stories for state persistence
Success: Providers expose correct state, UI updates reactively on state changes, no memory leaks, state persists with storage service.
Instructions: Mark this task as in-progress [-] in tasks.md, then after implementation, use log-implementation to record providers creation, then mark as completed [x].
```

---

## Phase 3: UI Screens

### Task 3.1: Home Screen
- [x] Implement main home screen with navigation
- **Files**:
  - `lib/screens/home_screen.dart`
  - `lib/widgets/stats_display.dart`
  - `lib/widgets/achievement_preview.dart`

**_Prompt**:
```
Role: UI Developer
Task: Create HomeScreen that displays: welcome message with student name, current level with star icon, total points with money icon, weekly stats breakdown (addition/subtraction/multiplication/division accuracy), and 3 achievement preview badges. Include prominent "Start Practice" button and settings icon. Layout should match design.md specification. Use responsive design that works on phones 4.5"-7" screens.
Restrictions: Text must use theme typography. All colors from color palette. Button minimum 48x48 dp. Animations smooth (60 FPS). No hardcoded values - use theme constants.
_Leverage: ListView for scrollable content, GridView for achievement badges, responsive sizing
_Requirements: US-001, US-003, US-007
Success: HomeScreen displays all data correctly, navigation works, responsive on different screen sizes, smooth animations, all stats update when data changes.
Instructions: Mark this task as in-progress [-] in tasks.md, then after implementation, use log-implementation to record home screen creation, then mark as completed [x].
```

### Task 3.2: Difficulty Selector Screen
- [x] Implement difficulty level selection UI
- **Files**:
  - `lib/screens/difficulty_selector_screen.dart`
  - `lib/widgets/difficulty_card.dart`

**_Prompt**:
```
Role: UI Developer
Task: Create DifficultySelector screen displaying all 4 difficulty levels with radio-button style selection. Each card shows: level number, name, number range description, points per answer, and lock status. Current level should be checked, unlocked levels selectable, locked levels show unlock requirement. Include "Start Practice" and "Cancel" buttons. Allow operation type selection (checkboxes for +, -, ×, ÷).
Restrictions: Match design.md layout exactly. Cards must be large and touch-friendly. Must show progress toward next level unlock.
_Leverage: Radio widgets for selection, Card widgets, Column/Row layouts
_Requirements: US-001 (Difficulty Selection), US-002 (Level Progression)
Success: All difficulty levels display correctly with accurate lock status, selection works, operation selection works, visual feedback on selection.
Instructions: Mark this task as in-progress [-] in tasks.md, then after implementation, use log-implementation to record difficulty selector creation, then mark as completed [x].
```

### Task 3.3: Practice Session Screen
- [x] Implement main practice interface
- **Files**:
  - `lib/screens/practice_session_screen.dart`
  - `lib/widgets/problem_display.dart`
  - `lib/widgets/answer_input.dart`
  - `lib/widgets/timer_display.dart`
  - `lib/widgets/streak_indicator.dart`

**_Prompt**:
```
Role: UI Developer
Task: Create PracticeSession screen with: timer countdown (30 sec) at top-right, problem counter (e.g., "3/10"), flame-based streak indicator, large math problem display (operand1 OPERATOR operand2), answer input field with auto-focus, submit button, skip button. Layout matches design.md specification. Timer auto-submits when reaches 0. Visual feedback for timer warning (<5 sec, orange color).
Restrictions: Problem must be large and centered. Timer visible and prominent. Touch-friendly input. Animations smooth. No auto-advance - wait for submit/skip.
_Leverage: Countdown timer, TextEditingController, gesture detection
_Requirements: US-006 (Practice Session), US-003 (Points)
Success: Timer counts down correctly, auto-submits on timeout, input accepts numbers only, submit/skip buttons work, streak displays correctly, problem updates correctly.
Instructions: Mark this task as in-progress [-] in tasks.md, then after implementation, use log-implementation to record practice session screen creation, then mark as completed [x].
```

### Task 3.4: Answer Feedback Screen
- [x] Implement answer validation feedback UI
- **Files**:
  - `lib/screens/answer_feedback_screen.dart`
  - `lib/widgets/feedback_animation.dart`
  - `lib/widgets/points_display.dart`

**_Prompt**:
```
Role: UI Developer / Animation Engineer
Task: Create modal/dialog that displays after answer submission. For correct answers: show checkmark ✅, "Correct!" message, points earned breakdown (base + bonuses), updated streak count, celebratory animation (confetti), "Next Problem" button. For incorrect answers: show ❌, "Not Quite!", student answer vs correct answer, broken streak indicator, problem explanation, "Try Again" and "Skip" buttons. Animations must follow design specifications (0.3-0.5s for feedback, confetti 3-5s for celebrations).
Restrictions: Animations GPU-accelerated. No blocking UI. Auto-close after 5 seconds (optional). Audio feedback integrated.
_Leverage: Lottie for complex animations, CustomPaint for confetti, AnimationController
_Requirements: US-003, US-004, US-006
Success: Correct feedback shows celebration with animations, incorrect shows explanation, points calculated correctly, audio plays, confetti animates smoothly.
Instructions: Mark this task as in-progress [-] in tasks.md, then after implementation, use log-implementation to record feedback screen creation, then mark as completed [x].
```

### Task 3.5: Session Results Screen
- [x] Implement end-of-session summary
- **Files**:
  - `lib/screens/session_results_screen.dart`
  - `lib/widgets/results_stats.dart`
  - `lib/widgets/level_up_banner.dart`

**_Prompt**:
```
Role: UI Developer
Task: Create SessionResults screen displayed when session ends. Show: accuracy percentage with progress bar, time taken, total points earned, best streak during session, average response time, performance by operation (if mixed operations). Include optional "Level Up!" banner if progression threshold met. Statistics saved to storage. Include "Practice Again" and "Back to Home" buttons.
Restrictions: Stats must match calculation logic. Progress bar should fill based on accuracy. Banner animation if level up. All data persisted.
_Leverage: LinearProgressIndicator for accuracy, Chart/Graph widget (optional), Hero animation for banner
_Requirements: US-003, US-007
Success: Accurate stats display, progress bar correct, level up banner shows when qualified, data persisted, navigation works.
Instructions: Mark this task as in-progress [-] in tasks.md, then after implementation, use log-implementation to record results screen creation, then mark as completed [x].
```

### Task 3.6: Progress Dashboard
- [x] Implement statistics and analytics screen
- **Files**:
  - `lib/screens/progress_dashboard_screen.dart`
  - `lib/widgets/operation_stats_card.dart`
  - `lib/widgets/progress_chart.dart`

**_Prompt**:
```
Role: UI Developer / Data Visualization Engineer
Task: Create ProgressDashboard showing weekly/monthly statistics: total points earned this week, problems solved, average accuracy, breakdown by operation type (accuracy%, problem count), level progression bar, achievements earned. Use charts or simple visual representations (progress bars, pie chart). Include filter for time period (this week, this month, all time).
Restrictions: Use simple, kid-friendly visualizations. No complex charts. Data aggregated from storage. Read-only view.
_Leverage: Charts package or CustomPaint, aggregation logic from statistics_provider
_Requirements: US-007 (Performance Analytics)
Success: All statistics calculated correctly, visual displays accurate data, filtering works, responsive on different screens.
Instructions: Mark this task as in-progress [-] in tasks.md, then after implementation, use log-implementation to record dashboard creation, then mark as completed [x].
```

### Task 3.7: Settings Screen
- [x] Implement user preferences and app settings
- **Files**:
  - `lib/screens/settings_screen.dart`
  - `lib/widgets/toggle_switch.dart`

**_Prompt**:
```
Role: UI Developer
Task: Create Settings screen with: toggle for sound effects, option to clear all data (with confirmation), view app version, view privacy policy, reset profile (with confirmation), change student name. Include visual toggle switches with clear on/off states. All settings immediately take effect.
Restrictions: Destructive actions require confirmation. No analytics or tracking without permission. Settings persisted in storage.
_Leverage: SharedPreferences or StorageService, Switch/Checkbox widgets
_Requirements: US-004, NFR-003 (Privacy)
Success: Toggles work correctly, settings persist, destructive actions confirmed, all functionality works.
Instructions: Mark this task as in-progress [-] in tasks.md, then after implementation, use log-implementation to record settings screen creation, then mark as completed [x].
```

---

## Phase 4: Integration & Polish

### Task 4.1: Navigation & Routing
- [x] Implement app navigation structure
- **Files**:
  - `lib/main.dart` (update)
  - `lib/config/routes.dart`

**_Prompt**:
```
Role: Mobile Architect
Task: Set up Flutter navigation using Navigator 2.0 or GoRouter. Define routes for: home, difficulty_selector, practice_session, answer_feedback, session_results, progress_dashboard, settings. Implement proper navigation flow with proper state preservation. Back button behavior should respect current screen context.
Restrictions: Navigation must be predictable and consistent. No dead ends.
_Leverage: GoRouter for cleaner routing or Navigator 2.0
_Requirements: All screens from Phase 3
Success: Navigation between all screens works seamlessly, back button behavior correct, state preserved on navigation.
Instructions: Mark this task as in-progress [-] in tasks.md, then after implementation, use log-implementation to record navigation setup, then mark as completed [x].
```

### Task 4.2: Initial Data Setup & Onboarding
- [x] Implement first-run initialization
- **Files**:
  - `lib/screens/splash_screen.dart`
  - `lib/controllers/app_initializer.dart`

**_Prompt**:
```
Role: UX Engineer
Task: Create Splash/Loading screen shown on first app launch. Implement AppInitializer that checks if user has existing profile, loads it, or creates new profile. Collect student name on first run. Initialize all services (storage, audio, analytics). Show loading progress.
Restrictions: Splash should be quick (<2 seconds). No blocking operations on main thread.
_Leverage: FutureBuilder for async initialization, shared_preferences for first-run detection
_Requirements: US-004
Success: First-run onboarding smooth, profile created correctly, name input works, all services initialized, app ready for practice.
Instructions: Mark this task as in-progress [-] in tasks.md, then after implementation, use log-implementation to record onboarding implementation, then mark as completed [x].
```

### Task 4.3: Testing & QA
- [x] Create unit tests for core logic
- **Files**:
  - `test/controllers/problem_generator_test.dart`
  - `test/controllers/game_controller_test.dart`
  - `test/controllers/progress_tracker_test.dart`

**_Prompt**:
```
Role: QA Engineer
Task: Write comprehensive unit tests for: problem generation (correct ranges, no repeats, division whole numbers), answer validation (correct/incorrect, point calculations, streak tracking), level progression (85% threshold, 10-problem minimum), achievement unlocking. Test edge cases (streak reset, level cap, exact threshold). Aim for 80%+ code coverage of core logic.
Restrictions: Tests must be deterministic and fast. No UI testing yet.
_Leverage: Flutter test framework, Mockito for mocking services
_Requirements: All business logic requirements
Success: All tests pass, core logic verified correct, no regression risks.
Instructions: Mark this task as in-progress [-] in tasks.md, then after implementation, use log-implementation to record test creation, then mark as completed [x].
```

### Task 4.4: Widget Testing
- [x] Create widget tests for screens
- **Files**:
  - `test/screens/home_screen_test.dart`
  - `test/screens/difficulty_selector_test.dart`
  - `test/screens/practice_session_test.dart`

**_Prompt**:
```
Role: QA Engineer
Task: Write widget tests for main screens: HomeScreen (displays stats correctly, buttons work), DifficultySelector (selection works, level locks work), PracticeSession (timer works, input works, feedback shows). Use WidgetTester to pump widgets and verify behavior. Mock providers/services.
Restrictions: Tests should be fast and reliable. No flaky timing tests.
_Leverage: flutter_test, mockito, pump/pumpWidget
_Requirements: UI requirements from user stories
Success: All critical user flows tested, no regressions.
Instructions: Mark this task as in-progress [-] in tasks.md, then after implementation, use log-implementation to record widget tests creation, then mark as completed [x].
```

### Task 4.5: Accessibility Audit
- [x] Verify accessibility compliance
- **Files**:
  - `lib/config/accessibility_config.dart`
  - `lib/utils/accessibility_helpers.dart`
  - `test/accessibility/accessibility_test.dart`

**_Prompt**:
```
Role: Accessibility Specialist
Task: Audit app for WCAG 2.1 AA compliance: color contrast ratios (4.5:1), touch targets (48x48 dp), semantic labels for screen readers, focus navigation, text scaling support. Test on different font sizes (100%-200%). Verify dark mode support. Test with accessibility scanner.
Restrictions: No changes to visual design - only ensure existing design meets standards. Fix any violations found.
_Leverage: Flutter accessibility tools, accessibility_testing_widget package
_Requirements: NFR-002 (Accessibility)
Success: 100% WCAG 2.1 AA compliance verified, color contrast correct, touch targets adequate, screen reader support works.
Instructions: Mark this task as in-progress [-] in tasks.md, then after implementation, use log-implementation to record accessibility audit, then mark as completed [x].
```

### Task 4.6: Performance Optimization
- [x] Optimize app for smooth performance
- **Files**:
  - `lib/utils/performance_monitor.dart`
  - `lib/controllers/optimized_problem_generator.dart`
  - `lib/utils/lazy_loader.dart`
  - `lib/utils/resource_disposer.dart`
  - `lib/widgets/performance_overlay.dart`
  - `lib/config/performance_config.dart`
  - `test/performance/performance_test.dart`

**_Prompt**:
```
Role: Performance Engineer
Task: Profile app for performance: ensure problem generation <100ms, animations 60 FPS, app startup <2 seconds, no memory leaks. Use Flutter DevTools to measure. Optimize problem generation with batch pre-generation, lazy-load historical data, dispose resources properly. Implement frame rate monitoring.
Restrictions: No functionality changes, only optimizations. Maintain smooth experience.
_Leverage: Flutter DevTools, profiling tools, memory analysis
_Requirements: NFR-001 (Performance)
Success: All performance targets met, app runs smoothly, no jank, memory stable.
Instructions: Mark this task as in-progress [-] in tasks.md, then after implementation, use log-implementation to record performance optimizations, then mark as completed [x].
```

### Task 4.7: Build & Deployment Preparation
- [x] Prepare for app store release
- **Files**:
  - `android/app/build.gradle` (update)
  - `ios/Runner.xcodeproj` (update)
  - App signing configuration

**_Prompt**:
```
Role: DevOps Engineer
Task: Configure app for release: update version numbers, create app icons (all sizes for iOS/Android), create app screenshots for store listings, configure app signing for iOS/Android, set up ProGuard/R8 for Android release builds. Create release notes and app store descriptions.
Restrictions: Must follow platform guidelines (Apple App Store, Google Play).
_Leverage: Flutter build tools, official platform guidelines
_Requirements: All requirements - release-ready state
Success: App builds in release mode, signing configured, ready for app store submission.
Instructions: Mark this task as in-progress [-] in tasks.md, then after implementation, use log-implementation to record build preparation, then mark as completed [x].
```

---

## Summary

**Total Tasks**: 20
- Phase 1 (Setup): 3 tasks
- Phase 2 (Logic): 5 tasks
- Phase 3 (UI): 6 tasks
- Phase 4 (Integration): 6 tasks

**Estimated Effort**: 4-6 weeks for single developer
**Dependencies**: None between phases, but Phase 1 required before Phase 2, Phase 2 before Phase 3

**Success Criteria for Full Completion**:
- All 20 tasks marked [x]
- App builds successfully for iOS and Android
- All user stories implemented
- All non-functional requirements met
- Unit test coverage >80%
- Widget tests for critical flows
- Ready for app store submission
