import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/home_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/practice_session_screen.dart';
import '../providers/student_provider.dart';
import '../utils/colors.dart';
import '../utils/enums.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const HomeScreen(showBottomNav: false),
          PracticeTab(onNavigateHome: () => setState(() => _currentIndex = 0)),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primaryBlue,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 12,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.play_circle_outline),
              activeIcon: Icon(Icons.play_circle),
              label: 'Practice',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}

/// Practice tab wrapper - shows practice start or session
class PracticeTab extends StatefulWidget {
  final VoidCallback onNavigateHome;

  const PracticeTab({
    super.key,
    required this.onNavigateHome,
  });

  @override
  State<PracticeTab> createState() => _PracticeTabState();
}

class _PracticeTabState extends State<PracticeTab> {
  bool _isInSession = false;
  int _timeLimit = 180;
  int _minNumber = 0;
  int _maxNumber = 10;
  List<Operation> _operations = [Operation.add, Operation.subtract, Operation.multiply, Operation.divide];

  void _startSession(List<Operation> ops, int timeLimit, int minNum, int maxNum) {
    setState(() {
      _isInSession = true;
      _operations = ops;
      _timeLimit = timeLimit;
      _minNumber = minNum;
      _maxNumber = maxNum;
    });
  }

  void _endSession() {
    setState(() {
      _isInSession = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isInSession) {
      return PracticeSessionScreen(
        difficultyLevel: 1, // Not used anymore, we use number range
        operations: _operations,
        timeLimitSeconds: _timeLimit,
        minNumber: _minNumber,
        maxNumber: _maxNumber,
        onSessionEnd: _endSession,
      );
    }
    return PracticeStartScreen(onStartPractice: _startSession);
  }
}

/// Practice start screen with quick start options
class PracticeStartScreen extends StatefulWidget {
  final void Function(List<Operation> ops, int timeLimit, int minNum, int maxNum) onStartPractice;

  const PracticeStartScreen({
    super.key,
    required this.onStartPractice,
  });

  @override
  State<PracticeStartScreen> createState() => _PracticeStartScreenState();
}

class _PracticeStartScreenState extends State<PracticeStartScreen> {
  int _timeLimit = 180;
  int _minNumber = 0;
  int _maxNumber = 10;
  Set<String> _enabledOperations = {'add', 'subtract', 'multiply', 'divide'};
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final savedOps = prefs.getStringList('enabledOperations');
    setState(() {
      _timeLimit = prefs.getInt('timeLimit') ?? 180;
      _minNumber = prefs.getInt('minNumber') ?? 0;
      _maxNumber = prefs.getInt('maxNumber') ?? 10;
      _enabledOperations = savedOps?.toSet() ?? {'add', 'subtract', 'multiply', 'divide'};
    });
  }

  @override
  Widget build(BuildContext context) {
    final studentProvider = context.watch<StudentProvider>();
    final student = studentProvider.currentStudent;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Practice'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              // Quick start card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: InkWell(
                  onTap: () => _startPracticeSession(context),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryBlue,
                          AppColors.primaryBlue.withValues(alpha: 0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.play_arrow_rounded,
                          size: 64,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Start Practice',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Numbers: $_minNumber - $_maxNumber • ${_formatTimeLimit(_timeLimit)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getOperationsLabel(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Info text
              const Text(
                'Configure difficulty and time limit in Settings tab',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              // Quick stats
              if (student != null) ...[
                const Text(
                  'Quick Stats',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildQuickStatCard(
                  context,
                  icon: Icons.check_circle,
                  label: 'Total Correct',
                  value: '${student.totalCorrectAnswers}',
                ),
                const SizedBox(height: 8),
                _buildQuickStatCard(
                  context,
                  icon: Icons.trending_up,
                  label: 'Current Streak',
                  value: '${student.currentStreak}',
                ),
                const SizedBox(height: 8),
                _buildQuickStatCard(
                  context,
                  icon: Icons.star,
                  label: 'Total Points',
                  value: '${student.totalPoints} pts',
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  String _formatTimeLimit(int seconds) {
    if (seconds == 0) return 'No Limit';
    if (seconds < 60) return '$seconds sec';
    final mins = seconds ~/ 60;
    return '$mins min';
  }
  
  String _getOperationsLabel() {
    if (_enabledOperations.length == 4) return 'All operations';
    final labels = <String>[];
    if (_enabledOperations.contains('add')) labels.add('+');
    if (_enabledOperations.contains('subtract')) labels.add('−');
    if (_enabledOperations.contains('multiply')) labels.add('×');
    if (_enabledOperations.contains('divide')) labels.add('÷');
    return labels.join(' ');
  }

  void _startPracticeSession(BuildContext context) {
    final operations = _enabledOperations.map((op) {
      switch (op) {
        case 'add': return Operation.add;
        case 'subtract': return Operation.subtract;
        case 'multiply': return Operation.multiply;
        case 'divide': return Operation.divide;
        default: return Operation.add;
      }
    }).toList();
    
    widget.onStartPractice(operations, _timeLimit, _minNumber, _maxNumber);
  }

  Widget _buildQuickStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppColors.primaryBlue),
        title: Text(label),
        trailing: Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlue,
          ),
        ),
      ),
    );
  }
}
