# Math Practice App - Quick Reference

## 📊 Key Metrics at a Glance

### Difficulty Levels
```
Level 1: 1-9       → 10 pts/correct
Level 2: 10-99     → 15 pts/correct
Level 3: 100-999   → 20 pts/correct
Level 4+: 1000+    → 25 pts/correct
```

### Progression Requirements
```
Threshold: 85% accuracy on 10+ consecutive problems
Auto-unlock next level
Max skip ahead: 1 level only
No regression allowed
```

### Bonus System
```
Speed Bonus: +20% points (within 30 sec)
Streak Bonuses:
  - 2 correct: 1.1x multiplier
  - 3 correct: 1.2x multiplier
  - 5 correct: 1.5x multiplier
```

### Time Limits
```
Per Problem: 30 seconds
Auto-submit: On timeout (counts as incorrect)
Min session: 5 problems
Max session: 30 problems (or 15 minutes)
```

### Achievements
```
🥇 100 Points Club
🥈 500 Points Club
🥉 1000 Points Club
🔥 5-Streak Master
🔥🔥 10-Streak Master
📅 Week Warrior (7 days practice)
🧮 Math Genius (90%+ accuracy)
```

---

## 🎨 Design System

### Color Palette
```
Primary Blue:     #2196F3  (Buttons, accents)
Success Green:    #4CAF50  (Correct answers)
Error Red:        #F44336  (Incorrect answers)
Warning Orange:   #FF9800  (Time warnings)
Accent Gold:      #FFB81C  (Points, badges)
Light Gray:       #F5F5F5  (Background)
Dark Gray:        #212121  (Text)
```

### Typography
```
Title:           Roboto 28px Bold
Math Display:    Roboto 48px Bold
Buttons:         Roboto 18px Medium
Body:            Roboto 16px Regular
Small:           Roboto 12px Regular
```

### Animations
```
Feedback:        0.3-0.5 seconds
Confetti:        3-5 seconds
Button Tap:      0.1-0.2 seconds
Level Up:        2+ seconds (full screen)
```

---

## 📱 Screen Layout Reference

### Home Screen
```
┌─────────────────────────┐
│ 🎓 Math Master [⚙️]    │
├─────────────────────────┤
│ Welcome, [Name]!        │
│ ⭐ Level 2              │
│ 💰 1,250 Points         │
├─────────────────────────┤
│ [Start Practice]        │
├─────────────────────────┤
│ 📊 Stats & Achievements │
└─────────────────────────┘
```

### Practice Screen
```
┌─────────────────────────┐
│ ← 3/10 ⏱️ 0:30         │
│ 🔥 3 Streak             │
├─────────────────────────┤
│       8                 │
│     ×   2               │
│    ──────────           │
│    [ ? ]                │
│                         │
│ [16] [14] [10]          │
│ [Submit]                │
└─────────────────────────┘
```

---

## 📂 Critical Files by Phase

### Phase 1: Models & Setup
```
lib/models/
  ├── student_profile.dart
  ├── difficulty_level.dart
  ├── math_problem.dart
  └── practice_session.dart

lib/config/difficulty_config.dart
lib/utils/theme.dart
lib/utils/colors.dart
```

### Phase 2: Logic
```
lib/controllers/
  ├── game_controller.dart
  ├── problem_generator.dart
  ├── progress_tracker.dart
  └── achievement_manager.dart

lib/services/
  ├── storage_service.dart
  └── audio_service.dart
```

### Phase 3: UI
```
lib/screens/
  ├── home_screen.dart
  ├── difficulty_selector_screen.dart
  ├── practice_session_screen.dart
  ├── answer_feedback_screen.dart
  └── session_results_screen.dart

lib/widgets/
  ├── problem_display.dart
  ├── feedback_animation.dart
  └── streak_indicator.dart
```

---

## 🔄 Data Flow

```
User Opens App
    ↓
Load StudentProfile from Storage
    ↓
Show Home Screen (Level, Points, Stats)
    ↓
User Selects Difficulty & Operations
    ↓
Generate Practice Problems
    ↓
User Submits Answer
    ↓
Validate Answer
    ↓
Calculate Points (Base + Bonuses)
    ↓
Update Streak & Statistics
    ↓
Check Level Progression (85% on 10?)
    ↓
Check Achievement Unlocks
    ↓
Save to Storage
    ↓
Show Feedback (Correct/Incorrect)
    ↓
Next Problem OR Session Complete
    ↓
Show Results Screen
    ↓
Save Session to Statistics
    ↓
Return to Home
```

---

## 🧪 Testing Checklist

### Core Logic Tests
- [ ] Problem generation (ranges, no repeats)
- [ ] Answer validation (correct/incorrect)
- [ ] Point calculations (base + bonuses)
- [ ] Streak tracking (increment/reset)
- [ ] Level progression (85% threshold)
- [ ] Achievement unlocking

### UI Tests
- [ ] Home screen displays correctly
- [ ] Difficulty selection works
- [ ] Practice session flow works
- [ ] Feedback displays correctly
- [ ] Results screen shows accurate data
- [ ] Navigation between screens

### Edge Cases
- [ ] Exact 85% accuracy (should advance)
- [ ] 84.9% accuracy (should not advance)
- [ ] Streak reset on incorrect answer
- [ ] Division by zero prevention
- [ ] Time limit auto-submit
- [ ] Invalid input handling

---

## 🚀 Deployment Checklist

- [ ] App builds for iOS (release mode)
- [ ] App builds for Android (release mode)
- [ ] All signing configured
- [ ] Icons created (all sizes)
- [ ] Screenshots prepared
- [ ] Privacy policy written
- [ ] COPPA compliance verified
- [ ] No hardcoded test data
- [ ] Analytics configured (if enabled)
- [ ] Crash reporting configured (if enabled)

---

## 📋 Tasks Status Template

Use this to track progress through the 20 tasks:

```
Phase 1: Setup & Models
- [ ] 1.1 Flutter Project Init
- [ ] 1.2 Data Models
- [ ] 1.3 Theme & Utilities

Phase 2: State Management
- [ ] 2.1 Storage Service
- [ ] 2.2 Audio Service
- [ ] 2.3 Game Controller
- [ ] 2.4 Progress Tracker
- [ ] 2.5 State Providers

Phase 3: UI Screens
- [ ] 3.1 Home Screen
- [ ] 3.2 Difficulty Selector
- [ ] 3.3 Practice Session
- [ ] 3.4 Answer Feedback
- [ ] 3.5 Session Results
- [ ] 3.6 Progress Dashboard

Phase 4: Integration
- [ ] 4.1 Navigation
- [x] 4.2 Onboarding
- [x] 4.3 Unit Tests
- [ ] 4.4 Widget Tests
- [ ] 4.5 Accessibility
- [ ] 4.6 Performance
- [ ] 4.7 Build & Deployment
```

---

## 📞 Common Questions

**Q: What Flutter version should I use?**
A: 3.0+ recommended. Uses Material Design 3 and latest Dart features.

**Q: Can I use GetX instead of Provider?**
A: Yes, but update all state management code accordingly.

**Q: What about division by remainders?**
A: Start with whole number division only (no remainders). Can add remainder handling in future versions.

**Q: How do I handle offline mode?**
A: All data stored locally with Hive. No internet required.

**Q: Can I add more than 4 difficulty levels?**
A: Yes, but design spec recommends max 4-5 for primary students.

**Q: How do I implement cloud sync?**
A: Add Firebase Firestore integration after Phase 2. StorageService acts as abstraction layer.

---

## 🎓 Learning Resources

- **Spec Workflow Docs**: `.spec-workflow/specs/math-practice-app/`
- **Flutter Docs**: https://flutter.dev/docs
- **State Management**: https://flutter.dev/docs/development/data-and-backend/state-mgmt/intro
- **Testing**: https://flutter.dev/docs/testing
- **Accessibility**: https://flutter.dev/docs/development/accessibility-and-localization

---

**Last Updated**: December 24, 2025
