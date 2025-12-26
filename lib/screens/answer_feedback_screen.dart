import 'package:flutter/material.dart';
import '../models/math_problem.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../widgets/feedback_animation.dart';
import '../widgets/points_display.dart';

/// Modal dialog showing feedback after answer submission
class AnswerFeedbackDialog extends StatefulWidget {
  final bool isCorrect;
  final MathProblem problem;
  final int studentAnswer;
  final int correctAnswer;
  final int basePoints;
  final int bonusPoints;
  final int totalPoints;
  final int currentStreak;
  final int streakMultiplier;
  final VoidCallback onNext;
  final VoidCallback onTryAgain;
  final VoidCallback onSkip;

  const AnswerFeedbackDialog({
    Key? key,
    required this.isCorrect,
    required this.problem,
    required this.studentAnswer,
    required this.correctAnswer,
    required this.basePoints,
    required this.bonusPoints,
    required this.totalPoints,
    required this.currentStreak,
    required this.streakMultiplier,
    required this.onNext,
    required this.onTryAgain,
    required this.onSkip,
  }) : super(key: key);

  @override
  State<AnswerFeedbackDialog> createState() => _AnswerFeedbackDialogState();
}

class _AnswerFeedbackDialogState extends State<AnswerFeedbackDialog>
    with TickerProviderStateMixin {
  late AnimationController _dismissController;

  @override
  void initState() {
    super.initState();
    _dismissController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Auto-close after 5 seconds if correct
    if (widget.isCorrect) {
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          widget.onNext();
        }
      });
    }
  }

  @override
  void dispose() {
    _dismissController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Feedback animation
              FeedbackAnimation(
                isCorrect: widget.isCorrect,
                duration: const Duration(milliseconds: 500),
              ),

              const SizedBox(height: AppConstants.largePadding),

              if (widget.isCorrect)
                _buildCorrectFeedback()
              else
                _buildIncorrectFeedback(),

              const SizedBox(height: AppConstants.largePadding),

              // Action buttons
              if (widget.isCorrect)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: widget.onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.successGreen,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppConstants.defaultBorderRadius,
                        ),
                      ),
                    ),
                    child: Text(
                      'Next Problem',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: widget.onTryAgain,
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
                          'Try Again',
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
                        onPressed: widget.onSkip,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.warningOrange,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppConstants.defaultBorderRadius,
                            ),
                          ),
                        ),
                        child: Text(
                          'Skip',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Colors.white,
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

  Widget _buildCorrectFeedback() {
    return Column(
      children: [
        // Celebration message
        Text(
          'Awesome work!',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.successGreen,
          ),
        ),

        const SizedBox(height: AppConstants.defaultPadding),

        // Points display
        PointsDisplay(
          basePoints: widget.basePoints,
          bonusPoints: widget.bonusPoints,
          totalPoints: widget.totalPoints,
          streakMultiplier: widget.streakMultiplier,
        ),

        const SizedBox(height: AppConstants.defaultPadding),

        // Streak display
        if (widget.currentStreak > 0)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.defaultPadding,
              vertical: AppConstants.smallPadding,
            ),
            decoration: BoxDecoration(
              color: AppColors.errorRed.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
              border: Border.all(color: AppColors.errorRed),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '🔥',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(width: AppConstants.smallPadding),
                Text(
                  'Streak: ${widget.currentStreak}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.errorRed,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildIncorrectFeedback() {
    return Column(
      children: [
        // Encouragement message
        Text(
          'Keep trying!',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.warningOrange,
          ),
        ),

        const SizedBox(height: AppConstants.defaultPadding),

        // Answer comparison
        Container(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          decoration: BoxDecoration(
            color: AppColors.lightGray.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
            border: Border.all(color: AppColors.lightGray),
          ),
          child: Column(
            children: [
              // Problem
              Text(
                'Problem: ${widget.problem.displayEquation}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: AppConstants.defaultPadding),

              // Student's answer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Your answer:',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.defaultPadding,
                      vertical: AppConstants.smallPadding,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.errorRed.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
                      border: Border.all(color: AppColors.errorRed),
                    ),
                    child: Text(
                      widget.studentAnswer.toString(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.errorRed,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppConstants.smallPadding),

              // Correct answer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Correct answer:',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.defaultPadding,
                      vertical: AppConstants.smallPadding,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.successGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
                      border: Border.all(color: AppColors.successGreen),
                    ),
                    child: Text(
                      widget.correctAnswer.toString(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.successGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: AppConstants.defaultPadding),

        // Explanation
        Container(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          decoration: BoxDecoration(
            color: AppColors.infoBg,
            borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
            border: Border.all(color: AppColors.primaryBlue),
          ),
          child: Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: AppColors.primaryBlue,
              ),
              const SizedBox(width: AppConstants.smallPadding),
              Expanded(
                child: Text(
                  'Check your calculation and try again!',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
