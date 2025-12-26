import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';

/// Widget to display countdown timer for problem
class TimerDisplay extends StatelessWidget {
  final int secondsRemaining;
  final int totalSeconds;
  final bool isWarning;
  final bool isCritical;

  const TimerDisplay({
    Key? key,
    required this.secondsRemaining,
    required this.totalSeconds,
    required this.isWarning,
    required this.isCritical,
  }) : super(key: key);

  Color _getTimerColor() {
    if (isCritical) return AppColors.errorRed;
    if (isWarning) return AppColors.warningOrange;
    return AppColors.primaryBlue;
  }

  @override
  Widget build(BuildContext context) {
    final progress = secondsRemaining / totalSeconds;
    final minutes = secondsRemaining ~/ 60;
    final seconds = secondsRemaining % 60;

    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: _getTimerColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        border: Border.all(
          color: _getTimerColor(),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(
            'Time Remaining',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: _getTimerColor(),
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0, 1),
              minHeight: 6,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation(_getTimerColor()),
            ),
          ),
          if (isWarning)
            Padding(
              padding: const EdgeInsets.only(top: AppConstants.smallPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.warning_amber,
                    color: AppColors.warningOrange,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Hurry up!',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.warningOrange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
