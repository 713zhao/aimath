import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';

/// Widget to display current streak
class StreakIndicator extends StatelessWidget {
  final int currentStreak;
  final int longestStreak;
  final String streakMessage;
  final String streakEmoji;

  const StreakIndicator({
    Key? key,
    required this.currentStreak,
    required this.longestStreak,
    required this.streakMessage,
    required this.streakEmoji,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Current streak
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(AppConstants.smallPadding),
            decoration: BoxDecoration(
              color: AppColors.errorRed.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
              border: Border.all(color: AppColors.errorRed),
            ),
            child: Column(
              children: [
                Text(
                  '🔥',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  currentStreak.toString(),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.errorRed,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Streak',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: AppConstants.smallPadding),

        // Streak message (if any)
        if (streakMessage.isNotEmpty)
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(AppConstants.smallPadding),
              decoration: BoxDecoration(
                color: AppColors.accentGold.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
                border: Border.all(color: AppColors.accentGold),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    streakEmoji,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    streakMessage,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.accentGold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(AppConstants.smallPadding),
              decoration: BoxDecoration(
                color: AppColors.lightGray.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
                border: Border.all(color: AppColors.lightGray),
              ),
              child: Column(
                children: [
                  Text(
                    '⭐',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    longestStreak.toString(),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.secondaryText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Best',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
