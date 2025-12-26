# Math Practice App - Specification & Implementation Guide

## 📱 Project Overview

A kid-friendly Flutter application for primary school students (ages 5-12) to practice basic arithmetic operations with:
- **Adaptive Difficulty Levels** (single digits → thousands)
- **Auto-Progression System** (advance when 85%+ accuracy achieved)
- **Gamification** (points, streaks, achievements, leaderboards)
- **Kid-Friendly UI** (colorful, engaging, appropriate for children)

## 📋 Specification Documents

All specification documents are located in `.spec-workflow/specs/math-practice-app/`:

### 1. **Requirements** ([.spec-workflow/specs/math-practice-app/requirements.md](.spec-workflow/specs/math-practice-app/requirements.md))
Comprehensive user stories covering:
- Difficulty level selection (US-001)
- Auto-progression through levels (US-002)
- Points and rewards system (US-003)
- Kid-friendly UI (US-004)
- Multiple arithmetic operations (US-005)
- Practice session management (US-006)
- Performance analytics (US-007)

**Key Metrics**:
- 4 difficulty levels (1-9, 10-99, 100-999, 1000+)
- 10/15/20/25 points per correct answer by level
- 85% accuracy threshold for level progression
- Streak bonuses (2x=1.1x, 3x=1.2x, 5x=1.5x)
- 30-second time limit per problem
- Speed bonus (20% extra points)

---

### 2. **Design** ([.spec-workflow/specs/math-practice-app/design.md](.spec-workflow/specs/math-practice-app/design.md))
Complete technical architecture including:
- **System Architecture** (3-layer architecture: Presentation → Business Logic → Data)
- **Data Models** (StudentProfile, DifficultyLevel, MathProblem, PracticeSession, Achievement, etc.)
- **UI Screens** (7 main screens with layout specifications)
- **Color Palette** (Bright Blue, Green, Red, Orange, Gold)
- **Typography** (Roboto, sizes 12-48px)
- **Animations** (0.3-0.5s feedback, confetti, streak indicators)
- **File Structure** (lib/, assets/ organization)
- **State Management Flow** (User Input → Validation → Points → Update UI)

**Technology Stack**:
- Flutter 3.0+, Dart 3.0+
- Provider for state management
- Hive for local storage
- Just_audio for sound effects
- Lottie for complex animations

---

### 3. **Implementation Tasks** ([.spec-workflow/specs/math-practice-app/tasks.md](.spec-workflow/specs/math-practice-app/tasks.md))
Detailed breakdown of 20 atomic implementation tasks across 4 phases:

**Phase 1: Setup & Models** (3 tasks)
- [ ] Flutter project initialization
- [ ] Create data models
- [ ] Create theme & utilities

**Phase 2: State Management** (5 tasks)
- [ ] Storage service
- [ ] Audio service
- [ ] Game controller (core logic)
- [ ] Progress tracker & achievements
- [ ] State providers

**Phase 3: UI Screens** (6 tasks)
- [ ] Home screen
- [ ] Difficulty selector
- [ ] Practice session
- [ ] Answer feedback
- [ ] Session results
- [ ] Progress dashboard

**Phase 4: Integration & Polish** (6 tasks)
- [ ] Navigation & routing
- [ ] Onboarding
- [ ] Unit tests
- [ ] Widget tests
- [ ] Accessibility audit
- [ ] Performance optimization
- [ ] Build & deployment

---

## 🚀 Getting Started

### Prerequisites
```bash
# Install Flutter SDK 3.0+
# Install Dart 3.0+
# Have Android Studio or Xcode installed
```

### Project Setup

1. **Initialize Flutter Project**:
```bash
cd c:\ZJB\aimath
flutter pub get
flutter pub run build_runner build  # For Hive code generation
```

2. **Create Asset Directories**:
```bash
mkdir -p assets/images/badges
mkdir -p assets/images/icons
mkdir -p assets/images/illustrations
mkdir -p assets/sounds
mkdir -p assets/animations
mkdir -p assets/fonts
```

3. **Run the App**:
```bash
flutter run
```

---

## 📂 Project Structure

```
aimath/
├── .spec-workflow/
│   └── specs/
│       └── math-practice-app/
│           ├── requirements.md      # User stories & acceptance criteria
│           ├── design.md            # Technical architecture
│           └── tasks.md             # Implementation tasks
├── lib/
│   ├── main.dart                    # App entry point
│   ├── models/                      # Data models
│   ├── screens/                     # UI screens
│   ├── controllers/                 # Business logic
│   ├── services/                    # Services (storage, audio, etc.)
│   ├── widgets/                     # Reusable UI widgets
│   ├── providers/                   # State management
│   ├── utils/                       # Constants, helpers, theme
│   └── config/                      # Configuration files
├── assets/
│   ├── images/                      # PNG/SVG images
│   ├── sounds/                      # MP3 audio files
│   ├── animations/                  # Lottie JSON files
│   └── fonts/                       # Custom fonts
├── test/
│   ├── controllers/                 # Unit tests for logic
│   └── screens/                     # Widget tests for UI
├── pubspec.yaml                     # Dependencies
└── README.md                        # This file
```

---

## 🎨 Key Features

### 1. Difficulty Levels
| Level | Name | Range | Points | Time |
|-------|------|-------|--------|------|
| 1 | Single Digits | 1-9 | 10 | 30s |
| 2 | Two Digits | 10-99 | 15 | 30s |
| 3 | Three Digits | 100-999 | 20 | 30s |
| 4+ | Four+ Digits | 1000+ | 25 | 30s |

### 2. Gamification System
- **Points**: Base points by difficulty + 20% speed bonus
- **Streaks**: 2x=1.1x, 3x=1.2x, 5x=1.5x multipliers
- **Achievements**: 100/500/1000 Points, 5/10 Streak, Week Warrior, Math Genius
- **Leaderboard**: Weekly/monthly rankings (privacy-preserving)

### 3. Auto-Progression
- Track accuracy per difficulty level
- Advance when: 85%+ accuracy on 10+ consecutive problems
- Unlock next level automatically
- Celebratory animation on level up

### 4. Kid-Friendly Design
- Bright, warm color scheme
- Large touch targets (48x48 dp minimum)
- Celebratory animations (confetti, stars)
- Encouraging messages and emojis
- Audio feedback (toggle-able)
- No ads or distracting elements

---

## 🔧 Implementation Roadmap

### Week 1-2: Foundation
- Set up Flutter project
- Create data models
- Implement storage service
- Set up state management

### Week 3: Core Logic
- Implement problem generation
- Answer validation & points calculation
- Streak tracking
- Level progression logic

### Week 4-5: UI Implementation
- Implement 7 main screens
- Add animations and feedback
- Integrate audio system
- Navigation setup

### Week 6: Polish & Testing
- Unit tests (80%+ coverage)
- Widget tests (critical flows)
- Accessibility audit
- Performance optimization
- App store preparation

---

## 📊 Code Statistics (Target)

- **Dart Code**: ~5,000-7,000 lines
- **Test Code**: ~2,000-3,000 lines
- **UI Screens**: 7 main screens
- **Data Models**: 7 model classes
- **Services**: 3-4 service classes
- **Widgets**: 15-20 custom widgets

---

## ✅ Quality Checklist

### Functional Requirements
- [ ] All 7 user stories implemented
- [ ] 4 difficulty levels with correct ranges
- [ ] Auto-progression at 85% on 10 problems
- [ ] Points calculated with bonuses
- [ ] Streak tracking works correctly
- [ ] Achievements unlock properly

### Non-Functional Requirements
- [ ] WCAG 2.1 AA accessibility compliance
- [ ] 60 FPS animations
- [ ] <2 second startup time
- [ ] Problem generation <100ms
- [ ] No memory leaks
- [ ] Offline support (local storage)

### Testing
- [ ] 80%+ unit test coverage
- [ ] Critical UI flows tested
- [ ] Edge cases covered
- [ ] No regressions

### Deployment
- [ ] App signing configured
- [ ] Icons for iOS/Android
- [ ] Screenshots for app stores
- [ ] Release notes prepared
- [ ] Privacy policy included

---

## 🎯 Success Metrics

1. **Engagement**: Students use app 3-4x/week
2. **Learning**: 85%+ accuracy improvement in 2 weeks
3. **Retention**: Progress 2+ levels in 1 month
4. **Satisfaction**: 4.5+/5.0 star rating
5. **Parent Approval**: 80%+ report improved math confidence

---

## 📝 Notes

- All specifications follow the spec-workflow methodology
- Tasks are atomic and can be implemented independently
- Each task includes implementation guidance in the `_Prompt` field
- Progress is tracked via task completion markers ([ ], [-], [x])
- Implementation details are logged in the `Implementation Logs/` directory

---

## 🤝 Contributing

When implementing tasks:
1. Read the full requirements, design, and task specifications
2. Update task status: `[ ]` → `[-]` (in-progress) → `[x]` (complete)
3. Log implementation details with artifacts
4. Test thoroughly before marking complete
5. Ensure no regression in existing functionality

---

## 📖 Additional Resources

- [Flutter Official Documentation](https://flutter.dev/docs)
- [Material Design 3 Guidelines](https://m3.material.io/)
- [WCAG 2.1 Accessibility](https://www.w3.org/WAI/WCAG21/quickref/)
- [Flutter Testing Guide](https://flutter.dev/docs/testing)

---

**Project Start Date**: December 24, 2025  
**Framework**: Flutter 3.0+  
**Target Platforms**: iOS 12.0+, Android 7.0+ (API 24)  
**Status**: Specification Phase Complete ✅
