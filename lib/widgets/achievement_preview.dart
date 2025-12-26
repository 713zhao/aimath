import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';

/// Widget to display a single achievement badge
class AchievementBadge extends StatelessWidget {
  final String icon;
  final String title;
  final bool isUnlocked;
  final VoidCallback? onTap;

  const AchievementBadge({
    Key? key,
    required this.icon,
    required this.title,
    required this.isUnlocked,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Tooltip(
        message: title,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isUnlocked ? AppColors.accentGold : AppColors.lightGray,
            boxShadow: [
              BoxShadow(
                color: isUnlocked ? AppColors.accentGold.withValues(alpha: 0.3) : Colors.transparent,
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Text(
            icon,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
        ),
      ),
    );
  }
}

/// Widget to display a preview of recent achievements
class AchievementPreview extends StatelessWidget {
  final List<String> achievementIcons;
  final List<String> achievementTitles;
  final int totalAchievements;
  final VoidCallback? onViewAll;

  const AchievementPreview({
    Key? key,
    required this.achievementIcons,
    required this.achievementTitles,
    required this.totalAchievements,
    this.onViewAll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Show up to 3 achievements with animation
    final displayCount = achievementIcons.length.clamp(0, 3);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
          ),
          child: Text(
            'Achievements ($totalAchievements)',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
          ),
          child: Wrap(
            spacing: AppConstants.defaultPadding,
            runSpacing: AppConstants.defaultPadding,
            children: [
              for (int i = 0; i < displayCount; i++)
                AchievementBadge(
                  icon: achievementIcons[i],
                  title: achievementTitles[i],
                  isUnlocked: true,
                ),
              if (totalAchievements > 3)
                GestureDetector(
                  onTap: onViewAll,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryBlue.withValues(alpha: 0.1),
                      border: Border.all(
                        color: AppColors.primaryBlue,
                        width: 2,
                      ),
                    ),
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    child: Center(
                      child: Text(
                        '+${totalAchievements - 3}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
