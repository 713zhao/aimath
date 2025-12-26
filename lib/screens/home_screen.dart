import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/student_provider.dart';
import '../providers/statistics_provider.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../widgets/stats_display.dart';
import '../widgets/achievement_preview.dart';

/// Home screen showing student profile, stats, and navigation
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Load statistics when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStatistics();
    });
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadStatistics();
    }
  }

  void _loadStatistics() {
    final studentProvider = context.read<StudentProvider>();
    final statsProvider = context.read<StatisticsProvider>();
    
    if (studentProvider.hasStudent) {
      // Reload student profile to get updated stats
      studentProvider.loadStudent(studentProvider.currentStudent!.id);
      statsProvider.loadStudentStats(studentProvider.currentStudent!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Math Practice'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings
              // Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: Consumer2<StudentProvider, StatisticsProvider>(
        builder: (context, studentProvider, statsProvider, child) {
          if (!studentProvider.hasStudent) {
            return _buildNoStudentView();
          }

          final student = studentProvider.currentStudent!;
          final accuracy = statsProvider.getAccuracyBreakdown();

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome header
                _buildWelcomeHeader(student.name, student.currentDifficultyLevel),

                const SizedBox(height: AppConstants.largePadding),

                // Main stats
                StatsDisplay(
                  currentLevel: student.currentDifficultyLevel,
                  totalPoints: student.totalPoints,
                  currentStreak: student.currentStreak,
                  overallAccuracy: student.overallAccuracyPercentage,
                  accuracyByOperation: accuracy,
                  onViewDetails: () {
                    // Navigate to detailed statistics
                  },
                ),

                const SizedBox(height: AppConstants.largePadding),

                // Achievements preview
                AchievementPreview(
                  achievementIcons: student.achievementIds.take(3).toList().isEmpty
                      ? []
                      : List.filled(student.achievementIds.take(3).length, '⭐'),
                  achievementTitles: List.filled(
                    student.achievementIds.take(3).length,
                    'Achievement',
                  ),
                  totalAchievements: student.achievementCount,
                  onViewAll: () {
                    // Navigate to achievements
                  },
                ),

                const SizedBox(height: AppConstants.largePadding),

                // Start practice button
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.defaultPadding,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/difficulty-selector');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.successGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppConstants.defaultBorderRadius,
                          ),
                        ),
                      ),
                      child: Text(
                        'Start Practice',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppConstants.defaultPadding),

                // Continue session button (if applicable)
                if (_shouldShowContinueButton(student))
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.defaultPadding,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () {
                          // Continue previous session
                        },
                        child: Text(
                          'Continue Session',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: AppConstants.largePadding),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeHeader(String name, int level) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryBlue,
            AppColors.primaryBlue.withValues(alpha: 0.7),
          ],
        ),
      ),
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome, $name! 👋',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Row(
            children: [
              Text(
                'Current Level: ',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.smallPadding,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Text(
                      '⭐ ',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      'Level $level',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool _shouldShowContinueButton(student) {
    // Check if there's an ongoing session
    // This would typically check if there's a session started but not completed
    return false; // Placeholder
  }

  Widget _buildNoStudentView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'No Student Selected',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/student-selection');
            },
            child: const Text('Select Student'),
          ),
        ],
      ),
    );
  }
}
