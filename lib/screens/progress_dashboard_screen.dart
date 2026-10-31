import 'package:flutter/material.dart';
import '../models/achievement.dart';
import 'package:provider/provider.dart';
import '../providers/statistics_provider.dart';
import '../providers/student_provider.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../widgets/progress_chart.dart';

/// Progress Dashboard screen showing comprehensive statistics and analytics
/// Displays session data, level progression, achievements
class ProgressDashboardScreen extends StatefulWidget {
  const ProgressDashboardScreen({Key? key}) : super(key: key);

  @override
  State<ProgressDashboardScreen> createState() =>
      _ProgressDashboardScreenState();
}

class _ProgressDashboardScreenState extends State<ProgressDashboardScreen> {
  String _selectedPeriod = 'week';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Dashboard'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer2<StatisticsProvider, StudentProvider>(
        builder: (context, statsProvider, studentProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTimePeriodFilter(),
                const SizedBox(height: AppConstants.largePadding),
                _buildStatsOverview(statsProvider),
                const SizedBox(height: AppConstants.largePadding),
                _buildProgressChart(statsProvider),
                const SizedBox(height: AppConstants.largePadding),
                Text(
                  'Recent Sessions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                ),
                const SizedBox(height: AppConstants.defaultPadding),
                _buildSessionSummary(statsProvider),
                const SizedBox(height: AppConstants.largePadding),
                _buildLevelProgression(studentProvider),
                const SizedBox(height: AppConstants.largePadding),
                _buildAchievements(statsProvider, studentProvider),
                const SizedBox(height: AppConstants.largePadding),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Build time period filter buttons
  Widget _buildTimePeriodFilter() {
    return Row(
      children: [
        _PeriodButton(
          label: 'This Week',
          period: 'week',
          isSelected: _selectedPeriod == 'week',
          onPressed: () {
            setState(() => _selectedPeriod = 'week');
          },
        ),
        const SizedBox(width: AppConstants.defaultPadding),
        _PeriodButton(
          label: 'This Month',
          period: 'month',
          isSelected: _selectedPeriod == 'month',
          onPressed: () {
            setState(() => _selectedPeriod = 'month');
          },
        ),
        const SizedBox(width: AppConstants.defaultPadding),
        _PeriodButton(
          label: 'All Time',
          period: 'allTime',
          isSelected: _selectedPeriod == 'allTime',
          onPressed: () {
            setState(() => _selectedPeriod = 'allTime');
          },
        ),
      ],
    );
  }

  /// Build overview stats
  Widget _buildStatsOverview(StatisticsProvider statsProvider) {
    final sessions = statsProvider.studentSessions;
    final totalPoints = sessions.fold<int>(0, (sum, session) => sum + session.totalPoints);
    final sessionsCompleted = sessions.length;
    final avgAccuracy = sessions.isNotEmpty
        ? sessions.fold<double>(0, (sum, session) => sum + session.accuracyPercentage) / sessions.length
        : 0.0;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: '💎',
            label: 'Total Points',
            value: totalPoints.toString(),
            color: AppColors.accentGold,
          ),
        ),
        const SizedBox(width: AppConstants.defaultPadding),
        Expanded(
          child: _StatCard(
            icon: '📊',
            label: 'Sessions',
            value: sessionsCompleted.toString(),
            color: AppColors.primaryBlue,
          ),
        ),
        const SizedBox(width: AppConstants.defaultPadding),
        Expanded(
          child: _StatCard(
            icon: '🎯',
            label: 'Avg Accuracy',
            value: '${avgAccuracy.toStringAsFixed(0)}%',
            color: AppColors.successGreen,
          ),
        ),
      ],
    );
  }

  /// Build progress chart widget
  Widget _buildProgressChart(StatisticsProvider statsProvider) {
    final sessions = statsProvider.studentSessions;
    final totalPoints = sessions.fold<int>(0, (sum, session) => sum + session.totalPoints);
    final totalProblems = sessions.fold<int>(0, (sum, session) => sum + session.problemCount);

    return ProgressChart(
      totalPoints: totalPoints,
      totalProblems: totalProblems,
      maxPoints: _selectedPeriod == 'allTime' ? 10000 : 2000,
      maxProblems: _selectedPeriod == 'allTime' ? 1000 : 200,
    );
  }

  /// Build session summary
  Widget _buildSessionSummary(StatisticsProvider statsProvider) {
    final sessions = statsProvider.studentSessions;
    
    if (sessions.isEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Center(
            child: Text(
              'No practice sessions yet. Start practicing! 📚',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.secondaryText,
                  ),
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        for (int i = 0; i < sessions.length && i < 3; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
            child: _SessionCard(session: sessions[i]),
          ),
      ],
    );
  }

  /// Build level progression section
  Widget _buildLevelProgression(StudentProvider studentProvider) {
    final student = studentProvider.currentStudent;
    if (student == null) return const SizedBox.shrink();

    final currentLevelIndex = student.currentDifficultyLevel;
    final currentAccuracy = student.overallAccuracyPercentage.clamp(0.0, 100.0);

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
            Text(
              'Level Progression',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Row(
              children: [
                Text(
                  _getLevelEmoji(currentLevelIndex),
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: AppConstants.defaultPadding),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getLevelName(currentLevelIndex),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkText,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Current Accuracy: ${currentAccuracy.toStringAsFixed(0)}%',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.secondaryText,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            // Next level progress
            if (currentLevelIndex < 3)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Progress to Next Level (85% accuracy needed)',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.secondaryText,
                        ),
                  ),
                  const SizedBox(height: AppConstants.smallPadding),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: (currentAccuracy / 85).clamp(0.0, 1.0),
                      minHeight: 8,
                      backgroundColor: AppColors.lightGray,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primaryBlue,
                      ),
                    ),
                  ),
                ],
              )
            else
              Text(
                '⭐ Expert Level Achieved!',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.accentGold,
                    ),
              ),
          ],
        ),
      ),
    );
  }

  /// Build achievements section
  Widget _buildAchievements(
      StatisticsProvider statsProvider, StudentProvider studentProvider) {
    final sessions = statsProvider.studentSessions;
    final totalPoints = sessions.fold<int>(0, (sum, session) => sum + session.totalPoints);
    final sessionsCount = sessions.length;
    
    final List<String> unlockedAchievements = [];
    if (totalPoints >= 100) unlockedAchievements.add('100 Points');
    if (totalPoints >= 500) unlockedAchievements.add('500 Points');
    if (totalPoints >= 1000) unlockedAchievements.add('1000 Points');
    if (sessionsCount >= 7) unlockedAchievements.add('Week Warrior');

    // Achievements unlocked in games are stored on the student profile.
    for (final id in studentProvider.currentStudent?.achievementIds ?? const <String>[]) {
      final title = AchievementDefinitions.getById(id)?.title;
      if (title != null && !unlockedAchievements.contains(title)) {
        unlockedAchievements.add(title);
      }
    }

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
            Text(
              'Achievements Unlocked',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            if (unlockedAchievements.isEmpty)
              Text(
                'Keep practicing to unlock achievements! 🎯',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.secondaryText,
                    ),
              )
            else
              Wrap(
                spacing: AppConstants.defaultPadding,
                runSpacing: AppConstants.defaultPadding,
                children: [
                  for (final achievement in unlockedAchievements)
                    _AchievementBadge(achievement: achievement),
                ],
              ),
          ],
        ),
      ),
    );
  }

  String _getLevelEmoji(int level) {
    switch (level) {
      case 0:
        return '🟢';
      case 1:
        return '🟡';
      case 2:
        return '🔴';
      default:
        return '⭐';
    }
  }

  String _getLevelName(int level) {
    switch (level) {
      case 0:
        return 'Beginner';
      case 1:
        return 'Intermediate';
      case 2:
        return 'Advanced';
      default:
        return 'Expert';
    }
  }
}

/// Individual stat card
class _StatCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  }) : super(key: key);

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
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.secondaryText,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Time period button
class _PeriodButton extends StatelessWidget {
  final String label;
  final String period;
  final bool isSelected;
  final VoidCallback onPressed;

  const _PeriodButton({
    Key? key,
    required this.label,
    required this.period,
    required this.isSelected,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? AppColors.primaryBlue : AppColors.lightGray,
          foregroundColor: isSelected ? Colors.white : AppColors.secondaryText,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          ),
          elevation: isSelected ? 4 : 0,
        ),
        child: Text(label),
      ),
    );
  }
}

/// Session card showing individual session details
class _SessionCard extends StatelessWidget {
  final dynamic session;

  const _SessionCard({
    Key? key,
    required this.session,
  }) : super(key: key);

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${session.problemCount} Problems',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkText,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Completed on ${session.completedAt?.toString().split(' ')[0] ?? 'N/A'}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.secondaryText,
                          ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${session.totalPoints} pts',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.accentGold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${session.accuracyPercentage.toStringAsFixed(0)}% accurate',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: session.accuracyPercentage >= 85
                                ? AppColors.successGreen
                                : AppColors.warningOrange,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Achievement badge widget
class _AchievementBadge extends StatelessWidget {
  final String achievement;

  const _AchievementBadge({
    Key? key,
    required this.achievement,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryBlueWithOpacity(0.1),
            border: Border.all(
              color: AppColors.primaryBlue,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              _getAchievementEmoji(achievement),
              style: const TextStyle(fontSize: 28),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 70,
          child: Text(
            achievement,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.darkText,
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _getAchievementEmoji(String achievement) {
    if (achievement.contains('Points')) return '💎';
    if (achievement.contains('Warrior')) return '⚔️';
    if (achievement.contains('Pizza')) return '🍕';
    if (achievement.contains('Fraction')) return '🥧';
    return '⭐';
  }
}
