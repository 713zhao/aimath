import 'package:flutter/material.dart';
import '../models/practice_session.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../widgets/results_stats.dart';
import '../widgets/level_up_banner.dart';

/// Screen showing session results and statistics
class SessionResultsScreen extends StatefulWidget {
  final PracticeSession session;
  final bool leveledUp;
  final int? newLevel;

  const SessionResultsScreen({
    Key? key,
    required this.session,
    this.leveledUp = false,
    this.newLevel,
  }) : super(key: key);

  @override
  State<SessionResultsScreen> createState() => _SessionResultsScreenState();
}

class _SessionResultsScreenState extends State<SessionResultsScreen> {
  @override
  void initState() {
    super.initState();
    // Save session data when screen loads
    _saveSessionData();
  }

  void _saveSessionData() async {
    // Session is already saved in GameProvider.endSession()
    // This is a safety measure if needed
  }

  void _practiceAgain() {
    // Return to home screen, user can select difficulty again
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _backToHome() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  int _getProblemsCorrect() {
    // Calculate from accuracy percentage
    final total = widget.session.problemIds.length;
    final percentage = widget.session.accuracyPercentage;
    return ((total * percentage) / 100).round();
  }

  @override
  Widget build(BuildContext context) {
    final problemsCorrect = _getProblemsCorrect();
    final totalProblems = widget.session.problemIds.length;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.darkText,
        title: Text(
          'Session Complete!',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.darkText,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            children: [
              // Level up banner if applicable
              if (widget.leveledUp && widget.newLevel != null)
                Column(
                  children: [
                    LevelUpBanner(
                      newLevel: widget.newLevel!,
                      nextLevelThreshold: 85,
                    ),
                    const SizedBox(height: AppConstants.defaultPadding),
                  ],
                ),

              // Main results stats
              ResultsStats(
                accuracyPercentage: widget.session.accuracyPercentage,
                totalPoints: widget.session.totalPoints,
                bestStreak: 0, // This would come from GameProvider
                durationSeconds: widget.session.durationSeconds,
                problemsAttempted: totalProblems,
                problemsCorrect: problemsCorrect,
              ),

              const SizedBox(height: AppConstants.largePadding),

              // Performance feedback message
              _buildPerformanceFeedback(context, widget.session.accuracyPercentage),

              const SizedBox(height: AppConstants.largePadding),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _practiceAgain,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppConstants.defaultBorderRadius,
                          ),
                        ),
                      ),
                      child: Text(
                        'Practice Again',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppConstants.smallPadding),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _backToHome,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.lightGray,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppConstants.defaultBorderRadius,
                          ),
                        ),
                      ),
                      child: Text(
                        'Back Home',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.darkText,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPerformanceFeedback(BuildContext context, double accuracy) {
    String message = '';
    String emoji = '';
    Color color = AppColors.secondaryText;

    if (accuracy >= 90) {
      message = 'Outstanding! You\'re a math master! 🌟';
      emoji = '🌟';
      color = AppColors.successGreen;
    } else if (accuracy >= 80) {
      message = 'Excellent work! Keep practicing! ⭐';
      emoji = '⭐';
      color = AppColors.successGreen;
    } else if (accuracy >= 70) {
      message = 'Great job! You\'re improving! 👍';
      emoji = '👍';
      color = AppColors.warningOrange;
    } else if (accuracy >= 60) {
      message = 'Good effort! Practice makes perfect! 💪';
      emoji = '💪';
      color = AppColors.warningOrange;
    } else {
      message = 'Keep trying! You\'ll get better! 📚';
      emoji = '📚';
      color = AppColors.errorRed;
    }

    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        border: Border.all(color: color),
      ),
      child: Row(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(width: AppConstants.defaultPadding),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
