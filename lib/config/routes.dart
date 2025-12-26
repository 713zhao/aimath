import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/difficulty_selector_screen.dart';
import '../screens/practice_session_screen.dart';
import '../screens/session_results_screen.dart';
import '../screens/progress_dashboard_screen.dart';
import '../screens/settings_screen.dart';
import '../utils/enums.dart';

/// Route configuration for the Math Practice App
class AppRoutes {
  AppRoutes._();

  // Route names
  static const String splash = '/';
  static const String home = '/home';
  static const String difficultySelector = '/difficulty-selector';
  static const String practiceSession = '/practice-session';
  static const String sessionResults = '/session-results';
  static const String progressDashboard = '/progress-dashboard';
  static const String settings = '/settings';

  /// Static routes map for simple named navigation (only for simple screens)
  static final Map<String, WidgetBuilder> routes = {
    home: (context) => const HomeScreen(),
    progressDashboard: (context) => const ProgressDashboardScreen(),
    settings: (context) => const SettingsScreen(),
  };

  /// Handle dynamic route generation with proper error handling
  /// Routes that require parameters should be navigated to via pushNamed with arguments
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(
          builder: (context) => const HomeScreen(),
          settings: settings,
        );

      case difficultySelector:
        return MaterialPageRoute(
          builder: (context) => const DifficultySelectorScreen(),
          settings: settings,
        );

      case practiceSession:
        // Arguments: {difficultyLevel: int, operations: List<Operation>, timeLimitSeconds: int?}
        final args = settings.arguments as Map<String, dynamic>?;
        if (args != null) {
          final opList = args['operations'] as List?;
          final operations = opList?.cast<Operation>() ?? [];
          final timeLimitSeconds = args['timeLimitSeconds'] as int? ?? 180;
          return MaterialPageRoute(
            builder: (context) => PracticeSessionScreen(
              difficultyLevel: args['difficultyLevel'] as int,
              operations: operations,
              timeLimitSeconds: timeLimitSeconds,
            ),
            settings: settings,
          );
        }
        // Fallback to difficulty selector if no arguments
        return MaterialPageRoute(
          builder: (context) => const DifficultySelectorScreen(),
          settings: settings,
        );

      case sessionResults:
        // Arguments: {session: PracticeSession, leveledUp: bool?, newLevel: int?}
        final args = settings.arguments as Map<String, dynamic>?;
        if (args != null && args.containsKey('session')) {
          return MaterialPageRoute(
            builder: (context) => SessionResultsScreen(
              session: args['session'],
              leveledUp: args['leveledUp'] as bool? ?? false,
              newLevel: args['newLevel'] as int?,
            ),
            settings: settings,
          );
        }
        // Fallback to home if no session
        return MaterialPageRoute(
          builder: (context) => const HomeScreen(),
          settings: settings,
        );

      case progressDashboard:
        return MaterialPageRoute(
          builder: (context) => const ProgressDashboardScreen(),
          settings: settings,
        );

      case '/settings':
        return MaterialPageRoute(
          builder: (context) => const SettingsScreen(),
          settings: settings,
        );

      default:
        // Return home screen for undefined routes
        return MaterialPageRoute(
          builder: (context) => const HomeScreen(),
          settings: settings,
        );
    }
  }

  /// Navigation helper - go to home (replacing current route)
  static void goToHome(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(home);
  }

  /// Navigation helper - go to difficulty selector
  static void goToDifficultySelector(BuildContext context) {
    Navigator.of(context).pushNamed(difficultySelector);
  }

  /// Navigation helper - go to practice session
  static void goToPracticeSession(BuildContext context) {
    Navigator.of(context).pushNamed(practiceSession);
  }

  /// Navigation helper - go to session results (replacing practice session)
  static void goToSessionResults(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(sessionResults);
  }

  /// Navigation helper - go to progress dashboard
  static void goToProgressDashboard(BuildContext context) {
    Navigator.of(context).pushNamed(progressDashboard);
  }

  /// Navigation helper - go to settings
  static void goToSettings(BuildContext context) {
    Navigator.of(context).pushNamed(settings);
  }

  /// Pop current screen and return to previous
  static void goBack(BuildContext context, [dynamic result]) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop(result);
    } else {
      // If at root, go to home instead
      goToHome(context);
    }
  }
}
