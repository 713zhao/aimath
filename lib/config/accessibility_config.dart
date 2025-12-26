import 'package:flutter/material.dart';

/// Accessibility configuration for WCAG 2.1 AA compliance
class AccessibilityConfig {
  AccessibilityConfig._();

  // Minimum touch target size (48x48 dp per WCAG guidelines)
  static const double minTouchTargetSize = 48.0;

  // Minimum contrast ratio for normal text (4.5:1)
  static const double minContrastRatioNormal = 4.5;

  // Minimum contrast ratio for large text (3:1)
  static const double minContrastRatioLarge = 3.0;

  // Large text threshold (18sp or 14sp bold)
  static const double largeTextThreshold = 18.0;
  static const double largeTextBoldThreshold = 14.0;

  // Maximum text scale factor to support
  static const double maxTextScaleFactor = 2.0;

  // Focus indicator width
  static const double focusIndicatorWidth = 2.0;

  // Animation reduced motion check
  static bool shouldReduceMotion(BuildContext context) {
    return MediaQuery.of(context).disableAnimations;
  }

  // Get accessible text scale factor (capped for layout stability)
  static double getTextScaleFactor(BuildContext context) {
    final scale = MediaQuery.of(context).textScaleFactor;
    return scale.clamp(1.0, maxTextScaleFactor);
  }

  // Check if using large fonts
  static bool isUsingLargeFonts(BuildContext context) {
    return MediaQuery.of(context).textScaleFactor > 1.3;
  }
}

/// Semantic labels for screen readers
class SemanticLabels {
  SemanticLabels._();

  // Home Screen
  static const String homeScreen = 'Home screen';
  static const String welcomeMessage = 'Welcome message';
  static const String currentLevel = 'Current difficulty level';
  static const String totalPoints = 'Total points earned';
  static const String startPractice = 'Start practice session button';
  static const String settingsButton = 'Open settings';
  static const String progressDashboard = 'View progress dashboard';

  // Difficulty Selector
  static const String difficultySelector = 'Difficulty selection screen';
  static String difficultyLevel(int level, bool isLocked) {
    if (isLocked) {
      return 'Level $level, locked. Achieve 85% accuracy to unlock.';
    }
    return 'Level $level, available for selection';
  }
  static String difficultyLevelSelected(int level) {
    return 'Level $level selected';
  }
  static String operationType(String operation, bool isSelected) {
    return '$operation ${isSelected ? 'selected' : 'not selected'}';
  }

  // Practice Session
  static const String practiceScreen = 'Practice session screen';
  static String timer(int seconds) {
    if (seconds <= 5) {
      return 'Warning: $seconds seconds remaining';
    }
    return '$seconds seconds remaining';
  }
  static String problemCounter(int current, int total) {
    return 'Problem $current of $total';
  }
  static String mathProblem(int operand1, String operator, int operand2) {
    final opName = _operatorName(operator);
    return '$operand1 $opName $operand2 equals what?';
  }
  static String _operatorName(String operator) {
    switch (operator) {
      case '+':
        return 'plus';
      case '-':
        return 'minus';
      case '×':
        return 'times';
      case '÷':
        return 'divided by';
      default:
        return operator;
    }
  }
  static const String answerInput = 'Enter your answer';
  static const String submitAnswer = 'Submit answer';
  static const String skipProblem = 'Skip this problem';
  static String streak(int count) {
    if (count == 0) return 'No streak';
    if (count == 1) return '1 correct answer streak';
    return '$count correct answers streak';
  }

  // Feedback
  static const String correctAnswer = 'Correct answer! Well done!';
  static String incorrectAnswer(int correct) {
    return 'Incorrect. The correct answer was $correct';
  }
  static String pointsEarned(int points) {
    return 'You earned $points points';
  }
  static const String nextProblem = 'Continue to next problem';
  static const String tryAgain = 'Try again';

  // Results
  static const String sessionResults = 'Session results screen';
  static String accuracy(double percent) {
    return 'Accuracy: ${percent.toStringAsFixed(0)} percent';
  }
  static String totalPointsEarned(int points) {
    return 'Total points earned: $points';
  }
  static const String levelUp = 'Congratulations! You leveled up!';
  static const String practiceAgain = 'Start another practice session';
  static const String backToHome = 'Return to home screen';

  // Settings
  static const String settingsScreen = 'Settings screen';
  static String soundToggle(bool isOn) {
    return 'Sound effects ${isOn ? 'enabled' : 'disabled'}';
  }
  static const String clearData = 'Clear all data. This action cannot be undone.';
  static const String resetProfile = 'Reset profile. This action cannot be undone.';
  static const String changeName = 'Change student name';

  // Achievements
  static String achievement(String name, bool isUnlocked) {
    return '$name achievement ${isUnlocked ? 'unlocked' : 'locked'}';
  }
}

/// Extension to add accessibility wrapper to widgets
extension AccessibilityExtension on Widget {
  /// Wraps widget with Semantics for screen readers
  Widget withSemantics({
    required String label,
    String? hint,
    bool? button,
    bool? header,
    bool? enabled,
    VoidCallback? onTap,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      button: button,
      header: header,
      enabled: enabled,
      onTap: onTap,
      child: this,
    );
  }

  /// Ensures minimum touch target size
  Widget withMinTouchTarget() {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: AccessibilityConfig.minTouchTargetSize,
        minHeight: AccessibilityConfig.minTouchTargetSize,
      ),
      child: this,
    );
  }

  /// Excludes from semantics (for decorative elements)
  Widget excludeSemantics() {
    return ExcludeSemantics(child: this);
  }
}

/// Accessible button that meets touch target requirements
class AccessibleButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final String semanticLabel;
  final String? semanticHint;
  final ButtonStyle? style;

  const AccessibleButton({
    super.key,
    required this.onPressed,
    required this.child,
    required this.semanticLabel,
    this.semanticHint,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      hint: semanticHint,
      button: true,
      enabled: onPressed != null,
      child: ElevatedButton(
        onPressed: onPressed,
        style: (style ?? const ButtonStyle()).copyWith(
          minimumSize: WidgetStateProperty.all(
            const Size(
              AccessibilityConfig.minTouchTargetSize,
              AccessibilityConfig.minTouchTargetSize,
            ),
          ),
        ),
        child: child,
      ),
    );
  }
}

/// Accessible icon button that meets touch target requirements
class AccessibleIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String semanticLabel;
  final double? iconSize;
  final Color? color;

  const AccessibleIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.semanticLabel,
    this.iconSize,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: onPressed != null,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: iconSize, color: color),
        constraints: const BoxConstraints(
          minWidth: AccessibilityConfig.minTouchTargetSize,
          minHeight: AccessibilityConfig.minTouchTargetSize,
        ),
      ),
    );
  }
}

/// Accessible text field with proper labeling
class AccessibleTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final String? hint;
  final TextInputType? keyboardType;
  final bool autofocus;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;

  const AccessibleTextField({
    super.key,
    this.controller,
    required this.label,
    this.hint,
    this.keyboardType,
    this.autofocus = false,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      hint: hint,
      textField: true,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        autofocus: autofocus,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        focusNode: focusNode,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          contentPadding: const EdgeInsets.all(16),
        ),
        style: TextStyle(
          fontSize: 18 * AccessibilityConfig.getTextScaleFactor(context),
        ),
      ),
    );
  }
}

/// Color contrast checker utility
class ContrastChecker {
  ContrastChecker._();

  /// Calculate relative luminance of a color
  static double _relativeLuminance(Color color) {
    double r = color.red / 255;
    double g = color.green / 255;
    double b = color.blue / 255;

    r = r <= 0.03928 ? r / 12.92 : ((r + 0.055) / 1.055).pow(2.4);
    g = g <= 0.03928 ? g / 12.92 : ((g + 0.055) / 1.055).pow(2.4);
    b = b <= 0.03928 ? b / 12.92 : ((b + 0.055) / 1.055).pow(2.4);

    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  /// Calculate contrast ratio between two colors
  static double contrastRatio(Color foreground, Color background) {
    final l1 = _relativeLuminance(foreground);
    final l2 = _relativeLuminance(background);
    final lighter = l1 > l2 ? l1 : l2;
    final darker = l1 > l2 ? l2 : l1;
    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Check if contrast meets WCAG AA for normal text (4.5:1)
  static bool meetsAANormal(Color foreground, Color background) {
    return contrastRatio(foreground, background) >= 4.5;
  }

  /// Check if contrast meets WCAG AA for large text (3:1)
  static bool meetsAALarge(Color foreground, Color background) {
    return contrastRatio(foreground, background) >= 3.0;
  }

  /// Check if contrast meets WCAG AAA for normal text (7:1)
  static bool meetsAAANormal(Color foreground, Color background) {
    return contrastRatio(foreground, background) >= 7.0;
  }
}

extension _DoublePow on double {
  double pow(double exponent) => this == 0 ? 0 : (this > 0 ? this : -this).toDouble().pow(exponent);
}

extension DoublePow on double {
  double pow(double exponent) {
    if (this == 0) return 0;
    return this > 0
        ? _pow(this, exponent)
        : -_pow(-this, exponent);
  }

  static double _pow(double base, double exp) {
    return base <= 0 ? 0 : (base.log() * exp).exp();
  }
}

extension on double {
  double log() => this <= 0 ? double.negativeInfinity : _log(this);
  double exp() => _exp(this);

  static double _log(double x) {
    // Using dart:math would be better, but for standalone:
    // ln(x) approximation
    if (x <= 0) return double.negativeInfinity;
    int k = 0;
    while (x > 2) {
      x /= 2;
      k++;
    }
    while (x < 1) {
      x *= 2;
      k--;
    }
    x -= 1;
    double result = 0;
    double term = x;
    for (int i = 1; i <= 20; i++) {
      result += (i % 2 == 1 ? 1 : -1) * term / i;
      term *= x;
    }
    return result + k * 0.6931471805599453; // ln(2)
  }

  static double _exp(double x) {
    double result = 1;
    double term = 1;
    for (int i = 1; i <= 20; i++) {
      term *= x / i;
      result += term;
    }
    return result;
  }
}
