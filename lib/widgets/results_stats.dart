import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';

/// Widget to display session results statistics
class ResultsStats extends StatelessWidget {
  final double accuracyPercentage;
  final int totalPoints;
  final int bestStreak;
  final int durationSeconds;
  final int problemsAttempted;
  final int problemsCorrect;

  const ResultsStats({
    Key? key,
    required this.accuracyPercentage,
    required this.totalPoints,
    required this.bestStreak,
    required this.durationSeconds,
    required this.problemsAttempted,
    required this.problemsCorrect,
  }) : super(key: key);

  String get _durationDisplay {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  double get _averageTimePerProblem {
    if (problemsAttempted == 0) return 0;
    return durationSeconds / problemsAttempted;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top row: Points and Best Streak
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: '💎',
                label: 'Points',
                value: totalPoints.toString(),
                color: AppColors.accentGold,
              ),
            ),
            const SizedBox(width: AppConstants.smallPadding),
            Expanded(
              child: _StatCard(
                icon: '🔥',
                label: 'Best Streak',
                value: bestStreak.toString(),
                color: AppColors.errorRed,
              ),
            ),
          ],
        ),

        const SizedBox(height: AppConstants.defaultPadding),

        // Accuracy progress bar
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Accuracy',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
                Text(
                  '${accuracyPercentage.toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.smallPadding),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
              child: LinearProgressIndicator(
                value: accuracyPercentage / 100,
                minHeight: 12,
                backgroundColor: AppColors.lightGray,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getAccuracyColor(),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: AppConstants.defaultPadding),

        // Bottom row: Time and Problems
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: '⏱️',
                label: 'Time',
                value: _durationDisplay,
                color: AppColors.primaryBlue,
                isSmall: true,
              ),
            ),
            const SizedBox(width: AppConstants.smallPadding),
            Expanded(
              child: _StatCard(
                icon: '✅',
                label: 'Correct',
                value: '$problemsCorrect/$problemsAttempted',
                color: AppColors.successGreen,
                isSmall: true,
              ),
            ),
            const SizedBox(width: AppConstants.smallPadding),
            Expanded(
              child: _StatCard(
                icon: '⏱',
                label: 'Avg Time',
                value: '${_averageTimePerProblem.toStringAsFixed(1)}s',
                color: AppColors.warningOrange,
                isSmall: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getAccuracyColor() {
    if (accuracyPercentage >= 85) return AppColors.successGreen;
    if (accuracyPercentage >= 70) return AppColors.warningOrange;
    return AppColors.errorRed;
  }
}

/// Individual stat card
class _StatCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final Color color;
  final bool isSmall;

  const _StatCard({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.isSmall = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isSmall ? AppConstants.smallPadding : AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        border: Border.all(color: color),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            icon,
            style: TextStyle(
              fontSize: isSmall ? 24 : 32,
            ),
          ),
          if (!isSmall) const SizedBox(height: AppConstants.smallPadding),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: AppConstants.tinyPadding),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
