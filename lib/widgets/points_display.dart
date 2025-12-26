import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';

/// Widget to display points breakdown (base + bonuses)
class PointsDisplay extends StatelessWidget {
  final int basePoints;
  final int bonusPoints;
  final int totalPoints;
  final int streakMultiplier;

  const PointsDisplay({
    Key? key,
    required this.basePoints,
    required this.bonusPoints,
    required this.totalPoints,
    this.streakMultiplier = 1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Total points (largest)
        Container(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          decoration: BoxDecoration(
            color: AppColors.accentGold.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
            border: Border.all(color: AppColors.accentGold, width: 2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Points',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: AppConstants.tinyPadding),
                  Text(
                    totalPoints.toString(),
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: AppColors.accentGold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Icon(
                Icons.card_giftcard,
                color: AppColors.accentGold,
                size: 48,
              ),
            ],
          ),
        ),

        const SizedBox(height: AppConstants.defaultPadding),

        // Points breakdown (smaller cards)
        Row(
          children: [
            // Base points
            Expanded(
              child: _PointsCard(
                label: 'Base',
                points: basePoints,
                color: AppColors.primaryBlue,
                icon: '⭐',
              ),
            ),

            const SizedBox(width: AppConstants.smallPadding),

            // Bonus points
            if (bonusPoints > 0)
              Expanded(
                child: _PointsCard(
                  label: 'Bonus',
                  points: bonusPoints,
                  color: AppColors.successGreen,
                  icon: '🎁',
                ),
              ),

            // Streak multiplier
            if (streakMultiplier > 1)
              Expanded(
                child: _PointsCard(
                  label: 'Streak',
                  points: streakMultiplier,
                  color: AppColors.errorRed,
                  icon: '🔥',
                  isMultiplier: true,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// Individual points card
class _PointsCard extends StatelessWidget {
  final String label;
  final int points;
  final Color color;
  final String icon;
  final bool isMultiplier;

  const _PointsCard({
    Key? key,
    required this.label,
    required this.points,
    required this.color,
    required this.icon,
    this.isMultiplier = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.smallPadding),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
        border: Border.all(color: color),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            icon,
            style: const TextTheme().headlineSmall,
          ),
          const SizedBox(height: AppConstants.tinyPadding),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: AppConstants.tinyPadding),
          Text(
            isMultiplier ? '${points}x' : points.toString(),
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
