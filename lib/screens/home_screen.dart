import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/student_provider.dart';
import '../providers/statistics_provider.dart';
import '../utils/colors.dart';
import '../utils/enums.dart';
import '../widgets/stats_display.dart';
import '../widgets/achievement_preview.dart';

/// Home screen showing student profile, stats, and navigation
class HomeScreen extends StatefulWidget {
  final bool showBottomNav;

  const HomeScreen({
    Key? key,
    this.showBottomNav = true,
  }) : super(key: key);

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
        automaticallyImplyLeading: false,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.pushNamed(context, '/progress');
            },
            tooltip: 'View Progress',
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer2<StudentProvider, StatisticsProvider>(
          builder: (context, studentProvider, statsProvider, child) {
            final student = studentProvider.currentStudent;

            if (student == null) {
              return const Center(child: CircularProgressIndicator());
            }

            // Build accuracy map from stats
            final accuracyMap = <String, double>{};
            for (final stat in statsProvider.studentStats) {
              final opName = stat.operation.displayName;
              accuracyMap[opName] = stat.accuracyPercentage;
            }

            return RefreshIndicator(
              onRefresh: () async {
                await studentProvider.loadStudent(student.id);
                await statsProvider.loadStudentStats(student.id);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Card
                    _buildWelcomeCard(context, student.name),
                    const SizedBox(height: 16),

                    // Stats Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            context,
                            icon: Icons.star,
                            label: 'Level',
                            value: 'P${student.currentDifficultyLevel}',
                            color: AppColors.warningOrange,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            context,
                            icon: Icons.monetization_on,
                            label: 'Points',
                            value: '${student.totalPoints}',
                            color: AppColors.successGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Weekly Stats
                    const Text(
                      'This Week',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    StatsDisplay(
                      currentLevel: student.currentDifficultyLevel,
                      totalPoints: student.totalPoints,
                      currentStreak: student.currentStreak,
                      overallAccuracy: student.overallAccuracyPercentage,
                      accuracyByOperation: accuracyMap,
                    ),
                    const SizedBox(height: 24),

                    // Achievements Preview
                    const Text(
                      'Recent Achievements',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    AchievementPreview(
                      achievementIcons: const ['🏆', '⭐', '🎯'],
                      achievementTitles: const ['First Win', 'Practice Star', 'Accurate'],
                      totalAchievements: student.achievementIds.length,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context, String name) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              AppColors.primaryBlue,
              AppColors.primaryBlue.withValues(alpha: 0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back,',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              name,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Ready to practice some math?',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
