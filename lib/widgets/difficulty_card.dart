import 'package:flutter/material.dart';
import '../config/difficulty_config.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';

/// Widget displaying a single difficulty level with selection
class DifficultyCard extends StatelessWidget {
  final DifficultyLevel level;
  final bool isSelected;
  final bool isUnlocked;
  final double progressToUnlock;
  final VoidCallback onSelect;

  const DifficultyCard({
    Key? key,
    required this.level,
    required this.isSelected,
    required this.isUnlocked,
    required this.progressToUnlock,
    required this.onSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isUnlocked ? onSelect : null,
      child: Card(
        elevation: isSelected ? 8 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
          side: isSelected
              ? BorderSide(
                  color: AppColors.primaryBlue,
                  width: 3,
                )
              : BorderSide(
                  color: Colors.transparent,
                ),
        ),
        color: isUnlocked
            ? Colors.white
            : AppColors.lightGray.withValues(alpha: 0.5),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with level icon and radio button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        level.icon,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      Radio<int>(
                        value: level.id,
                        groupValue: isSelected ? level.id : -1,
                        onChanged: isUnlocked
                            ? (_) {
                                onSelect();
                              }
                            : null,
                        activeColor: AppColors.primaryBlue,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.defaultPadding),

                  // Level title
                  Text(
                    level.displayName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isUnlocked ? Colors.black : AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: AppConstants.smallPadding),

                  // Number range
                  Row(
                    children: [
                      Text(
                        '📊 Numbers: ',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        level.numberRangeDisplay,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.smallPadding),

                  // Points per correct
                  Row(
                    children: [
                      Text(
                        '💎 Points: ',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        '${level.pointsPerCorrect} per answer',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.accentGold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.defaultPadding),

                  // Description
                  Text(
                    level.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),

            // Lock overlay
            if (!isUnlocked)
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.lock,
                        size: 48,
                        color: Colors.white,
                      ),
                      const SizedBox(height: AppConstants.smallPadding),
                      Text(
                        'Locked',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppConstants.smallPadding),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.defaultPadding,
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Reach 85% accuracy on',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                            Text(
                              'Level ${level.id - 1}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: AppConstants.smallPadding),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progressToUnlock.clamp(0, 1),
                                minHeight: 6,
                                backgroundColor: Colors.white24,
                                valueColor: AlwaysStoppedAnimation(
                                  Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${(progressToUnlock * 100).toStringAsFixed(0)}%',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
