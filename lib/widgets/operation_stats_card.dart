import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../utils/enums.dart';

/// Card displaying statistics for a specific math operation
/// Shows accuracy percentage, problem count, and visual progress indicator
class OperationStatsCard extends StatelessWidget {
  final Operation operation;
  final int problemsAttempted;
  final int problemsCorrect;
  final double accuracyPercentage;

  const OperationStatsCard({
    Key? key,
    required this.operation,
    required this.problemsAttempted,
    required this.problemsCorrect,
    required this.accuracyPercentage,
  }) : super(key: key);

  /// Get color based on accuracy threshold
  Color _getAccuracyColor() {
    if (accuracyPercentage >= 85) {
      return AppColors.successGreen;
    } else if (accuracyPercentage >= 70) {
      return AppColors.warningOrange;
    } else {
      return AppColors.errorRed;
    }
  }

  /// Get emoji representation for operation
  String _getOperationEmoji() {
    switch (operation) {
      case Operation.add:
        return '➕';
      case Operation.subtract:
        return '➖';
      case Operation.multiply:
        return '✖️';
      case Operation.divide:
        return '➗';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Operation header
            Row(
              children: [
                Text(
                  _getOperationEmoji(),
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: AppConstants.smallPadding),
                Text(
                  operation.symbol,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            // Accuracy percentage
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Accuracy',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.secondaryText,
                      ),
                ),
                Text(
                  '${accuracyPercentage.toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _getAccuracyColor(),
                      ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.smallPadding),
            // Accuracy progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: accuracyPercentage / 100,
                minHeight: 6,
                backgroundColor: AppColors.lightGray,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getAccuracyColor(),
                ),
              ),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            // Problem statistics
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatDetail(
                  label: 'Attempted',
                  value: problemsAttempted.toString(),
                  icon: '📝',
                ),
                _StatDetail(
                  label: 'Correct',
                  value: problemsCorrect.toString(),
                  icon: '✅',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Small detail display within operation card
class _StatDetail extends StatelessWidget {
  final String label;
  final String value;
  final String icon;

  const _StatDetail({
    Key? key,
    required this.label,
    required this.value,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          icon,
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
        ),
        const SizedBox(height: 2),
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
