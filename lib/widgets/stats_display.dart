import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';

/// Widget to display operation-specific accuracy stats
class OperationStatCard extends StatelessWidget {
  final String operation;
  final String operationSymbol;
  final double accuracy;
  final int attempts;

  const OperationStatCard({
    Key? key,
    required this.operation,
    required this.operationSymbol,
    required this.accuracy,
    required this.attempts,
  }) : super(key: key);

  Color _getAccuracyColor() {
    if (accuracy >= 85) return AppColors.successGreen;
    if (accuracy >= 70) return AppColors.warningOrange;
    if (accuracy >= 50) return AppColors.accentGold;
    return AppColors.errorRed;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      operation,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      '$attempts attempts',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
                Text(
                  operationSymbol,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ],
            ),
            const SizedBox(height: AppConstants.smallPadding),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (accuracy / 100).clamp(0, 1),
                minHeight: 8,
                backgroundColor: AppColors.lightGray,
                valueColor: AlwaysStoppedAnimation(_getAccuracyColor()),
              ),
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Text(
              '${accuracy.toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: _getAccuracyColor(),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget to display overall statistics
class StatsDisplay extends StatelessWidget {
  final int currentLevel;
  final int totalPoints;
  final int currentStreak;
  final double overallAccuracy;
  final Map<String, double> accuracyByOperation;
  final VoidCallback? onViewDetails;

  const StatsDisplay({
    Key? key,
    required this.currentLevel,
    required this.totalPoints,
    required this.currentStreak,
    required this.overallAccuracy,
    required this.accuracyByOperation,
    this.onViewDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with main stats
        Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatCard(
                icon: '⭐',
                label: 'Level',
                value: currentLevel.toString(),
                color: AppColors.accentGold,
              ),
              _StatCard(
                icon: '💎',
                label: 'Points',
                value: totalPoints.toString(),
                color: AppColors.primaryBlue,
              ),
              _StatCard(
                icon: '🔥',
                label: 'Streak',
                value: currentStreak.toString(),
                color: AppColors.errorRed,
              ),
            ],
          ),
        ),
        
        // Overall accuracy
        Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Overall Accuracy',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppConstants.smallPadding),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: (overallAccuracy / 100).clamp(0, 1),
                        minHeight: 12,
                        backgroundColor: AppColors.lightGray,
                        valueColor: AlwaysStoppedAnimation(
                          overallAccuracy >= 85
                              ? AppColors.successGreen
                              : overallAccuracy >= 70
                                  ? AppColors.warningOrange
                                  : AppColors.errorRed,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppConstants.smallPadding),
                  Text(
                    '${overallAccuracy.toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Operation breakdown
        if (accuracyByOperation.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'By Operation',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (onViewDetails != null)
                      GestureDetector(
                        onTap: onViewDetails,
                        child: Text(
                          'View Details',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppConstants.smallPadding),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _OperationQuickStat(
                        icon: '➕',
                        label: 'Add',
                        accuracy: accuracyByOperation['addition'] ?? 0,
                      ),
                      const SizedBox(width: AppConstants.defaultPadding),
                      _OperationQuickStat(
                        icon: '➖',
                        label: 'Sub',
                        accuracy: accuracyByOperation['subtraction'] ?? 0,
                      ),
                      const SizedBox(width: AppConstants.defaultPadding),
                      _OperationQuickStat(
                        icon: '✖️',
                        label: 'Mul',
                        accuracy: accuracyByOperation['multiplication'] ?? 0,
                      ),
                      const SizedBox(width: AppConstants.defaultPadding),
                      _OperationQuickStat(
                        icon: '➗',
                        label: 'Div',
                        accuracy: accuracyByOperation['division'] ?? 0,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Small stat card for displaying a single stat
class _StatCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          icon,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.secondaryText,
          ),
        ),
      ],
    );
  }
}

/// Quick operation stat display (small icon + accuracy)
class _OperationQuickStat extends StatelessWidget {
  final String icon;
  final String label;
  final double accuracy;

  const _OperationQuickStat({
    required this.icon,
    required this.label,
    required this.accuracy,
  });

  Color _getColor() {
    if (accuracy >= 85) return AppColors.successGreen;
    if (accuracy >= 70) return AppColors.warningOrange;
    if (accuracy > 0) return AppColors.errorRed;
    return AppColors.lightGray;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: AppConstants.smallPadding,
      ),
      decoration: BoxDecoration(
        color: _getColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
        border: Border.all(color: _getColor(), width: 1),
      ),
      child: Column(
        children: [
          Text(
            icon,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            '${accuracy.toStringAsFixed(0)}%',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: _getColor(),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.secondaryText,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
