import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'dart:math' as math;

/// Helper class for accessibility-related utilities
class AccessibilityHelpers {
  AccessibilityHelpers._();

  /// Calculate contrast ratio between two colors (WCAG formula)
  static double calculateContrastRatio(Color foreground, Color background) {
    final l1 = _relativeLuminance(foreground);
    final l2 = _relativeLuminance(background);
    final lighter = math.max(l1, l2);
    final darker = math.min(l1, l2);
    return (lighter + 0.05) / (darker + 0.05);
  }

  static double _relativeLuminance(Color color) {
    double r = _linearize(color.red / 255);
    double g = _linearize(color.green / 255);
    double b = _linearize(color.blue / 255);
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  static double _linearize(double value) {
    return value <= 0.03928
        ? value / 12.92
        : math.pow((value + 0.055) / 1.055, 2.4).toDouble();
  }

  /// Check if color combination meets WCAG AA for normal text (4.5:1)
  static bool meetsWCAGAA(Color foreground, Color background) {
    return calculateContrastRatio(foreground, background) >= 4.5;
  }

  /// Check if color combination meets WCAG AA for large text (3:1)
  static bool meetsWCAGAALarge(Color foreground, Color background) {
    return calculateContrastRatio(foreground, background) >= 3.0;
  }

  /// Get a high-contrast color for text based on background
  static Color getContrastingTextColor(Color background) {
    final luminance = _relativeLuminance(background);
    return luminance > 0.179 ? Colors.black : Colors.white;
  }

  /// Validate app color palette for accessibility
  static Map<String, bool> validateColorPalette({
    required Color primaryColor,
    required Color backgroundColor,
    required Color successColor,
    required Color errorColor,
    required Color textColor,
  }) {
    return {
      'primary_on_background': meetsWCAGAA(primaryColor, backgroundColor),
      'success_on_background': meetsWCAGAA(successColor, backgroundColor),
      'error_on_background': meetsWCAGAA(errorColor, backgroundColor),
      'text_on_background': meetsWCAGAA(textColor, backgroundColor),
      'white_on_primary': meetsWCAGAA(Colors.white, primaryColor),
      'white_on_success': meetsWCAGAA(Colors.white, successColor),
      'white_on_error': meetsWCAGAA(Colors.white, errorColor),
    };
  }
}

/// Widget wrapper that ensures minimum touch target size
class TouchTargetPadding extends StatelessWidget {
  final Widget child;
  final double minSize;

  const TouchTargetPadding({
    super.key,
    required this.child,
    this.minSize = 48.0,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: minSize,
        minHeight: minSize,
      ),
      child: Center(child: child),
    );
  }
}

/// Announcement widget for screen readers
class ScreenReaderAnnouncement extends StatefulWidget {
  final String message;
  final Widget child;

  const ScreenReaderAnnouncement({
    super.key,
    required this.message,
    required this.child,
  });

  @override
  State<ScreenReaderAnnouncement> createState() => _ScreenReaderAnnouncementState();
}

class _ScreenReaderAnnouncementState extends State<ScreenReaderAnnouncement> {
  @override
  void initState() {
    super.initState();
    _announce();
  }

  @override
  void didUpdateWidget(ScreenReaderAnnouncement oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.message != widget.message) {
      _announce();
    }
  }

  void _announce() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SemanticsService.announce(widget.message, TextDirection.ltr);
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Focus traversal helper for keyboard navigation
class AccessibleFocusTraversal extends StatelessWidget {
  final Widget child;
  final int order;

  const AccessibleFocusTraversal({
    super.key,
    required this.child,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return FocusTraversalOrder(
      order: NumericFocusOrder(order.toDouble()),
      child: child,
    );
  }
}
