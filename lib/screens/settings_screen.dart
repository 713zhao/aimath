import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/student_profile.dart';
import '../providers/student_provider.dart';
import '../services/audio_service.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../widgets/toggle_switch.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late AudioService _audioService;
  bool _soundEnabled = true;
  int _timeLimit = 180; // Default 3 minutes
  Set<String> _enabledOperations = {'add', 'subtract', 'multiply', 'divide'};
  int _minNumber = 0;
  int _maxNumber = 10;
  
  final TextEditingController _minController = TextEditingController();
  final TextEditingController _maxController = TextEditingController();

  static const List<int> _timeLimitOptions = [0, 60, 120, 180, 300, 600];
  
  static const List<Map<String, dynamic>> _operationOptions = [
    {'key': 'add', 'label': 'Addition', 'icon': Icons.add},
    {'key': 'subtract', 'label': 'Subtraction', 'icon': Icons.remove},
    {'key': 'multiply', 'label': 'Multiplication', 'icon': Icons.close},
    {'key': 'divide', 'label': 'Division', 'icon': Icons.safety_divider},
  ];
  
  @override
  void initState() {
    super.initState();
    _audioService = AudioService();
    _loadSettings();
  }
  
  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final savedOps = prefs.getStringList('enabledOperations');
    setState(() {
      _soundEnabled = _audioService.isMuted == false;
      _timeLimit = prefs.getInt('timeLimit') ?? 180;
      _enabledOperations = savedOps?.toSet() ?? {'add', 'subtract', 'multiply', 'divide'};
      _minNumber = prefs.getInt('minNumber') ?? 0;
      _maxNumber = prefs.getInt('maxNumber') ?? 10;
      _minController.text = _minNumber.toString();
      _maxController.text = _maxNumber.toString();
    });
  }
  
  Future<void> _saveNumberRange() async {
    final prefs = await SharedPreferences.getInstance();
    final minVal = int.tryParse(_minController.text) ?? 0;
    final maxVal = int.tryParse(_maxController.text) ?? 10;
    
    if (minVal >= 0 && maxVal > minVal && maxVal <= 9999) {
      setState(() {
        _minNumber = minVal;
        _maxNumber = maxVal;
      });
      await prefs.setInt('minNumber', minVal);
      await prefs.setInt('maxNumber', maxVal);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Number range set to $_minNumber - $_maxNumber'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid range. Min must be >= 0, Max must be > Min and <= 9999'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _toggleSound(bool value) {
    setState(() {
      _soundEnabled = value;
    });
    _audioService.toggleMute();
  }
  
  Future<void> _setTimeLimit(int seconds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('timeLimit', seconds);
    setState(() {
      _timeLimit = seconds;
    });
  }
  
  Future<void> _toggleOperation(String op) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_enabledOperations.contains(op)) {
        // Don't allow disabling all operations
        if (_enabledOperations.length > 1) {
          _enabledOperations.remove(op);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('At least one operation must be enabled'),
              duration: Duration(seconds: 2),
            ),
          );
          return;
        }
      } else {
        _enabledOperations.add(op);
      }
    });
    await prefs.setStringList('enabledOperations', _enabledOperations.toList());
  }
  
  String _formatTimeLimit(int seconds) {
    if (seconds == 0) return 'No Limit';
    if (seconds < 60) return '$seconds sec';
    final mins = seconds ~/ 60;
    return '$mins min';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(AppConstants.largePadding),
          child: Consumer<StudentProvider>(
            builder: (ctx, studentProvider, _) {
              final student = studentProvider.currentStudent;
              if (student == null) {
                return const Center(child: CircularProgressIndicator());
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Card
                  Container(
                    padding: EdgeInsets.all(AppConstants.largePadding),
                    decoration: BoxDecoration(
                      color: AppColors.lightBackground,
                      borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                      border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: Center(
                            child: Text(
                              student.name.isEmpty ? 'S' : student.name[0].toUpperCase(),
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: AppColors.primaryBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ),
                        SizedBox(width: AppConstants.largePadding),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                student.name,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: AppConstants.smallPadding),
                              Text(
                                'Age: ${student.age}',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppConstants.largePadding * 1.5),

                  // Practice Settings
                  Text(
                    'Practice Settings',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: AppConstants.smallPadding),
                  
                  // Number Range
                  Container(
                    padding: EdgeInsets.all(AppConstants.largePadding),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                      borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Number Range',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: AppConstants.smallPadding / 2),
                        Text(
                          'Set the range of numbers for problems (e.g., 0-10)',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                        ),
                        SizedBox(height: AppConstants.smallPadding),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _minController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Min',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                'to',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                controller: _maxController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Max',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: _saveNumberRange,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                              child: const Text('Save', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                        SizedBox(height: AppConstants.smallPadding),
                        Text(
                          'Current: $_minNumber - $_maxNumber',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppConstants.smallPadding),
                  
                  // User Level Display
                  Container(
                    padding: EdgeInsets.all(AppConstants.largePadding),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                      borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Level',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: AppConstants.smallPadding / 2),
                        Text(
                          'Based on your scores',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                        ),
                        SizedBox(height: AppConstants.smallPadding),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Level ${student.currentDifficultyLevel}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total Points: ${student.totalPoints}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                  Text(
                                    'Accuracy: ${student.overallAccuracyPercentage.toStringAsFixed(1)}%',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppConstants.smallPadding),
                        Text(
                          _getLevelProgressText(student),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppConstants.smallPadding),
                  
                  // Math Operations
                  Container(
                    padding: EdgeInsets.all(AppConstants.largePadding),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                      borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Math Operations',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: AppConstants.smallPadding / 2),
                        Text(
                          'Select which operations to practice',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                        ),
                        SizedBox(height: AppConstants.smallPadding),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _operationOptions.map((op) {
                            final isEnabled = _enabledOperations.contains(op['key']);
                            return GestureDetector(
                              onTap: () => _toggleOperation(op['key']),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isEnabled 
                                      ? AppColors.primaryBlue 
                                      : Colors.grey.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isEnabled 
                                        ? AppColors.primaryBlue 
                                        : Colors.grey.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      op['icon'] as IconData,
                                      size: 16,
                                      color: isEnabled ? Colors.white : Colors.grey,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      op['label'] as String,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: isEnabled ? Colors.white : Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppConstants.smallPadding),
                  
                  // Time Limit
                  Container(
                    padding: EdgeInsets.all(AppConstants.largePadding),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                      borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Time Limit',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: AppConstants.smallPadding / 2),
                        Text(
                          'Set practice session duration',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                        ),
                        SizedBox(height: AppConstants.smallPadding),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _timeLimitOptions.map((seconds) {
                            final isSelected = seconds == _timeLimit;
                            return GestureDetector(
                              onTap: () => _setTimeLimit(seconds),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected 
                                      ? AppColors.primaryBlue 
                                      : AppColors.primaryBlue.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected 
                                        ? AppColors.primaryBlue 
                                        : AppColors.primaryBlue.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Text(
                                  _formatTimeLimit(seconds),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: isSelected ? Colors.white : AppColors.primaryBlue,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppConstants.largePadding * 1.5),

                  // Audio Settings
                  Text(
                    'Audio & Sound',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: AppConstants.smallPadding),
                  
                  // Sound Toggle
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppConstants.largePadding,
                      vertical: AppConstants.smallPadding,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                      borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sound Effects',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            SizedBox(height: AppConstants.smallPadding / 2),
                            Text(
                              'Enable or disable sound',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                            ),
                          ],
                        ),
                        ToggleSwitch(value: _soundEnabled, onChanged: _toggleSound),
                      ],
                    ),
                  ),
                  SizedBox(height: AppConstants.largePadding * 2),

                  // App Info
                  Text(
                    'App Info',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: AppConstants.smallPadding),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppConstants.largePadding,
                      vertical: AppConstants.smallPadding,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                      borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                    ),
                    child: Text(
                      'Version 1.0.0',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
  
  String _getLevelProgressText(StudentProfile student) {
    final level = student.currentDifficultyLevel;
    final points = student.totalPoints;
    if (level >= 4) {
      return 'You reached the highest level! 🎉';
    }
    // Points needed for next level: Level 2 = 500, Level 3 = 1500, Level 4 = 3000
    final pointsNeeded = [0, 500, 1500, 3000];
    final nextLevelPoints = pointsNeeded[level];
    final remaining = nextLevelPoints - points;
    if (remaining <= 0) {
      return 'Complete a session to level up!';
    }
    return 'Need $remaining more points for Level ${level + 1}';
  }
}
