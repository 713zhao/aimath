import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';

/// Simple visual chart showing progress metrics
/// Displays total points and problems solved with bar graphs
class ProgressChart extends StatelessWidget {
  final int totalPoints;
  final int totalProblems;
  final int maxPoints;
  final int maxProblems;

  const ProgressChart({
    Key? key,
    required this.totalPoints,
    required this.totalProblems,
    this.maxPoints = 5000,
    this.maxProblems = 500,
  }) : super(key: key);

  double _getPointsPercentage() {
    if (maxPoints == 0) return 0;
    return (totalPoints / maxPoints).clamp(0.0, 1.0);
  }

  double _getProblemsPercentage() {
    if (maxProblems == 0) return 0;
    return (totalProblems / maxProblems).clamp(0.0, 1.0);
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
            // Title
            Text(
              'Progress Overview',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            // Points bar
            _ProgressBar(
              icon: '💎',
              label: 'Total Points',
              current: totalPoints,
              maximum: maxPoints,
              percentage: _getPointsPercentage(),
              color: AppColors.accentGold,
            ),
            const SizedBox(height: AppConstants.largePadding),
            // Problems bar
            _ProgressBar(
              icon: '✅',
              label: 'Problems Solved',
              current: totalProblems,
              maximum: maxProblems,
              percentage: _getProblemsPercentage(),
              color: AppColors.successGreen,
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual progress bar within chart
class _ProgressBar extends StatelessWidget {
  final String icon;
  final String label;
  final int current;
  final int maximum;
  final double percentage;
  final Color color;

  const _ProgressBar({
    Key? key,
    required this.icon,
    required this.label,
    required this.current,
    required this.maximum,
    required this.percentage,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label and value
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  icon,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(width: AppConstants.smallPadding),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.darkText,
                      ),
                ),
              ],
            ),
            Text(
              '$current / $maximum',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.smallPadding),
        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 12,
            backgroundColor: AppColors.lightGray,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

/// Time period filter button
class TimePeriodButton extends StatelessWidget {
  final String period;
  final bool isSelected;
  final VoidCallback onPressed;

  const TimePeriodButton({
    Key? key,
    required this.period,
    required this.isSelected,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? AppColors.primaryBlue : AppColors.lightGray,
        foregroundColor: isSelected ? Colors.white : AppColors.secondaryText,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
        elevation: isSelected ? 4 : 0,
      ),
      child: Text(period),
    );
  }
}
