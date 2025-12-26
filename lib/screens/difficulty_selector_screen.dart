import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aimath/providers/student_provider.dart';
import 'package:aimath/providers/game_provider.dart';
import 'package:aimath/models/difficulty_level.dart';
import 'package:aimath/models/operation_type.dart';
import 'package:aimath/widgets/difficulty_card.dart';
import 'package:aimath/utils/colors.dart';

class DifficultySelectorScreen extends StatefulWidget {
  final bool asSettingsTab;

  const DifficultySelectorScreen({
    super.key,
    this.asSettingsTab = false,
  });

  @override
  State<DifficultySelectorScreen> createState() => _DifficultySelectorScreenState();
}

class _DifficultySelectorScreenState extends State<DifficultySelectorScreen> {
  DifficultyLevel _selectedLevel = DifficultyLevel.level1;
  final Set<OperationType> _selectedOperations = {OperationType.addition};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSavedSettings();
    });
  }

  void _loadSavedSettings() {
    final studentProvider = context.read<StudentProvider>();
    final gameProvider = context.read<GameProvider>();
    
    if (studentProvider.profile != null) {
      setState(() {
        _selectedLevel = studentProvider.profile!.currentLevel;
      });
    }
    
    // Load saved operation preferences if available
    final savedOperations = gameProvider.selectedOperations;
    if (savedOperations.isNotEmpty) {
      setState(() {
        _selectedOperations.clear();
        _selectedOperations.addAll(savedOperations);
      });
    }
  }

  void _toggleOperation(OperationType operation) {
    setState(() {
      if (_selectedOperations.contains(operation)) {
        if (_selectedOperations.length > 1) {
          _selectedOperations.remove(operation);
        }
      } else {
        _selectedOperations.add(operation);
      }
    });
    _saveSettings();
  }

  void _selectLevel(DifficultyLevel level) {
    final studentProvider = context.read<StudentProvider>();
    final unlockedLevels = studentProvider.profile?.unlockedLevels ?? [DifficultyLevel.level1];
    
    if (unlockedLevels.contains(level)) {
      setState(() {
        _selectedLevel = level;
      });
      _saveSettings();
    }
  }

  void _saveSettings() {
    final gameProvider = context.read<GameProvider>();
    gameProvider.setDifficulty(_selectedLevel);
    gameProvider.setOperations(_selectedOperations.toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.asSettingsTab ? 'Settings' : 'Select Difficulty'),
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: !widget.asSettingsTab,
        actions: widget.asSettingsTab
            ? [
                IconButton(
                  icon: const Icon(Icons.person),
                  onPressed: () => _showProfileSettings(context),
                  tooltip: 'Profile Settings',
                ),
              ]
            : null,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Difficulty Section
              const Text(
                'Difficulty Level',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Select your practice difficulty',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              _buildDifficultyCards(),
              const SizedBox(height: 32),

              // Operations Section
              const Text(
                'Operations',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Choose which operations to practice',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              _buildOperationToggles(),

              if (widget.asSettingsTab) ...[
                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 16),
                
                // App Settings Section
                const Text(
                  'App Settings',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildAppSettings(),
              ],

              if (!widget.asSettingsTab) ...[
                const SizedBox(height: 32),
                _buildActionButtons(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyCards() {
    return Consumer<StudentProvider>(
      builder: (context, provider, child) {
        final unlockedLevels = provider.profile?.unlockedLevels ?? [DifficultyLevel.level1];

        return Column(
          children: DifficultyLevel.values.map((level) {
            final isUnlocked = unlockedLevels.contains(level);
            final isSelected = _selectedLevel == level;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DifficultyCard(
                level: level,
                isSelected: isSelected,
                isUnlocked: isUnlocked,
                onTap: () => _selectLevel(level),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildOperationToggles() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: OperationType.values.map((operation) {
        final isSelected = _selectedOperations.contains(operation);
        return FilterChip(
          label: Text(
            '${operation.name} (${operation.symbol})',
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          selected: isSelected,
          onSelected: (_) => _toggleOperation(operation),
          selectedColor: AppColors.primary,
          checkmarkColor: Colors.white,
          backgroundColor: Colors.grey[200],
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        );
      }).toList(),
    );
  }

  Widget _buildAppSettings() {
    return Column(
      children: [
        _buildSettingsTile(
          icon: Icons.volume_up,
          title: 'Sound Effects',
          subtitle: 'Enable sound feedback',
          trailing: Switch(
            value: true, // TODO: Connect to actual setting
            onChanged: (value) {
              // TODO: Implement sound toggle
            },
            activeColor: AppColors.primary,
          ),
        ),
        _buildSettingsTile(
          icon: Icons.timer,
          title: 'Timer Duration',
          subtitle: '30 seconds per problem',
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: Show timer duration picker
          },
        ),
        _buildSettingsTile(
          icon: Icons.format_list_numbered,
          title: 'Problems per Session',
          subtitle: '10 problems',
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: Show problem count picker
          },
        ),
        const Divider(height: 32),
        _buildSettingsTile(
          icon: Icons.delete_outline,
          title: 'Clear Progress',
          subtitle: 'Reset all data',
          trailing: const Icon(Icons.chevron_right),
          textColor: AppColors.error,
          onTap: () => _showClearDataDialog(context),
        ),
        _buildSettingsTile(
          icon: Icons.info_outline,
          title: 'About',
          subtitle: 'Version 1.0.0',
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: Show about dialog
          },
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    Color? textColor,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? AppColors.primary),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: trailing,
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: () {
              _saveSettings();
              Navigator.pushNamed(context, '/practice');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'Start Practice',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  void _showProfileSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Profile Settings',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Change Name'),
                onTap: () {
                  Navigator.pop(context);
                  _showChangeNameDialog(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.restart_alt),
                title: const Text('Reset Profile'),
                onTap: () {
                  Navigator.pop(context);
                  _showResetProfileDialog(context);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showChangeNameDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'New Name',
            hintText: 'Enter your name',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                context.read<StudentProvider>().updateName(controller.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showResetProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Profile'),
        content: const Text(
          'This will reset your profile to Level 1 but keep your points and achievements. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<StudentProvider>().resetLevel();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all your progress, points, and achievements. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<StudentProvider>().clearAllData();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }
}
