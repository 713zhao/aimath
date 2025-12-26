import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/difficulty_config.dart';
import '../providers/student_provider.dart';
import '../providers/statistics_provider.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../utils/enums.dart';
import '../widgets/difficulty_card.dart';

/// Screen for selecting difficulty level and operations for practice
class DifficultySelectorScreen extends StatefulWidget {
  const DifficultySelectorScreen({Key? key}) : super(key: key);

  @override
  State<DifficultySelectorScreen> createState() => _DifficultySelectorScreenState();
}

class _DifficultySelectorScreenState extends State<DifficultySelectorScreen> {
  late int _selectedLevel;
  late Set<Operation> _selectedOperations;
  int _selectedTimeLimitSeconds = 180; // Default 3 minutes
  
  // Time limit options: label -> seconds
  static const Map<String, int> _timeLimitOptions = {
    'No Limit': 0,
    '1 minute': 60,
    '2 minutes': 120,
    '3 minutes': 180,
    '5 minutes': 300,
    '10 minutes': 600,
  };

  @override
  void initState() {
    super.initState();
    _selectedLevel = context.read<StudentProvider>().currentLevel ?? 1;
    _selectedOperations = {
      Operation.add,
      Operation.subtract,
      Operation.multiply,
      Operation.divide,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Difficulty'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer2<StudentProvider, StatisticsProvider>(
        builder: (context, studentProvider, statsProvider, child) {
          final currentLevel = studentProvider.currentLevel ?? 1;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Difficulty levels
                Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Difficulty Level',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppConstants.defaultPadding),
                      ...DifficultyConfig.allLevels.map((level) {
                        final isUnlocked = level.id <= currentLevel;
                        final previousLevel = level.id > 1
                            ? DifficultyConfig.getLevelById(level.id - 1)
                            : null;
                        final progressToUnlock = previousLevel != null
                            ? statsProvider
                                .getLevelAccuracy(previousLevel.id)
                                .clamp(0, 100) /
                                100
                            : 1.0;

                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppConstants.defaultPadding,
                          ),
                          child: DifficultyCard(
                            level: level,
                            isSelected: _selectedLevel == level.id,
                            isUnlocked: isUnlocked,
                            progressToUnlock: progressToUnlock,
                            onSelect: () {
                              setState(() {
                                _selectedLevel = level.id;
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),

                // Operation selection
                Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Operations',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppConstants.defaultPadding),
                      Row(
                        children: [
                          _buildOperationCheckbox(
                            context,
                            Operation.add,
                            'Addition',
                            '➕',
                          ),
                          const SizedBox(width: AppConstants.defaultPadding),
                          _buildOperationCheckbox(
                            context,
                            Operation.subtract,
                            'Subtraction',
                            '➖',
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.defaultPadding),
                      Row(
                        children: [
                          _buildOperationCheckbox(
                            context,
                            Operation.multiply,
                            'Multiplication',
                            '✖️',
                          ),
                          const SizedBox(width: AppConstants.defaultPadding),
                          _buildOperationCheckbox(
                            context,
                            Operation.divide,
                            'Division',
                            '➗',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Time Limit Selection
                Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Time Limit',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppConstants.smallPadding),
                      Text(
                        'Set a time limit for the entire practice session',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.secondaryText,
                        ),
                      ),
                      const SizedBox(height: AppConstants.defaultPadding),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.primaryBlue),
                          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                        ),
                        child: DropdownButton<int>(
                          value: _selectedTimeLimitSeconds,
                          isExpanded: true,
                          underline: const SizedBox(),
                          icon: const Icon(Icons.timer, color: AppColors.primaryBlue),
                          items: _timeLimitOptions.entries.map((entry) {
                            return DropdownMenuItem<int>(
                              value: entry.value,
                              child: Text(
                                entry.key,
                                style: TextStyle(
                                  color: entry.value == _selectedTimeLimitSeconds
                                      ? AppColors.primaryBlue
                                      : AppColors.darkText,
                                  fontWeight: entry.value == _selectedTimeLimitSeconds
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedTimeLimitSeconds = value;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppConstants.largePadding),

                // Buttons
                Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton(
                        onPressed: _selectedOperations.isEmpty
                            ? null
                            : () {
                                _startPractice(context);
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.successGreen,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppConstants.defaultPadding,
                          ),
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
                      const SizedBox(height: AppConstants.smallPadding),
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppConstants.defaultPadding,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppConstants.defaultBorderRadius,
                            ),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOperationCheckbox(
    BuildContext context,
    Operation operation,
    String label,
    String icon,
  ) {
    final isSelected = _selectedOperations.contains(operation);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (isSelected) {
              if (_selectedOperations.length > 1) {
                _selectedOperations.remove(operation);
              }
            } else {
              _selectedOperations.add(operation);
            }
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryBlue.withValues(alpha: 0.1) : Colors.transparent,
            border: Border.all(
              color: isSelected ? AppColors.primaryBlue : AppColors.lightGray,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
          ),
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            children: [
              Checkbox(
                value: isSelected,
                onChanged: (_) {
                  setState(() {
                    if (isSelected) {
                      if (_selectedOperations.length > 1) {
                        _selectedOperations.remove(operation);
                      }
                    } else {
                      _selectedOperations.add(operation);
                    }
                  });
                },
                activeColor: AppColors.primaryBlue,
              ),
              const SizedBox(height: AppConstants.smallPadding),
              Text(
                icon,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppConstants.smallPadding),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startPractice(BuildContext context) {
    final operations = _selectedOperations.toList();
    
    // Navigate to practice session with selected parameters
    Navigator.pushNamed(
      context,
      '/practice-session',
      arguments: {
        'difficultyLevel': _selectedLevel,
        'operations': operations,
        'timeLimitSeconds': _selectedTimeLimitSeconds,
      },
    );
  }
}
